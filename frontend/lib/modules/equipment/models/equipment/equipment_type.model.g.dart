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
      'category': const EquipmentCategoryConverter().toJson(instance.category),
      'weightRange': instance.weightRange,
      'dimensions': instance.dimensions,
      'powerRequirements': instance.powerRequirements,
      'isMobile': instance.isMobile,
      'exerciseTypeId': instance.exerciseTypeId,
      'photoUrl': instance.photoUrl,
      'manualUrl': instance.manualUrl,
      'isActive': instance.isActive,
    };
