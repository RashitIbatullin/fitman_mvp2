import '../../config/database.dart';
import '../../models/user_back.dart';

// Helper data classes for clarity
class _ClientData {
  final User user;
  final Map<String, dynamic> anthropometry;
  final Map<String, dynamic> bioimpedance;

  _ClientData({
    required this.user,
    required this.anthropometry,
    required this.bioimpedance,
  });
}

class _SomatotypeProfile {
  final double ectomorph;
  final double mesomorph;
  final double endomorph;

  _SomatotypeProfile({
    this.ectomorph = 0,
    this.mesomorph = 0,
    this.endomorph = 0,
  });

  String get dominantType {
    if (ectomorph >= mesomorph && ectomorph >= endomorph) return 'Эктоморф';
    if (mesomorph >= ectomorph && mesomorph >= endomorph) return 'Мезоморф';
    return 'Эндоморф';
  }

  @override
  String toString() {
    return 'Эктоморф: ${ectomorph.toStringAsFixed(0)}%, Мезоморф: ${mesomorph.toStringAsFixed(0)}%, Эндоморф: ${endomorph.toStringAsFixed(0)}%';
  }
}

class RecommendationService {
  final db = Database();

  Future<Map<String, String?>> generateRecommendation(int userId) async {
    print('[RecommendationService] Starting recommendation generation for userId: $userId');

    // 1. Сбор данных
    final clientData = await _getClientData(userId);
    if (clientData == null) {
      print('[RecommendationService] ERROR: Failed to get client data or client has no anthropometry.');
      return {
        'client_recommendation': 'Недостаточно данных для генерации рекомендации.',
        'trainer_recommendation': 'Клиент не найден или у него отсутствуют антропометрические данные.',
      };
    }

    final rules = await db.getSomatotypeRules();
    final allRecommendations = await db.getTrainingRecommendations();
    print('[RecommendationService] Fetched ${allRecommendations.length} total recommendations and ${rules.length} somatotype rules.');

    // 2. Анализ
    final somatotype = _determineSomatotype(clientData, rules);
    final bodyShape = _determineBodyShape(clientData.anthropometry['start']);
    
    print('[RecommendationService] Calculated values:');
    print('  - Goal ID: ${clientData.user.clientProfile?.goalTrainingId}');
    print('  - Level ID: ${clientData.user.clientProfile?.levelTrainingId}');
    print('  - Somatotype: $somatotype');
    print('  - Body Shape: $bodyShape');

    // 3. Генерация рекомендации
    final recommendation = _findBestRecommendation(
      bodyShape: bodyShape,
      goalId: clientData.user.clientProfile?.goalTrainingId,
      levelId: clientData.user.clientProfile?.levelTrainingId,
      dominantSomatotype: somatotype.dominantType,
      recommendations: allRecommendations,
    );

    if (recommendation == null) {
      print('[RecommendationService] ERROR: No matching recommendation found in the database.');
      return {
        'client_recommendation': 'Не удалось подобрать индивидуальную рекомендацию. Обратитесь к тренеру.',
        'trainer_recommendation': 'Не найдено подходящей рекомендации в базе. Проверьте каталог training_recommendations.',
      };
    }
    
    print('[RecommendationService] Found recommendation: ${recommendation['id']} for body_type: ${recommendation['body_type']}');


    // TODO: AI Enhancer logic will be added later

    return {
      'client_recommendation': recommendation['recommendation_text_client'] as String?,
      'trainer_recommendation': recommendation['recommendation_text_trainer'] as String?,
    };
  }

  Future<_ClientData?> _getClientData(int userId) async {
    final user = await db.getUserById(userId);
    if (user == null) return null;

    final anthropometry = await db.getAnthropometryData(userId);
    final bioimpedance = await db.getBioimpedanceData(userId);
    
    if (anthropometry['start'] == null || (anthropometry['start'] as Map).isEmpty) {
      return null;
    }

    return _ClientData(
      user: user,
      anthropometry: anthropometry,
      bioimpedance: bioimpedance,
    );
  }

