import 'package:json_annotation/json_annotation.dart';
import 'package:postgres/postgres.dart'; // Import Time type

part 'work_schedule.g.dart';

@JsonSerializable()
class WorkSchedule {
  WorkSchedule({
    required this.id,
    required this.staffId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  factory WorkSchedule.fromJson(Map<String, dynamic> json) =>
      _$WorkScheduleFromJson(json);

  @JsonKey(name: 'id')
  final int id;
  @JsonKey(name: 'staff_id')
  final int staffId;
  @JsonKey(name: 'day_of_week')
  final int dayOfWeek;
  
  // Custom converter for TIME type from database to String
  @JsonKey(name: 'start_time', fromJson: _timeToString, toJson: _stringToTime)
  final String startTime;
  
  // Custom converter for TIME type from database to String
  @JsonKey(name: 'end_time', fromJson: _timeToString, toJson: _stringToTime)
  final String endTime;

  Map<String, dynamic> toJson() => _$WorkScheduleToJson(this);

  // Custom static methods for Time conversion
  static String _timeToString(dynamic value) {
    if (value is Time) {
      // Format Time object to HH:mm:ss string
      return '${value.hour.toString().padLeft(2, '0')}:'
             '${value.minute.toString().padLeft(2, '0')}:'
             '${value.second.toString().padLeft(2, '0')}';
    }
    if (value is String) {
        // If it's already a string, assume it's correctly formatted
        return value;
    }
    // Handle other types or throw an error if unexpected
    return value.toString(); // Fallback
  }

  static dynamic _stringToTime(String value) {
    // When saving to DB, convert String "HH:mm:ss" back to Time object
    // Or just pass the string if the DB driver handles it.
    // For now, assume DB driver expects Time object for TIME column
    final parts = value.split(':');
    return Time(
      int.parse(parts[0]),
      int.parse(parts[1]),
      parts.length > 2 ? int.parse(parts[2]) : 0,
    );
  }
}