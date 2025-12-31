import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'group_schedule_slot.g.dart';

@JsonSerializable()
class GroupScheduleSlot extends Equatable {
  final String id;
  final String groupId;
  final int dayOfWeek;          // 1-7 (понедельник-воскресенье)
  
  // Custom TimeOfDay converter for JSON serialization
  @JsonKey(fromJson: _timeOfDayFromJson, toJson: _timeOfDayToJson)
  final TimeOfDay startTime;

  @JsonKey(fromJson: _timeOfDayFromJson, toJson: _timeOfDayToJson)
  final TimeOfDay endTime;

  final bool isActive;

  const GroupScheduleSlot({
    required this.id,
    required this.groupId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.isActive = true,
  });

  factory GroupScheduleSlot.fromJson(Map<String, dynamic> json) => _$GroupScheduleSlotFromJson(json);
  Map<String, dynamic> toJson() => _$GroupScheduleSlotToJson(this);

  @override
  List<Object?> get props => [
        id,
        groupId,
        dayOfWeek,
        startTime,
        endTime,
        isActive,
      ];
}

// Helper class for TimeOfDay as it's not directly JSON serializable
class TimeOfDay extends Equatable {
  final int hour;
  final int minute;

  const TimeOfDay({required this.hour, required this.minute});

  factory TimeOfDay.fromJson(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String toJson() => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  @override
  List<Object?> get props => [hour, minute];
}

TimeOfDay _timeOfDayFromJson(String time) => TimeOfDay.fromJson(time);
String _timeOfDayToJson(TimeOfDay time) => time.toJson();
