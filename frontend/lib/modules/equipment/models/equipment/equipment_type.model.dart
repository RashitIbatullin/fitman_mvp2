import 'package:freezed_annotation/freezed_annotation.dart';
import 'equipment_category.enum.dart';
// import 'equipment_sub_type.enum.dart'; // Commented out as subType field is commented
import 'equipment_category.converter.dart';

part 'equipment_type.model.freezed.dart';
part 'equipment_type.model.g.dart';

@freezed
class EquipmentType with _$EquipmentType {
  const factory EquipmentType({
    required String id,
    required String name,
    String? description,
    @EquipmentCategoryConverter() required EquipmentCategory category,
    // EquipmentSubType? subType, // Commented out due to inconsistent DB values
    String? weightRange,
    String? dimensions,

    @Default(true) bool isMobile,



    String? schematicIcon,

    DateTime? archivedAt,
    String? archivedBy,
    String? archivedReason,
  }) = _EquipmentType;

  factory EquipmentType.fromJson(Map<String, dynamic> json) =>
      _$EquipmentTypeFromJson(json);
}
