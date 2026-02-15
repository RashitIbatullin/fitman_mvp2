// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'competency.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Competency _$CompetencyFromJson(Map<String, dynamic> json) => Competency(
  id: (json['id'] as num).toInt(),
  staffId: (json['staff_id'] as num).toInt(),
  name: json['name'] as String,
  level: (json['level'] as num).toInt(),
  certificateUrl: json['certificate_url'] as String?,
  verifiedAt: Competency._dateTimeFromDb(json['verified_at']),
  verifiedBy: (json['verified_by'] as num?)?.toInt(),
);

Map<String, dynamic> _$CompetencyToJson(Competency instance) =>
    <String, dynamic>{
      'id': instance.id,
      'staff_id': instance.staffId,
      'name': instance.name,
      'level': instance.level,
      'certificate_url': instance.certificateUrl,
      'verified_at': Competency._dateTimeToDb(instance.verifiedAt),
      'verified_by': instance.verifiedBy,
    };