  _SomatotypeProfile _determineSomatotype(_ClientData data, List<Map<String, dynamic>> rules) {
    final gender = data.user.gender == 'мужской' ? 'M' : 'Ж';
    final wristCirc = (data.anthropometry['fixed']?['wrist_circ'] as num?)?.toDouble();
    final ankleCirc = (data.anthropometry['fixed']?['ankle_circ'] as num?)?.toDouble();

    if (wristCirc == null && ankleCirc == null) {
      return _SomatotypeProfile();
    }

    final scores = <String, double>{};
    final relevantRules = rules.where((r) => r['gender'] == gender || r['gender'] == 'ALL').toList();

    for (final rule in relevantRules) {
      final typeName = rule['name'] as String;
      double wristScore = 0;
      double ankleScore = 0;
      int scoresCount = 0;

      if (wristCirc != null) {
        final min = (rule['wrist_min'] as num?)?.toDouble();
        final max = (rule['wrist_max'] as num?)?.toDouble();
        wristScore = _calculateScore(wristCirc, min, max);
        scoresCount++;
      }
      
      if (ankleCirc != null) {
        final min = (rule['ankle_min'] as num?)?.toDouble();
        final max = (rule['ankle_max'] as num?)?.toDouble();
        ankleScore = _calculateScore(ankleCirc, min, max);
        scoresCount++;
      }

      if (scoresCount > 0) {
        scores[typeName] = (scores[typeName] ?? 0) + (wristScore + ankleScore) / scoresCount;
      }
    }

    final totalScore = scores.values.fold(0.0, (sum, val) => sum + val);
    if (totalScore == 0) return _SomatotypeProfile();

    final ecto = (scores['Эктоморф'] ?? 0) / totalScore * 100;
    final meso = (scores['Мезоморф'] ?? 0) / totalScore * 100;
    final endo = (scores['Эндоморф'] ?? 0) / totalScore * 100;

    return _SomatotypeProfile(ectomorph: ecto, mesomorph: meso, endomorph: endo);
  }

  double _calculateScore(double value, double? min, double? max) {
    // This logic determines how "close" a value is to a given range.
    // If a rule has only a min (e.g., endomorph), anything above is a match.
    // If a rule has only a max (e.g., ectomorph), anything below is a match.
    // If a rule has both, it must be within the range.
    if (min != null && max != null) { // Mesomorph case
      return (value >= min && value <= max) ? 100 : 0;
    } else if (min != null) { // Endomorph case
      return (value >= min) ? 100 : 0;
    } else if (max != null) { // Ectomorph case
      return (value <= max) ? 100 : 0;
    }
    return 0;
  }

  String _determineBodyShape(Map<String, dynamic> startAnthro) {
    final shoulders = (startAnthro['shoulders_circ'] as num?)?.toDouble();
    final waist = (startAnthro['waist_circ'] as num?)?.toDouble();
    final hips = (startAnthro['hips_circ'] as num?)?.toDouble();

    if (shoulders == null || waist == null || hips == null || shoulders == 0 || waist == 0 || hips == 0) {
      return 'Не определен';
    }

    // Логика из ТЗ
    if ((waist / hips >= 0.85) && (waist > shoulders) && (waist > hips)) {
      return 'Яблоко';
    }
    if (hips > shoulders * 1.05) {
      return 'Груша';
    }
    if ((shoulders / hips).abs() < 1.05 && (hips / shoulders).abs() < 1.05) {
       if ((waist / shoulders) < 0.75) return 'Песочные часы';
       return 'Прямоугольник';
    }
    if (shoulders > hips * 1.05) {
      return 'Перевернутый треугольник';
    }

    return 'Не определен';
  }

  Map<String, dynamic>? _findBestRecommendation({
    required String bodyShape,
    required int? goalId,
    required int? levelId,
    required String dominantSomatotype,
    required List<Map<String, dynamic>> recommendations,
  }) {
    if (goalId == null || levelId == null) {
      print('[_findBestRecommendation] Error: goalId or levelId is null.');
      return null;
    }

    final filtered = recommendations.where((rec) {
      return rec['body_type'] == bodyShape &&
             rec['goal_training_id'] == goalId &&
             rec['level_training_id'] == levelId;
    }).toList();

    print('[_findBestRecommendation] Found ${filtered.length} direct matches for bodyShape: $bodyShape, goal: $goalId, level: $levelId.');

    if (filtered.isEmpty) {
       // Fallback to 'Не определен' if no specific recommendation is found
       final fallback = recommendations.where((rec) {
         return rec['body_type'] == 'Не определен' &&
                rec['goal_training_id'] == goalId &&
                rec['level_training_id'] == levelId;
       }).toList();

       print('[_findBestRecommendation] Found ${fallback.length} fallback matches.');
       
       if (fallback.isNotEmpty) return fallback.first;
       return null;
    }

    if (filtered.length == 1) {
      return filtered.first;
    }
    
    // Если найдено несколько записей, приоритет отдается той, 
    // которая лучше всего подходит для преобладающего соматотипа.
    // (This logic is not fully defined in the TS, so we'll just take the first match for now)
    // A future implementation could add a 'dominant_somatotype' column to the recommendations table.
    print('[_findBestRecommendation] Multiple direct matches found, returning the first one.');
    return filtered.first;
  }
}
