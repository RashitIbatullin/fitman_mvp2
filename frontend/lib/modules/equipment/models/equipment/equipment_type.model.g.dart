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
      category: const EquipmentCategoryConverter().fromJson(
        (json['category'] as num).toInt(),
      ),
      weightRange: json['weight_range'] as String?,
      dimensions: json['dimensions'] as String?,
      powerRequirements: json['power_requirements'] as String?,
      isMobile: json['is_mobile'] as bool? ?? true,
      exerciseTypeId: json['exercise_type_id'] as String?,
      photoUrl: json['photo_url'] as String?,
      manualUrl: json['manual_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );

Map<String, dynamic> _$$EquipmentTypeImplToJson(_$EquipmentTypeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'category': const EquipmentCategoryConverter().toJson(instance.category),
      'weight_range': instance.weightRange,
      'dimensions': instance.dimensions,
      'power_requirements': instance.powerRequirements,
      'is_mobile': instance.isMobile,
      'exercise_type_id': instance.exerciseTypeId,
      'photo_url': instance.photoUrl,
      'manual_url': instance.manualUrl,
      'is_active': instance.isActive,
    };
