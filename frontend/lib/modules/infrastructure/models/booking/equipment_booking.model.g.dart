// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equipment_booking.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EquipmentBookingImpl _$$EquipmentBookingImplFromJson(
  Map<String, dynamic> json,
) => _$EquipmentBookingImpl(
  id: json['id'] as String,
  equipmentItemId: json['equipmentItemId'] as String,
  bookedById: json['bookedById'] as String,
  startTime: DateTime.parse(json['startTime'] as String),
  endTime: DateTime.parse(json['endTime'] as String),
  lessonId: json['lessonId'] as String?,
  trainingGroupId: json['trainingGroupId'] as String?,
  purpose: json['purpose'] as String,
  status: $enumDecode(_$BookingStatusEnumMap, json['status']),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$$EquipmentBookingImplToJson(
  _$EquipmentBookingImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'equipmentItemId': instance.equipmentItemId,
  'bookedById': instance.bookedById,
  'startTime': instance.startTime.toIso8601String(),
  'endTime': instance.endTime.toIso8601String(),
  'lessonId': instance.lessonId,
  'trainingGroupId': instance.trainingGroupId,
  'purpose': instance.purpose,
  'status': _$BookingStatusEnumMap[instance.status]!,
  'notes': instance.notes,
};

const _$BookingStatusEnumMap = {
  BookingStatus.confirmed: 'confirmed',
  BookingStatus.active: 'active',
  BookingStatus.completed: 'completed',
  BookingStatus.cancelled: 'cancelled',
};
