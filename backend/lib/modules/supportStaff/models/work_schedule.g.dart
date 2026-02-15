// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkSchedule _$WorkScheduleFromJson(Map<String, dynamic> json) => WorkSchedule(
  id: (json['id'] as num).toInt(),
  staffId: (json['staff_id'] as num).toInt(),
  dayOfWeek: (json['day_of_week'] as num).toInt(),
  startTime: WorkSchedule._timeToString(json['start_time']),
  endTime: WorkSchedule._timeToString(json['end_time']),
);

Map<String, dynamic> _$WorkScheduleToJson(WorkSchedule instance) =>
    <String, dynamic>{
      'id': instance.id,
      'staff_id': instance.staffId,
      'day_of_week': instance.dayOfWeek,
      'start_time': WorkSchedule._stringToTime(instance.startTime),
      'end_time': WorkSchedule._stringToTime(instance.endTime),
    };
