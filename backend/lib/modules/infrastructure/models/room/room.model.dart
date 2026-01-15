import 'dart:convert';
import 'package:postgres/postgres.dart';
import 'package:fitman_backend/modules/infrastructure/models/room/room_type.enum.dart';

class Room {
  const Room({
    this.id,
    required this.name,
    this.description,
    required this.type,
    this.floor,
    this.building,
    required this.maxCapacity,
    this.area,
    this.hasMirrors = false,
    this.hasSoundSystem = false,
    this.openTime,
    this.closeTime,
    this.workingDays = const [],
    this.isActive = true,
    this.isUnderMaintenance = false,
    this.maintenanceNote,
    this.maintenanceUntil,
    this.equipmentIds = const [],
    this.photoUrls = const [],
    this.floorPlanUrl,
    this.note,
  });

  final String? id;
  final String name;
  final String? description;
  final RoomType type;

  // Локация
  final String? floor;
  final String? building;

  // Вместимость и параметры
  final int maxCapacity;
  final double? area;
  final bool hasMirrors;
  final bool hasSoundSystem;

  // Расписание доступности
  final String? openTime;
  final String? closeTime;
  final List<int> workingDays;

  // Статус
  final bool isActive;
  final bool isUnderMaintenance;
  final String? maintenanceNote;
  final DateTime? maintenanceUntil;

  // Оборудование в помещении
  final List<String> equipmentIds;

  // Фотографии
  final List<String> photoUrls;
  final String? floorPlanUrl;
  final String? note;

  factory Room.fromMap(Map<String, dynamic> map) {
    final areaValue = map['area'];
    final openTimeValue = map['open_time'];
    final closeTimeValue = map['close_time'];

    return Room(
      id: map['id'].toString(),
      name: map['name'] as String,
      description: map['description'] as String?,
      type: RoomType.values.firstWhere((e) => e.value == map['type'] as int),
      floor: map['floor'] as String?,
      building: map['building'] as String?,
      maxCapacity: map['max_capacity'] as int,
      area: areaValue is String ? double.tryParse(areaValue) : (areaValue as num?)?.toDouble(),
      hasMirrors: map['has_mirrors'] as bool,
      hasSoundSystem: map['has_sound_system'] as bool,
      openTime: openTimeValue is Time ? openTimeValue.toString() : openTimeValue as String?,
      closeTime: closeTimeValue is Time ? closeTimeValue.toString() : closeTimeValue as String?,
      workingDays: (map['working_days'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
      isActive: map['is_active'] as bool,
      isUnderMaintenance: map['is_under_maintenance'] as bool,
      maintenanceNote: map['maintenance_note'] as String?,
      maintenanceUntil: map['maintenance_until'] as DateTime?,
      equipmentIds: const [], 
      photoUrls: (map['photo_urls'] is String
              ? (jsonDecode(map['photo_urls']) as List<dynamic>)
              : (map['photo_urls'] as List<dynamic>?))
          ?.map((e) => e.toString())
          .toList() ?? const [],
      floorPlanUrl: map['floor_plan_url'] as String?,
      note: map['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.value, // Convert enum to int value
      'floor': floor,
      'building': building,
      'maxCapacity': maxCapacity,
      'area': area,
      'hasMirrors': hasMirrors,
      'hasSoundSystem': hasSoundSystem,
      'openTime': openTime,
      'closeTime': closeTime,
      'workingDays': workingDays,
      'isActive': isActive,
      'isUnderMaintenance': isUnderMaintenance,
      'maintenanceNote': maintenanceNote,
      'maintenanceUntil': maintenanceUntil?.toIso8601String(),
      'equipmentIds': equipmentIds,
      'photoUrls': photoUrls,
      'floorPlanUrl': floorPlanUrl,
      'note': note,
    };
  }
}
