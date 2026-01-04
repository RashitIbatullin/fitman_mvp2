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
}
