import 'package:fitman_backend/config/database.dart';
import 'package:fitman_backend/modules/supportStaff/models/competency.dart';
import 'package:fitman_backend/modules/supportStaff/models/support_staff.dart';
import 'dart:convert';
import 'package:postgres/postgres.dart';
import 'package:fitman_backend/modules/supportStaff/models/work_schedule.dart';
import 'package:fitman_backend/modules/supportStaff/models/employment_type.dart';
import 'package:fitman_backend/modules/supportStaff/models/staff_category.dart';


abstract class SupportStaffRepository {
  Future<SupportStaff> getById(int id);
  Future<List<SupportStaff>> getAll({bool includeArchived = false});
  Future<SupportStaff> create(SupportStaff supportStaff, String userId);
  Future<SupportStaff> update(int id, SupportStaff supportStaff, String userId);
  Future<void> archive(int id, String userId, String reason);
  Future<void> unarchive(int id);
  Future<List<Competency>> getCompetencies(int staffId);
  Future<Competency> addCompetency(Competency competency);
  Future<void> deleteCompetency(int competencyId);
  Future<Competency> getCompetencyById(int id);
  Future<WorkSchedule?> getSchedule(int staffId);
  Future<WorkSchedule> updateSchedule(WorkSchedule schedule);
}

class SupportStaffRepositoryImpl implements SupportStaffRepository {
  SupportStaffRepositoryImpl(this._db);

  final Database _db;

