import 'dart:convert';
import 'package:fitman_backend/modules/equipment/models/equipment/equipment_status.enum.dart';

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

  factory EquipmentItem.fromMap(Map<String, dynamic> map) {
    final purchasePriceValue = map['purchase_price'];
    return EquipmentItem(
      id: map['id'].toString(),
      typeId: map['type_id'].toString(),
      inventoryNumber: map['inventory_number'] as String,
      serialNumber: map['serial_number'] as String?,
      model: map['model'] as String?,
      manufacturer: map['manufacturer'] as String?,
      roomId: map['room_id']?.toString(), // room_id can be null
      placementNote: map['placement_note'] as String?,
      status: EquipmentStatus.values[map['status'] as int],
      conditionRating: map['condition_rating'] as int,
      conditionNotes: map['condition_notes'] as String?,
      lastMaintenanceDate: map['last_maintenance_date'] as DateTime?,
      nextMaintenanceDate: map['next_maintenance_date'] as DateTime?,
      maintenanceNotes: map['maintenance_notes'] as String?,
      purchaseDate: map['purchase_date'] as DateTime?,
      purchasePrice: purchasePriceValue is String ? double.tryParse(purchasePriceValue) : (purchasePriceValue as num?)?.toDouble(),
      supplier: map['supplier'] as String?,
      warrantyMonths: map['warranty_months'] as int?,
      usageHours: map['usage_hours'] as int,
      lastUsedDate: map['last_used_date'] as DateTime?,
      photoUrls: (map['photo_urls'] is String
              ? (jsonDecode(map['photo_urls']) as List<dynamic>)
              : (map['photo_urls'] as List<dynamic>?))
          ?.map((e) => e.toString())
          .toList() ?? const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'typeId': typeId,
      'inventoryNumber': inventoryNumber,
      'serialNumber': serialNumber,
      'model': model,
      'manufacturer': manufacturer,
      'roomId': roomId,
      'placementNote': placementNote,
      'status': status.name,
      'conditionRating': conditionRating,
      'conditionNotes': conditionNotes,
      'lastMaintenanceDate': lastMaintenanceDate?.toIso8601String(),
      'nextMaintenanceDate': nextMaintenanceDate?.toIso8601String(),
      'maintenanceNotes': maintenanceNotes,
      'purchaseDate': purchaseDate?.toIso8601String(),
      'purchasePrice': purchasePrice,
      'supplier': supplier,
      'warrantyMonths': warrantyMonths,
      'usageHours': usageHours,
      'lastUsedDate': lastUsedDate?.toIso8601String(),
      'photoUrls': photoUrls,
    };
  }
}
