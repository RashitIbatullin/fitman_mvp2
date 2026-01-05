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
    return EquipmentType(
      id: map['id'].toString(),
      name: map['name'] as String,
      description: map['description'] as String?,
      category: EquipmentCategory.values[map['category'] as int],
      subType: map['sub_type'] != null ? EquipmentSubType.values[map['sub_type'] as int] : null,
      weightRange: map['weight_range'] as String?,
      dimensions: map['dimensions'] as String?,
      powerRequirements: map['power_requirements'] as String?,
      isMobile: map['is_mobile'] as bool,
      exerciseTypeId: map['exercise_type_id']?.toString(), // exercise_type_id can be null
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