  @override
  Future<void> archive(int id, String userId, String reason) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named(
          'UPDATE support_staff SET archived_at = NOW(), archived_by = @userId, archived_reason = @reason WHERE id = @id'),
      parameters: {
        'id': id,
        'userId': userId,
        'reason': reason,
      },
    );
  }

  @override
  Future<SupportStaff> create(SupportStaff supportStaff, String userId) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('''
        INSERT INTO support_staff (
          first_name, last_name, middle_name, phone, email, employment_type, category,
          can_maintain_equipment, accessible_equipment_types, company_name, contract_number,
          contract_expiry_date, notes, company_id, created_at, updated_at,
          created_by, updated_by
        ) VALUES (
          @firstName, @lastName, @middleName, @phone, @email, @employmentType, @category,
          @canMaintainEquipment, @accessibleEquipmentTypes, @companyName, @contractNumber,
          @contractExpiryDate, @notes, -1, NOW(), NOW(), @createdBy, @updatedBy
        ) RETURNING id;
      '''),
      parameters: {
        'firstName': supportStaff.firstName,
        'lastName': supportStaff.lastName,
        'middleName': supportStaff.middleName,
        'phone': supportStaff.phone,
        'email': supportStaff.email,
        'employmentType': supportStaff.employmentType.index,
        'category': supportStaff.category.index,
        'canMaintainEquipment': supportStaff.canMaintainEquipment,
        'accessibleEquipmentTypes': supportStaff.accessibleEquipmentTypes != null && supportStaff.accessibleEquipmentTypes!.isNotEmpty
          ? jsonEncode(supportStaff.accessibleEquipmentTypes)
          : null,
        'companyName': supportStaff.companyName,
        'contractNumber': supportStaff.contractNumber,
        'contractExpiryDate': supportStaff.contractExpiryDate?.toIso8601String().split('T')[0],
        'notes': supportStaff.notes,
        'createdBy': userId,
        'updatedBy': userId,
      },
    );

    final newId = result.first.first as int;
    return await getById(newId);
  }

  @override
  Future<List<SupportStaff>> getAll({bool includeArchived = false}) async {
    final conn = await _db.connection;
    final whereClause = includeArchived ? '' : 'WHERE archived_at IS NULL';
    final result = await conn.execute(
        Sql.named('SELECT * FROM support_staff $whereClause ORDER BY last_name, first_name ASC'));

    final staffList = <SupportStaff>[];
    for (final row in result) {
      final staffData = row.toColumnMap();
      final staffId = staffData['id'] as int;
      final competencies = await getCompetencies(staffId);
      final schedule = await getSchedule(staffId);

      // Create a new SupportStaff object with all fetched data
      staffList.add(
        SupportStaff(
          id: staffData['id'] as int,
          firstName: staffData['first_name'] as String,
          lastName: staffData['last_name'] as String,
          middleName: staffData['middle_name'] as String?,
          phone: staffData['phone'] as String?,
          email: staffData['email'] as String?,
          employmentType: EmploymentType.values[staffData['employment_type'] as int],
          category: StaffCategory.values[staffData['category'] as int],
          canMaintainEquipment: staffData['can_maintain_equipment'] as bool,
          accessibleEquipmentTypes: (staffData['accessible_equipment_types'] != null && staffData['accessible_equipment_types'] is String)
            ? (jsonDecode(staffData['accessible_equipment_types']) as List<dynamic>).cast<String>()
            : (staffData['accessible_equipment_types'] as List<dynamic>?)?.cast<String>(),
          companyName: staffData['company_name'] as String?,
          contractNumber: staffData['contract_number'] as String?,
          contractExpiryDate: (staffData['contract_expiry_date'] as DateTime?)?.toLocal(),
          notes: staffData['notes'] as String?,
          createdAt: (staffData['created_at'] as DateTime).toLocal(),
          updatedAt: (staffData['updated_at'] as DateTime).toLocal(),
          archivedAt: (staffData['archived_at'] as DateTime?)?.toLocal(),
          archivedBy: staffData['archived_by'] as int?,
          archivedReason: staffData['archived_reason'] as String?,
          competencies: competencies, // Add fetched competencies
          schedule: schedule, // Add fetched schedule
        ),
      );
    }
    return staffList;
  }

  @override
  Future<SupportStaff> getById(int id) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('SELECT * FROM support_staff WHERE id = @id'),
      parameters: {'id': id},
    );

    if (result.isEmpty) {
      throw Exception('SupportStaff with id $id not found');
    }

    final staffData = result.first.toColumnMap();
    final staffId = staffData['id'] as int;
    final competencies = await getCompetencies(staffId);
    final schedule = await getSchedule(staffId);

    return SupportStaff(
      id: staffData['id'] as int,
      firstName: staffData['first_name'] as String,
      lastName: staffData['last_name'] as String,
      middleName: staffData['middle_name'] as String?,
      phone: staffData['phone'] as String?,
      email: staffData['email'] as String?,
      employmentType: EmploymentType.values[staffData['employment_type'] as int],
      category: StaffCategory.values[staffData['category'] as int],
      canMaintainEquipment: staffData['can_maintain_equipment'] as bool,
      accessibleEquipmentTypes: (staffData['accessible_equipment_types'] != null && staffData['accessible_equipment_types'] is String)
        ? (jsonDecode(staffData['accessible_equipment_types']) as List<dynamic>).cast<String>()
        : (staffData['accessible_equipment_types'] as List<dynamic>?)?.cast<String>(),
      companyName: staffData['company_name'] as String?,
      contractNumber: staffData['contract_number'] as String?,
      contractExpiryDate: (staffData['contract_expiry_date'] as DateTime?)?.toLocal(),
      notes: staffData['notes'] as String?,
      createdAt: (staffData['created_at'] as DateTime).toLocal(),
      updatedAt: (staffData['updated_at'] as DateTime).toLocal(),
      archivedAt: (staffData['archived_at'] as DateTime?)?.toLocal(),
      archivedBy: staffData['archived_by'] as int?,
      archivedReason: staffData['archived_reason'] as String?,
      competencies: competencies,
      schedule: schedule,
    );
  }

  @override
  Future<void> unarchive(int id) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named(
          'UPDATE support_staff SET archived_at = NULL, archived_by = NULL, archived_reason = NULL WHERE id = @id'),
      parameters: {'id': id},
    );
  }

  @override
  Future<SupportStaff> update(int id, SupportStaff supportStaff, String userId) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named('''
        UPDATE support_staff SET
          first_name = @firstName,
          last_name = @lastName,
          middle_name = @middleName,
          phone = @phone,
          email = @email,
          employment_type = @employmentType,
          category = @category,
          can_maintain_equipment = @canMaintainEquipment,
          accessible_equipment_types = @accessibleEquipmentTypes,
          company_name = @companyName,
          contract_number = @contractNumber,
          contract_expiry_date = @contractExpiryDate,
          notes = @notes,
          updated_at = NOW(),
          updated_by = @updatedBy
        WHERE id = @id;
      '''),
      parameters: {
        'id': id,
        'firstName': supportStaff.firstName,
        'lastName': supportStaff.lastName,
        'middleName': supportStaff.middleName,
        'phone': supportStaff.phone,
        'email': supportStaff.email,
        'employmentType': supportStaff.employmentType.index,
        'category': supportStaff.category.index,
        'canMaintainEquipment': supportStaff.canMaintainEquipment,
        'accessibleEquipmentTypes': supportStaff.accessibleEquipmentTypes != null && supportStaff.accessibleEquipmentTypes!.isNotEmpty
          ? jsonEncode(supportStaff.accessibleEquipmentTypes)
          : null,
        'companyName': supportStaff.companyName,
        'contractNumber': supportStaff.contractNumber,
        'contractExpiryDate': supportStaff.contractExpiryDate?.toIso8601String().split('T')[0],
        'notes': supportStaff.notes,
        'updatedBy': userId,
      },
    );
    return await getById(id);
  }

  @override
  Future<Competency> addCompetency(Competency competency) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('''
        INSERT INTO support_staff_competencies (
          staff_id, name, level, certificate_url, verified_at, verified_by
        ) VALUES (
          @staffId, @name, @level, @certificateUrl, @verifiedAt, @verifiedBy
        ) RETURNING id;
      '''),
      parameters: {
        'staffId': competency.staffId,
        'name': competency.name,
        'level': competency.level,
        'certificateUrl': competency.certificateUrl,
        'verifiedAt': competency.verifiedAt,
        'verifiedBy': competency.verifiedBy,
      },
    );
    final newId = result.first.first as int;
    return await getCompetencyById(newId);
  }

  @override
  Future<void> deleteCompetency(int competencyId) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named('DELETE FROM support_staff_competencies WHERE id = @id'),
      parameters: {'id': competencyId},
    );
  }

  @override
  Future<List<Competency>> getCompetencies(int staffId) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('SELECT * FROM support_staff_competencies WHERE staff_id = @staffId'),
      parameters: {'staffId': staffId},
    );
    return result.map((row) => Competency.fromJson(row.toColumnMap())).toList();
  }

  @override
  Future<WorkSchedule?> getSchedule(int staffId) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('SELECT * FROM support_staff_schedules WHERE staff_id = @staffId'),
      parameters: {'staffId': staffId},
    );
    if (result.isEmpty) {
      return null;
    }
    return WorkSchedule.fromJson(result.first.toColumnMap());
  }

  @override
  Future<WorkSchedule> updateSchedule(WorkSchedule schedule) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named('''
        INSERT INTO support_staff_schedules (
          staff_id, day_of_week, start_time, end_time
        ) VALUES (
          @staffId, @dayOfWeek, @startTime, @endTime
        ) ON CONFLICT (staff_id, day_of_week) DO UPDATE SET
          start_time = @startTime,
          end_time = @endTime;
      '''),
      parameters: {
        'staffId': schedule.staffId,
        'dayOfWeek': schedule.dayOfWeek,
        'startTime': schedule.startTime,
        'endTime': schedule.endTime,
      },
    );
    return schedule;
  }

  @override
  Future<Competency> getCompetencyById(int id) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('SELECT * FROM support_staff_competencies WHERE id = @id'),
      parameters: {'id': id},
    );

    if (result.isEmpty) {
      throw Exception('Competency with id $id not found');
    }

    return Competency.fromJson(result.first.toColumnMap());
  }
}