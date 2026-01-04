import 'package:freezed_annotation/freezed_annotation.dart';
import 'equipment_category.enum.dart';
import 'equipment_sub_type.enum.dart';

part 'equipment_type.model.freezed.dart';
part 'equipment_type.model.g.dart';

@freezed
class EquipmentType with _$EquipmentType {
  const factory EquipmentType({
    required String id,
    required String name,
    String? description,
    required EquipmentCategory category,
    EquipmentSubType? subType,
    String? weightRange,
    String? dimensions,
    String? powerRequirements,
    @Default(true) bool isMobile,
    String? exerciseTypeId,
    String? photoUrl,
    String? manualUrl,
    @Default(true) bool isActive,
  }) = _EquipmentType;

  factory EquipmentType.fromJson(Map<String, dynamic> json) =>
      _$EquipmentTypeFromJson(json);
}
