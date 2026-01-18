import 'package:flutter/material.dart';

enum EquipmentStatus {
  available, // Доступно
  inUse, // Используется (во время занятия)
  reserved, // Забронировано
  maintenance, // На обслуживании/ремонте
  outOfOrder, // Неисправно
  storage, // На складе
}

extension EquipmentStatusExtension on EquipmentStatus {
  String get displayName {
    switch (this) {
      case EquipmentStatus.available:
        return 'Доступно';
      case EquipmentStatus.inUse:
        return 'В использовании';
      case EquipmentStatus.reserved:
        return 'Забронировано';
      case EquipmentStatus.maintenance:
        return 'На ТО';
      case EquipmentStatus.outOfOrder:
        return 'Неисправно';
      case EquipmentStatus.storage:
        return 'На складе';
    }
  }

  Color get color {
    switch (this) {
      case EquipmentStatus.available:
        return Colors.green;
      case EquipmentStatus.inUse:
        return Colors.blue;
      case EquipmentStatus.reserved:
        return Colors.orange;
      case EquipmentStatus.maintenance:
        return Colors.purple;
      case EquipmentStatus.outOfOrder:
        return Colors.red;
      case EquipmentStatus.storage:
        return Colors.grey;
    }
  }
}
