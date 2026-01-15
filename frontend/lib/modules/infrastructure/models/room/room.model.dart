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
    @RoomTypeConverter() required RoomType type,
    String? floor,
    String? buildingId,
    
    // Вместимость и параметры
    required int maxCapacity,
    double? area,
    @Default(false) bool hasMirrors,
    @Default(false) bool hasSoundSystem,
    @TimeOfDayConverter() TimeOfDay? openTime,
    @TimeOfDayConverter() TimeOfDay? closeTime,
    @Default([]) List<int> workingDays,
    @Default(true) bool isActive,
    @Default(false) bool isUnderMaintenance,
    String? maintenanceNote,
    DateTime? maintenanceUntil,
    @Default([]) List<String> equipmentIds,
    @Default([]) List<String> photoUrls,
    String? floorPlanUrl,
    String? note,
  }) = _Room;

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);
}
