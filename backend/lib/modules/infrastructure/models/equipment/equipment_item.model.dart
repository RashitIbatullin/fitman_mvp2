import 'package:fitman_backend/modules/infrastructure/models/equipment/equipment_status.enum.dart';

class EquipmentItem {
  EquipmentItem({
    required this.id,
    required this.typeId,
    required this.inventoryNumber,
    this.serialNumber,
    this.model,
    this.manufacturer,
    this.roomId,
    this.placementNote,
    required this.status,
    required this.conditionRating,
    this.conditionNotes,
    this.lastMaintenanceDate,
    this.nextMaintenanceDate,
    this.maintenanceNotes,
    this.purchaseDate,
    this.purchasePrice,
    this.supplier,
    this.warrantyMonths,
    this.usageHours = 0,
    this.lastUsedDate,
    this.photoUrls = const [],
  });

  final String id;
  final String typeId;
  final String inventoryNumber;
  final String? serialNumber;
  final String? model;
  final String? manufacturer;

  // Локация
  final String? roomId;
  final String? placementNote;

  // Состояние
  final EquipmentStatus status;
  final int conditionRating;
  final String? conditionNotes;

  // Техническое обслуживание
  final DateTime? lastMaintenanceDate;
  final DateTime? nextMaintenanceDate;
  final String? maintenanceNotes;

  // Покупка/учёт
  final DateTime? purchaseDate;
  final double? purchasePrice;
  final String? supplier;
  final int? warrantyMonths;

  // Использование
  final int usageHours;
  final DateTime? lastUsedDate;

  // Фотографии
  final List<String> photoUrls;
}
