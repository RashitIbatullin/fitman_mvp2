// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_staff.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupportStaff _$SupportStaffFromJson(Map<String, dynamic> json) => SupportStaff(
  id: (json['id'] as num).toInt(),
  firstName: json['first_name'] as String,
  lastName: json['last_name'] as String,
  middleName: json['middle_name'] as String?,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  employmentType: $enumDecode(_$EmploymentTypeEnumMap, json['employment_type']),
  category: $enumDecode(_$StaffCategoryEnumMap, json['category']),
  competencies: (json['competencies'] as List<dynamic>?)
      ?.map((e) => Competency.fromJson(e as Map<String, dynamic>))
      .toList(),
  accessibleEquipmentTypes:
      (json['accessible_equipment_types'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
  canMaintainEquipment: json['can_maintain_equipment'] as bool,
  schedule: json['schedule'] == null
      ? null
      : WorkSchedule.fromJson(json['schedule'] as Map<String, dynamic>),
  companyName: json['company_name'] as String?,
  contractNumber: json['contract_number'] as String?,
  contractExpiryDate: json['contract_expiry_date'] == null
      ? null
      : DateTime.parse(json['contract_expiry_date'] as String),
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  archivedAt: json['archived_at'] == null
      ? null
      : DateTime.parse(json['archived_at'] as String),
  archivedBy: (json['archived_by'] as num?)?.toInt(),
  archivedReason: json['archived_reason'] as String?,
);

Map<String, dynamic> _$SupportStaffToJson(
  SupportStaff instance,
) => <String, dynamic>{
  'id': instance.id,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'middle_name': instance.middleName,
  'phone': instance.phone,
  'email': instance.email,
  'employment_type': _$EmploymentTypeEnumMap[instance.employmentType]!,
  'category': _$StaffCategoryEnumMap[instance.category]!,
  if (instance.competencies?.map((e) => e.toJson()).toList() case final value?)
    'competencies': value,
  'accessible_equipment_types': instance.accessibleEquipmentTypes,
  'can_maintain_equipment': instance.canMaintainEquipment,
  if (instance.schedule?.toJson() case final value?) 'schedule': value,
  'company_name': instance.companyName,
  'contract_number': instance.contractNumber,
  'contract_expiry_date': instance.contractExpiryDate?.toIso8601String(),
  'notes': instance.notes,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'archived_at': instance.archivedAt?.toIso8601String(),
  'archived_by': instance.archivedBy,
  'archived_reason': instance.archivedReason,
};

const _$EmploymentTypeEnumMap = {
  EmploymentType.fullTime: 0,
  EmploymentType.partTime: 1,
  EmploymentType.contractor: 2,
  EmploymentType.freelance: 3,
};

const _$StaffCategoryEnumMap = {
  StaffCategory.technician: 0,
  StaffCategory.cleaner: 1,
  StaffCategory.administrator: 2,
  StaffCategory.security: 3,
  StaffCategory.medical: 4,
  StaffCategory.itService: 5,
  StaffCategory.other: 6,
};
