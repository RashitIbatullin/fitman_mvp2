import 'package:json_annotation/json_annotation.dart';
import 'package:fitman_backend/modules/supportStaff/models/competency.dart'; // Updated import
import 'package:fitman_backend/modules/supportStaff/models/employment_type.dart'; // Updated import
import 'package:fitman_backend/modules/supportStaff/models/staff_category.dart'; // Updated import
import 'package:fitman_backend/modules/supportStaff/models/work_schedule.dart'; // Updated import

part 'support_staff.g.dart';

@JsonSerializable(explicitToJson: true) // explicitToJson for nested objects
class SupportStaff {
  SupportStaff({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.middleName,
    this.phone,
    this.email,
    required this.employmentType,
    required this.category,
    this.competencies,
    this.accessibleEquipmentTypes,
    required this.canMaintainEquipment,
    this.schedule,
    this.companyName,
    this.contractNumber,
    this.contractExpiryDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
    this.archivedBy,
    this.archivedReason,
  });

  factory SupportStaff.fromJson(Map<String, dynamic> json) =>
      _$SupportStaffFromJson(json);

  @JsonKey(name: 'id')
  final int id;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  @JsonKey(name: 'middle_name')
  final String? middleName;
  @JsonKey(name: 'phone')
  final String? phone;
  @JsonKey(name: 'email')
  final String? email;
  @JsonKey(name: 'employment_type')
  final EmploymentType employmentType;
  @JsonKey(name: 'category')
  final StaffCategory category;
  // Competencies are fetched separately from the main staff object,
  // so we mark them as nullable.
  @JsonKey(name: 'competencies', includeIfNull: false)
  final List<Competency>? competencies;
  @JsonKey(name: 'accessible_equipment_types')
  // accessible_equipment_types is JSONB in SQL, handled as List<String>
  final List<String>? accessibleEquipmentTypes;
  @JsonKey(name: 'can_maintain_equipment')
  final bool canMaintainEquipment;
  // Schedule is fetched separately, so we mark it as nullable.
  @JsonKey(name: 'schedule', includeIfNull: false)
  final WorkSchedule? schedule;
  @JsonKey(name: 'company_name')
  final String? companyName;
  @JsonKey(name: 'contract_number')
  final String? contractNumber;
  @JsonKey(name: 'contract_expiry_date')
  final DateTime? contractExpiryDate;
  @JsonKey(name: 'notes')
  final String? notes;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'archived_at')
  final DateTime? archivedAt;
  @JsonKey(name: 'archived_by')
  final int? archivedBy; // FK to users(id), can be null
  @JsonKey(name: 'archived_reason')
  final String? archivedReason;

  Map<String, dynamic> toJson() => _$SupportStaffToJson(this);
}