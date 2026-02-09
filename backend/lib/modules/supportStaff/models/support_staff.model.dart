import 'package:fitman_backend/modules/supportStaff/models/competency.model.dart';
import 'package:fitman_backend/modules/supportStaff/models/employment_type.enum.dart';
import 'package:fitman_backend/modules/supportStaff/models/staff_category.enum.dart';
import 'package:fitman_backend/modules/supportStaff/models/work_schedule.model.dart';

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
    required this.isActive,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String? middleName;
  final String? phone;
  final String? email;
  final EmploymentType employmentType;
  final StaffCategory category;
  final List<Competency>? competencies;
  final List<String>? accessibleEquipmentTypes;
  final bool canMaintainEquipment;
  final WorkSchedule? schedule;
  final String? companyName;
  final String? contractNumber;
  final DateTime? contractExpiryDate;
  final bool isActive;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory SupportStaff.fromMap(Map<String, dynamic> map) {
    return SupportStaff(
      id: map['id'].toString(),
      firstName: map['first_name'] as String,
      lastName: map['last_name'] as String,
      middleName: map['middle_name'] as String?,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      employmentType: EmploymentType.values[map['employment_type'] as int],
      category: StaffCategory.values[map['category'] as int],
      canMaintainEquipment: map['can_maintain_equipment'] as bool,
      accessibleEquipmentTypes: (map['accessible_equipment_types'] as List<dynamic>?)?.cast<String>(),
      companyName: map['company_name'] as String?,
      contractNumber: map['contract_number'] as String?,
      contractExpiryDate: map['contract_expiry_date'] as DateTime?,
      isActive: map['is_active'] as bool,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] as DateTime,
      updatedAt: map['updated_at'] as DateTime,
      // competencies and schedule will be loaded separately
    );
  }

  SupportStaff copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? middleName,
    String? phone,
    String? email,
    EmploymentType? employmentType,
    StaffCategory? category,
    List<Competency>? competencies,
    List<String>? accessibleEquipmentTypes,
    bool? canMaintainEquipment,
    WorkSchedule? schedule,
    String? companyName,
    String? contractNumber,
    DateTime? contractExpiryDate,
    bool? isActive,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SupportStaff(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      middleName: middleName ?? this.middleName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      employmentType: employmentType ?? this.employmentType,
      category: category ?? this.category,
      competencies: competencies ?? this.competencies,
      accessibleEquipmentTypes: accessibleEquipmentTypes ?? this.accessibleEquipmentTypes,
      canMaintainEquipment: canMaintainEquipment ?? this.canMaintainEquipment,
      schedule: schedule ?? this.schedule,
      companyName: companyName ?? this.companyName,
      contractNumber: contractNumber ?? this.contractNumber,
      contractExpiryDate: contractExpiryDate ?? this.contractExpiryDate,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'middle_name': middleName,
      'phone': phone,
      'email': email,
      'employment_type': employmentType.name,
      'category': category.name,
      'can_maintain_equipment': canMaintainEquipment,
      'accessible_equipment_types': accessibleEquipmentTypes,
      'company_name': companyName,
      'contract_number': contractNumber,
      'contract_expiry_date': contractExpiryDate?.toIso8601String(),
      'is_active': isActive,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'competencies': competencies?.map((c) => c.toJson()).toList(),
      'schedule': schedule?.toJson(),
    };
  }
}
