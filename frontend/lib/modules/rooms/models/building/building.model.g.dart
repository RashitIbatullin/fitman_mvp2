// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'building.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BuildingImpl _$$BuildingImplFromJson(Map<String, dynamic> json) =>
    _$BuildingImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      note: json['note'] as String?,
      archivedAt: const NullableDateTimeConverter().fromJson(
        json['archivedAt'] as String?,
      ),
    );

Map<String, dynamic> _$$BuildingImplToJson(
  _$BuildingImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'address': instance.address,
  'note': instance.note,
  'archivedAt': const NullableDateTimeConverter().toJson(instance.archivedAt),
};
