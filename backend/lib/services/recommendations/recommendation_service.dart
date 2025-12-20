import '../../config/database.dart';
import '../../models/user_back.dart';
import 'somatotype_helper.dart';

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

class _WhtrProfile {
  final double ratio;
  final String gradation;

  _WhtrProfile({required this.ratio, required this.gradation});
}


class RecommendationService {
  final db = Database();

  /// Returns a calculated SomatotypeProfile for a given user.
  /// This is the single source of truth for somatotype calculation.
  Future<SomatotypeProfile?> getSomatotypeProfileForUser(int userId) async {
    final clientData = await _getClientData(userId);
    if (clientData == null) {
      print('[RecommendationService] Could not get client data for somatotype profile.');
      return null;
    }
    final rules = await db.getSomatotypeRules();
    final profile = _determineSomatotype(clientData, rules);
    return profile;
  }

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
    final baseRecommendations = await db.getBodyShapeRecommendations(); 
    final whtrRefinements = await db.getWhtrRefinements();
    
    print('[RecommendationService] Fetched ${baseRecommendations.length} base recommendations and ${whtrRefinements.length} WHtR refinements.');

    // 2. Анализ
    final somatotype = _determineSomatotype(clientData, rules);
    final bodyShape = _determineBodyShape(clientData.anthropometry['start']);
    final whtrProfile = _determineWhtrProfile(clientData);
    
    print('[RecommendationService] Calculated values:');
    print('  - Goal ID: ${clientData.user.clientProfile?.goalTrainingId}');
    print('  - Level ID: ${clientData.user.clientProfile?.levelTrainingId}');
    print('  - Somatotype: $somatotype');
    print('  - Body Shape: $bodyShape');
    print('  - WHtR: ${whtrProfile.ratio.toStringAsFixed(2)} (${whtrProfile.gradation})');

    // 3. Генерация рекомендации
    final recommendation = _buildFinalRecommendation(
      bodyShape: bodyShape,
      whtrGradation: whtrProfile.gradation,
      goalId: clientData.user.clientProfile?.goalTrainingId,
      levelId: clientData.user.clientProfile?.levelTrainingId,
      baseRecommendations: baseRecommendations,
      whtrRefinements: whtrRefinements,
    );

    if (recommendation == null) {
      print('[RecommendationService] ERROR: No matching recommendation found in the database.');
      return {
        'client_recommendation': 'Не удалось подобрать индивидуальную рекомендацию. Обратитесь к тренеру.',
        'trainer_recommendation': 'Не найдено подходящей рекомендации в базе. Проверьте каталоги body_shape_recommendations и whtr_refinements.',
      };
    }
    
    print('[RecommendationService] Successfully built a combined recommendation.');

    // The helper now always returns a meaningful string.
    final somatotypeHelp = getSomatotypeHelpTextForRecommendation(somatotype);

    final enrichedClientRecommendation = (recommendation['client_recommendation'] ?? '') + somatotypeHelp;
    final enrichedTrainerRecommendation = (recommendation['trainer_recommendation'] ?? '') + somatotypeHelp;

    return {
      'client_recommendation': enrichedClientRecommendation,
      'trainer_recommendation': enrichedTrainerRecommendation,
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
    if (anthropometry['fixed'] == null || (anthropometry['fixed'] as Map).isEmpty) {
      return null;
    }

    return _ClientData(
      user: user,
      anthropometry: anthropometry,
      bioimpedance: bioimpedance,
    );
  }

  SomatotypeProfile _determineSomatotype(_ClientData data, List<Map<String, dynamic>> rules) {
    final gender = data.user.gender == 'мужской' ? 'M' : 'Ж';
    final wristCirc = (data.anthropometry['fixed']?['wrist_circ'] as num?)?.toDouble();
    final ankleCirc = (data.anthropometry['fixed']?['ankle_circ'] as num?)?.toDouble();

    if (wristCirc == null) { // wristCirc is mandatory for this calculation
      return SomatotypeProfile();
    }

    final scores = <String, double>{};
    final relevantRules = rules.where((r) => r['gender'] == gender || r['gender'] == 'ALL').toList();

    for (final rule in relevantRules) {
      final typeName = rule['name'] as String;
      
      final wristMin = (rule['wrist_min'] as num?)?.toDouble();
      final wristMax = (rule['wrist_max'] as num?)?.toDouble();
      final ankleMin = (rule['ankle_min'] as num?)?.toDouble();
      final ankleMax = (rule['ankle_max'] as num?)?.toDouble();

      final wristScore = _calculateScore(wristCirc, wristMin, wristMax);
      
      if (ankleCirc != null) {
        final ankleScore = _calculateScore(ankleCirc, ankleMin, ankleMax);
        scores[typeName] = (wristScore + ankleScore) / 2;
      } else {
        scores[typeName] = wristScore;
      }
    }

    final totalScore = scores.values.fold(0.0, (sum, val) => sum + val);
    if (totalScore == 0) return SomatotypeProfile();

    final ecto = (scores['Эктоморф'] ?? 0) / totalScore * 100;
    final meso = (scores['Мезоморф'] ?? 0) / totalScore * 100;
    final endo = (scores['Эндоморф'] ?? 0) / totalScore * 100;

    return SomatotypeProfile(ectomorph: ecto, mesomorph: meso, endomorph: endo);
  }

