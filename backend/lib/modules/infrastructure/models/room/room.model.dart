import 'package:fitman_backend/modules/infrastructure/models/room/room_type.enum.dart';

class Room {
  Room({
    required this.id,
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

  final String id;
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
}
