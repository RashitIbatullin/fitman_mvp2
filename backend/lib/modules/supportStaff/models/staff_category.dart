import 'package:json_annotation/json_annotation.dart';

enum StaffCategory {
  @JsonValue(0)
  technician,      // Техник/механик
  @JsonValue(1)
  cleaner,         // Уборщик
  @JsonValue(2)
  administrator,   // Администратор (вспомогательный)
  @JsonValue(3)
  security,        // Охрана
  @JsonValue(4)
  medical,         // Медицинский работник
  @JsonValue(5)
  itService,       // Айтишник
  @JsonValue(6)
  other            // Прочее
}