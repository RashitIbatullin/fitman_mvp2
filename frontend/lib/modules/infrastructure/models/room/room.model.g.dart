// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RoomImpl _$$RoomImplFromJson(Map<String, dynamic> json) => _$RoomImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  type: const RoomTypeConverter().fromJson((json['type'] as num).toInt()),
  floor: json['floor'] as String?,
  buildingId: json['buildingId'] as String?,
  maxCapacity: (json['maxCapacity'] as num).toInt(),
  area: (json['area'] as num?)?.toDouble(),
  hasMirrors: json['hasMirrors'] as bool? ?? false,
  hasSoundSystem: json['hasSoundSystem'] as bool? ?? false,
  openTime: const TimeOfDayConverter().fromJson(json['openTime'] as String?),
  closeTime: const TimeOfDayConverter().fromJson(json['closeTime'] as String?),
  workingDays:
      (json['workingDays'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
  isActive: json['isActive'] as bool? ?? true,
  isUnderMaintenance: json['isUnderMaintenance'] as bool? ?? false,
  maintenanceNote: json['maintenanceNote'] as String?,
  maintenanceUntil: json['maintenanceUntil'] == null
      ? null
      : DateTime.parse(json['maintenanceUntil'] as String),
  equipmentIds:
      (json['equipmentIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  photoUrls:
      (json['photoUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  floorPlanUrl: json['floorPlanUrl'] as String?,
  note: json['note'] as String?,
);

Map<String, dynamic> _$$RoomImplToJson(_$RoomImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': const RoomTypeConverter().toJson(instance.type),
      'floor': instance.floor,
      'buildingId': instance.buildingId,
      'maxCapacity': instance.maxCapacity,
      'area': instance.area,
      'hasMirrors': instance.hasMirrors,
      'hasSoundSystem': instance.hasSoundSystem,
      'openTime': const TimeOfDayConverter().toJson(instance.openTime),
      'closeTime': const TimeOfDayConverter().toJson(instance.closeTime),
      'workingDays': instance.workingDays,
      'isActive': instance.isActive,
      'isUnderMaintenance': instance.isUnderMaintenance,
      'maintenanceNote': instance.maintenanceNote,
      'maintenanceUntil': instance.maintenanceUntil?.toIso8601String(),
      'equipmentIds': instance.equipmentIds,
      'photoUrls': instance.photoUrls,
      'floorPlanUrl': instance.floorPlanUrl,
      'note': instance.note,
    };
