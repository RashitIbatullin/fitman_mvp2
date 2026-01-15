// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RoomImpl _$$RoomImplFromJson(Map<String, dynamic> json) => _$RoomImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  roomNumber: json['room_number'] as String?,
  type: const RoomTypeConverter().fromJson((json['type'] as num).toInt()),
  floor: json['floor'] as String?,
  buildingId: json['building_id'] as String?,
  buildingName: json['buildingName'] as String?,
  maxCapacity: (json['max_capacity'] as num?)?.toInt() ?? 30,
  area: (json['area'] as num?)?.toDouble(),
  hasMirrors: json['has_mirrors'] as bool? ?? false,
  hasSoundSystem: json['has_sound_system'] as bool? ?? false,
  openTime: const TimeOfDayConverter().fromJson(json['open_time'] as String?),
  closeTime: const TimeOfDayConverter().fromJson(json['close_time'] as String?),
  workingDays:
      (json['working_days'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
  isActive: json['is_active'] as bool? ?? true,
  isUnderMaintenance: json['is_under_maintenance'] as bool? ?? false,
  maintenanceNote: json['maintenance_note'] as String?,
  maintenanceUntil: json['maintenance_until'] == null
      ? null
      : DateTime.parse(json['maintenance_until'] as String),
  equipmentIds:
      (json['equipment_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  photoUrls:
      (json['photo_urls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  floorPlanUrl: json['floor_plan_url'] as String?,
  note: json['note'] as String?,
  archivedAt: json['archived_at'] == null
      ? null
      : DateTime.parse(json['archived_at'] as String),
);

Map<String, dynamic> _$$RoomImplToJson(_$RoomImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'room_number': instance.roomNumber,
      'type': const RoomTypeConverter().toJson(instance.type),
      'floor': instance.floor,
      'building_id': instance.buildingId,
      'buildingName': instance.buildingName,
      'max_capacity': instance.maxCapacity,
      'area': instance.area,
      'has_mirrors': instance.hasMirrors,
      'has_sound_system': instance.hasSoundSystem,
      'open_time': const TimeOfDayConverter().toJson(instance.openTime),
      'close_time': const TimeOfDayConverter().toJson(instance.closeTime),
      'working_days': instance.workingDays,
      'is_active': instance.isActive,
      'is_under_maintenance': instance.isUnderMaintenance,
      'maintenance_note': instance.maintenanceNote,
      'maintenance_until': instance.maintenanceUntil?.toIso8601String(),
      'equipment_ids': instance.equipmentIds,
      'photo_urls': instance.photoUrls,
      'floor_plan_url': instance.floorPlanUrl,
      'note': instance.note,
      'archived_at': instance.archivedAt?.toIso8601String(),
    };
