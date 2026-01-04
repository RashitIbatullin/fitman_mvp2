import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'room_type.enum.dart';
import 'time_of_day_converter.dart';

part 'room.model.freezed.dart';
part 'room.model.g.dart';

@freezed
class Room with _$Room {
  const factory Room({
    required String id,
    required String name,
    String? description,
    required RoomType type,
    String? floor,
    String? building,
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
