import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'room_type.enum.dart';
import 'time_of_day_converter.dart';

part 'room.model.freezed.dart';
part 'room.model.g.dart';

// Custom converter for RoomType enum to/from int
class RoomTypeConverter implements JsonConverter<RoomType, int> {
  const RoomTypeConverter();

  @override
  RoomType fromJson(int json) {
    return RoomType.values.firstWhere((e) => e.value == json);
  }

  @override
  int toJson(RoomType object) {
    return object.value;
  }
}

@freezed
class Room with _$Room {
  const factory Room({
    required String id,
    required String name,
    String? description,
    @JsonKey(name: 'room_number') String? roomNumber,
    @RoomTypeConverter() required RoomType type,
    String? floor,
    @JsonKey(name: 'building_id') String? buildingId,
    String? buildingName,
    @JsonKey(name: 'max_capacity') @Default(30) int maxCapacity,
    double? area,
    @JsonKey(name: 'has_mirrors') @Default(false) bool hasMirrors,
    @JsonKey(name: 'has_sound_system') @Default(false) bool hasSoundSystem,
    @TimeOfDayConverter() @JsonKey(name: 'open_time') TimeOfDay? openTime,
    @TimeOfDayConverter() @JsonKey(name: 'close_time') TimeOfDay? closeTime,
    @JsonKey(name: 'working_days') @Default([]) List<int> workingDays,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'is_under_maintenance') @Default(false) bool isUnderMaintenance,
    @JsonKey(name: 'maintenance_note') String? maintenanceNote,
    @JsonKey(name: 'maintenance_until') DateTime? maintenanceUntil,
    @JsonKey(name: 'equipment_ids') @Default([]) List<String> equipmentIds,
    @JsonKey(name: 'photo_urls') @Default([]) List<String> photoUrls,
    @JsonKey(name: 'floor_plan_url') String? floorPlanUrl,
    String? note,
    @JsonKey(name: 'archived_at') DateTime? archivedAt,
  }) = _Room;

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);
}