  double _calculateScore(double value, double? min, double? max) {
    const falloffRange = 2.0;
    const falloffFactor = 100 / falloffRange;

    if (min != null && max != null) { // Мезоморф
      if (value >= min && value <= max) {
        return 100;
      } else if (value > max && value <= max + falloffRange) {
        return 100 - (value - max) * falloffFactor;
      } else if (value < min && value >= min - falloffRange) {
        return 100 - (min - value) * falloffFactor;
      }
    } else if (min == null && max != null) { // Эктоморф
      if (value <= max) {
        return 100;
      } else if (value > max && value <= max + falloffRange) {
        return 100 - (value - max) * falloffFactor;
      }
    } else if (min != null && max == null) { // Эндоморф
      if (value >= min) {
        return 100;
      } else if (value < min && value >= min - falloffRange) {
        return 100 - (min - value) * falloffFactor;
      }
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
    final waistToHips = waist / hips;
    final shouldersToHips = (shoulders / hips).abs();

    if (waistToHips >= 0.85 && waist > shoulders && waist > hips) {
      return 'Яблоко';
    }
    if (hips > shoulders * 1.05) {
      return 'Груша';
    }
    if (shouldersToHips >= 0.95 && shouldersToHips <= 1.05) { // Shoulders and hips are about the same
       if ((waist / shoulders) < 0.75) return 'Песочные часы';
       return 'Прямоугольник';
    }
    if (shoulders > hips * 1.05) {
      return 'Перевернутый треугольник';
    }

    return 'Не определен';
  }

  _WhtrProfile _determineWhtrProfile(_ClientData data) {
    final height = (data.anthropometry['fixed']?['height'] as num?)?.toDouble();
    final waist = (data.anthropometry['start']?['waist_circ'] as num?)?.toDouble();
    final age = data.user.age;

    if (height == null || waist == null || height == 0) {
      return _WhtrProfile(ratio: 0, gradation: 'Не определен');
    }

    final ratio = waist / height;
    var whtrWithAge = ratio;

    // Поправка на возраст из ТЗ
    if (age != null) {
      if (age <= 25) {
        // no correction
      } else if (age <= 40) {
        whtrWithAge += 0.02;
      } else if (age <= 60) {
        whtrWithAge += 0.04;
      } else {
        whtrWithAge += 0.05;
      }
    }
    
    String gradation;
    if (whtrWithAge > 0.6) {
      gradation = 'Высокий риск ожирения';
    } else if (whtrWithAge > 0.55) {
      gradation = 'Повышенный риск ожирения';
    } else if (whtrWithAge >= 0.45) {
      gradation = 'Норма';
    } else if (whtrWithAge >= 0.4) {
      gradation = 'Повышенный риск истощения';
    } else {
      gradation = 'Высокий риск истощения';
    }

    return _WhtrProfile(ratio: ratio, gradation: gradation);
  }

  Map<String, String>? _buildFinalRecommendation({
    required String bodyShape,
    required String whtrGradation,
    required int? goalId,
    required int? levelId,
    required List<Map<String, dynamic>> baseRecommendations,
    required List<Map<String, dynamic>> whtrRefinements,
  }) {
    if (goalId == null || levelId == null) {
      print('[_buildFinalRecommendation] Error: goalId or levelId is null.');
      return null;
    }

    // 1. Find base recommendation (strict search)
    final baseRec = baseRecommendations.firstWhere(
      (rec) =>
          rec['body_type'] == bodyShape &&
          rec['goal_training_id'] == goalId &&
          rec['level_training_id'] == levelId,
      orElse: () => {}, // Return an empty map if not found
    );

    if (baseRec.isEmpty) {
      print('[_buildFinalRecommendation] Could not find a specific base recommendation for body_type: $bodyShape, goal_id: $goalId, level_id: $levelId.');
      return null;
    }

    // 2. Find refinement
    final refinement = whtrRefinements.firstWhere(
      (ref) =>
          ref['whtr_gradation'] == whtrGradation &&
          ref['goal_training_id'] == goalId,
      orElse: () => {}, // Return an empty map if not found
    );

    final clientText = (baseRec['recommendation_text_client'] ?? '') +
        (refinement['refinement_text_client'] ?? '');
    
    final trainerText = (baseRec['recommendation_text_trainer'] ?? '') +
        (refinement['refinement_text_trainer'] ?? '');
    
    return {
      'client_recommendation': clientText,
      'trainer_recommendation': trainerText,
    };
  }
}