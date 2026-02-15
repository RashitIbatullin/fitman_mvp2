import 'package:json_annotation/json_annotation.dart';

enum EmploymentType {
  @JsonValue(0)
  fullTime,    // Штатный сотрудник
  @JsonValue(1)
  partTime,    // Частичная занятость
  @JsonValue(2)
  contractor,  // Внешний подрядчик
  @JsonValue(3)
  freelance    // Разовые работы
}