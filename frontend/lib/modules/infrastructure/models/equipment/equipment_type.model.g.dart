// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equipment_type.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EquipmentTypeImpl _$$EquipmentTypeImplFromJson(Map<String, dynamic> json) =>
    _$EquipmentTypeImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: $enumDecode(_$EquipmentCategoryEnumMap, json['category']),
      subType: $enumDecodeNullable(_$EquipmentSubTypeEnumMap, json['subType']),
      weightRange: json['weightRange'] as String?,
      dimensions: json['dimensions'] as String?,
      powerRequirements: json['powerRequirements'] as String?,
      isMobile: json['isMobile'] as bool? ?? true,
      exerciseTypeId: json['exerciseTypeId'] as String?,
      photoUrl: json['photoUrl'] as String?,
      manualUrl: json['manualUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$$EquipmentTypeImplToJson(_$EquipmentTypeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'category': _$EquipmentCategoryEnumMap[instance.category]!,
      'subType': _$EquipmentSubTypeEnumMap[instance.subType],
      'weightRange': instance.weightRange,
      'dimensions': instance.dimensions,
      'powerRequirements': instance.powerRequirements,
      'isMobile': instance.isMobile,
      'exerciseTypeId': instance.exerciseTypeId,
      'photoUrl': instance.photoUrl,
      'manualUrl': instance.manualUrl,
      'isActive': instance.isActive,
    };

const _$EquipmentCategoryEnumMap = {
  EquipmentCategory.cardio: 'cardio',
  EquipmentCategory.strength: 'strength',
  EquipmentCategory.freeWeights: 'freeWeights',
  EquipmentCategory.functional: 'functional',
  EquipmentCategory.accessories: 'accessories',
  EquipmentCategory.measurement: 'measurement',
  EquipmentCategory.other: 'other',
};

const _$EquipmentSubTypeEnumMap = {EquipmentSubType.none: 'none'};
