import 'package:fitman_backend/modules/infrastructure/models/equipment/equipment_category.enum.dart';
import 'package:fitman_backend/modules/infrastructure/models/equipment/equipment_sub_type.enum.dart';

class EquipmentType {
  EquipmentType({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    this.subType,
    this.weightRange,
    this.dimensions,
    this.powerRequirements,
    this.isMobile = true,
    this.exerciseTypeId,
    this.photoUrl,
    this.manualUrl,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String? description;

  // Классификация
  final EquipmentCategory category;
  final EquipmentSubType? subType;

  // Базовые характеристики
  final String? weightRange;
  final String? dimensions;
  final String? powerRequirements;
  final bool isMobile;

  // Связи
  final String? exerciseTypeId;

  // Медиа
  final String? photoUrl;
  final String? manualUrl;

  // Статус
  final bool isActive;

  factory EquipmentType.fromMap(Map<String, dynamic> map) {
    final category = EquipmentCategory.values[map['category'] as int];
    EquipmentSubType? subType;
    final subTypeValue = map['sub_type'] as int?;

    if (subTypeValue != null) {
      switch (category) {
        case EquipmentCategory.cardio:
          const mapping = {
            0: EquipmentSubType.treadmill,
            1: EquipmentSubType.elliptical,
            2: EquipmentSubType.bike,
          };
          subType = mapping[subTypeValue];
          break;
        case EquipmentCategory.strength:
          const mapping = {
            0: EquipmentSubType.bench,
            1: EquipmentSubType.legPress,
          };
          subType = mapping[subTypeValue];
          break;
        case EquipmentCategory.freeWeights:
          const mapping = {
            0: EquipmentSubType.dumbbell,
            1: EquipmentSubType.barbell,
          };
          subType = mapping[subTypeValue];
          break;
        case EquipmentCategory.functional:
          const mapping = {0: EquipmentSubType.fitball};
          subType = mapping[subTypeValue];
          break;
        case EquipmentCategory.accessories:
          const mapping = {0: EquipmentSubType.yogaMat};
          subType = mapping[subTypeValue];
          break;
        case EquipmentCategory.measurement:
          const mapping = {0: EquipmentSubType.scales};
          subType = mapping[subTypeValue];
          break;
        case EquipmentCategory.other:
          subType = EquipmentSubType.none;
          break;
      }
    }

    return EquipmentType(
      id: map['id'].toString(),
      name: map['name'] as String,
      description: map['description'] as String?,
      category: category,
      subType: subType,
      weightRange: map['weight_range'] as String?,
      dimensions: map['dimensions'] as String?,
      powerRequirements: map['power_requirements'] as String?,
      isMobile: map['is_mobile'] as bool,
      exerciseTypeId: map['exercise_type_id']?.toString(),
      photoUrl: map['photo_url'] as String?,
      manualUrl: map['manual_url'] as String?,
      isActive: map['is_active'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.index, // Revert to index
      'subType': subType?.index, // Revert to index
      'weightRange': weightRange,
      'dimensions': dimensions,
      'powerRequirements': powerRequirements,
      'isMobile': isMobile,
      'exerciseTypeId': exerciseTypeId,
      'photoUrl': photoUrl,
      'manualUrl': manualUrl,
      'isActive': isActive,
    };
  }
}
