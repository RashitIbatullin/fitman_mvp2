import 'package:postgres/postgres.dart';
import '../config/database.dart';
import '../models/groups/analytic_group.dart';
import '../models/groups/group_schedule_slot.dart';
import '../models/groups/training_group.dart';

class GroupRepository {
  final Database _db;

  GroupRepository(this._db);

  // --- Training Group Methods ---

  Future<List<TrainingGroup>> getAllTrainingGroups() async {
    final conn = await _db.connection;
    final results = await conn.execute('SELECT * FROM training_groups WHERE archived_at IS NULL');
    return results.map((row) => TrainingGroup.fromJson(row.toColumnMap())).toList();
  }

  Future<TrainingGroup?> getTrainingGroupById(String id) async {
    final conn = await _db.connection;
    final results = await conn.execute(
      Sql.named('SELECT * FROM training_groups WHERE id = @id AND archived_at IS NULL'),
      parameters: {'id': int.parse(id)},
    );
    if (results.isEmpty) return null;
    return TrainingGroup.fromJson(results.first.toColumnMap());
  }

  Future<TrainingGroup> createTrainingGroup(TrainingGroup group, int creatorId) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('''
        INSERT INTO training_groups (
          name, description, primary_trainer_id, primary_instructor_id,
          responsible_manager_id, program_id, goal_id, level_id,
          max_participants, current_participants, start_date, end_date,
          is_active, chat_id, company_id, created_by, updated_by
        )
        VALUES (
          @name, @description, @primary_trainer_id, @primary_instructor_id,
          @responsible_manager_id, @program_id, @goal_id, @level_id,
          @max_participants, @current_participants, @start_date, @end_date,
          @is_active, @chat_id, @company_id, @created_by, @updated_by
        )
        RETURNING *
      '''),
      parameters: {
        'name': group.name,
        'description': group.description,
        'primary_trainer_id': int.parse(group.primaryTrainerId),
        'primary_instructor_id': group.primaryInstructorId != null ? int.parse(group.primaryInstructorId!) : null,
        'responsible_manager_id': group.responsibleManagerId != null ? int.parse(group.responsibleManagerId!) : null,
        'program_id': group.programId != null ? int.parse(group.programId!) : null,
        'goal_id': group.goalId != null ? int.parse(group.goalId!) : null,
        'level_id': group.levelId != null ? int.parse(group.levelId!) : null,
        'max_participants': group.maxParticipants,
        'current_participants': group.currentParticipants,
        'start_date': group.startDate,
        'end_date': group.endDate,
        'is_active': group.isActive,
        'chat_id': group.chatId != null ? int.parse(group.chatId!) : null,
        'company_id': -1, // Assuming default company_id for now
        'created_by': creatorId,
        'updated_by': creatorId,
      },
    );
    return TrainingGroup.fromJson(result.first.toColumnMap());
  }

  Future<TrainingGroup> updateTrainingGroup(TrainingGroup group, int updaterId) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('''
        UPDATE training_groups
        SET
          name = @name,
          description = @description,
          primary_trainer_id = @primary_trainer_id,
          primary_instructor_id = @primary_instructor_id,
          responsible_manager_id = @responsible_manager_id,
          program_id = @program_id,
          goal_id = @goal_id,
          level_id = @level_id,
          max_participants = @max_participants,
          current_participants = @current_participants,
          start_date = @start_date,
          end_date = @end_date,
          is_active = @is_active,
          chat_id = @chat_id,
          updated_by = @updated_by,
          updated_at = NOW()
        WHERE id = @id
        RETURNING *
      '''),
      parameters: {
        'id': int.parse(group.id),
        'name': group.name,
        'description': group.description,
        'primary_trainer_id': int.parse(group.primaryTrainerId),
        'primary_instructor_id': group.primaryInstructorId != null ? int.parse(group.primaryInstructorId!) : null,
        'responsible_manager_id': group.responsibleManagerId != null ? int.parse(group.responsibleManagerId!) : null,
        'program_id': group.programId != null ? int.parse(group.programId!) : null,
        'goal_id': group.goalId != null ? int.parse(group.goalId!) : null,
        'level_id': group.levelId != null ? int.parse(group.levelId!) : null,
        'max_participants': group.maxParticipants,
        'current_participants': group.currentParticipants,
        'start_date': group.startDate,
        'end_date': group.endDate,
        'is_active': group.isActive,
        'chat_id': group.chatId != null ? int.parse(group.chatId!) : null,
        'updated_by': updaterId,
      },
    );
    return TrainingGroup.fromJson(result.first.toColumnMap());
  }

  Future<void> deleteTrainingGroup(String id, int archiverId) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named('''
        UPDATE training_groups
        SET archived_at = NOW(), archived_by = @archiverId
        WHERE id = @id
      '''),
      parameters: {'id': int.parse(id), 'archiverId': archiverId},
    );
  }

  // --- Analytic Group Methods ---

  // --- Analytic Group Methods ---

  Future<List<AnalyticGroup>> getAllAnalyticGroups() async {
    final conn = await _db.connection;
    final results = await conn.execute('SELECT * FROM analytic_groups WHERE archived_at IS NULL');
    return results.map((row) => AnalyticGroup.fromJson(row.toColumnMap())).toList();
  }

  Future<AnalyticGroup?> getAnalyticGroupById(String id) async {
    final conn = await _db.connection;
    final results = await conn.execute(
      Sql.named('SELECT * FROM analytic_groups WHERE id = @id AND archived_at IS NULL'),
      parameters: {'id': int.parse(id)},
    );
    if (results.isEmpty) return null;
    return AnalyticGroup.fromJson(results.first.toColumnMap());
  }

  Future<AnalyticGroup> createAnalyticGroup(AnalyticGroup group, int creatorId) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('''
        INSERT INTO analytic_groups (
          name, description, type, is_auto_update, conditions, metadata,
          client_ids_cache, last_updated_at, company_id, created_by, updated_by
        )
        VALUES (
          @name, @description, @type, @is_auto_update, @conditions, @metadata,
          @client_ids_cache, @last_updated_at, @company_id, @created_by, @updated_by
        )
        RETURNING *
      '''),
      parameters: {
        'name': group.name,
        'description': group.description,
        'type': group.type.index,
        'is_auto_update': group.isAutoUpdate,
        'conditions': group.conditions.map((e) => e.toJson()).toList(), // Convert list of objects to JSON
        'metadata': group.metadata,
        'client_ids_cache': group.clientIds, // Storing List<String> directly as JSONB
        'last_updated_at': group.lastUpdatedAt,
        'company_id': -1, // Assuming default company_id for now
        'created_by': creatorId,
        'updated_by': creatorId,
      },
    );
    return AnalyticGroup.fromJson(result.first.toColumnMap());
  }

  Future<AnalyticGroup> updateAnalyticGroup(AnalyticGroup group, int updaterId) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('''
        UPDATE analytic_groups
        SET
          name = @name,
          description = @description,
          type = @type,
          is_auto_update = @is_auto_update,
          conditions = @conditions,
          metadata = @metadata,
          client_ids_cache = @client_ids_cache,
          last_updated_at = @last_updated_at,
          updated_by = @updaterId,
          updated_at = NOW()
        WHERE id = @id
        RETURNING *
      '''),
      parameters: {
        'id': int.parse(group.id),
        'name': group.name,
        'description': group.description,
        'type': group.type.index,
        'is_auto_update': group.isAutoUpdate,
        'conditions': group.conditions.map((e) => e.toJson()).toList(), // Convert list of objects to JSON
        'metadata': group.metadata,
        'client_ids_cache': group.clientIds, // Storing List<String> directly as JSONB
        'last_updated_at': group.lastUpdatedAt,
        'updaterId': updaterId,
      },
    );
    return AnalyticGroup.fromJson(result.first.toColumnMap());
  }

  Future<void> deleteAnalyticGroup(String id, int archiverId) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named('''
        UPDATE analytic_groups
        SET archived_at = NOW(), archived_by = @archiverId
        WHERE id = @id
      '''),
      parameters: {'id': int.parse(id), 'archiverId': archiverId},
    );
  }

  // --- Training Group Member Methods ---

  // --- Training Group Member Methods ---

  Future<List<String>> getTrainingGroupMembers(String groupId) async {
    final conn = await _db.connection;
    final results = await conn.execute(
      Sql.named('SELECT user_id FROM training_group_members WHERE training_group_id = @groupId'),
      parameters: {'groupId': int.parse(groupId)},
    );
    return results.map((row) => (row[0] as int).toString()).toList();
  }

  Future<void> addTrainingGroupMember(String groupId, String userId, int addedById) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named('''
        INSERT INTO training_group_members (training_group_id, user_id, added_by)
        VALUES (@groupId, @userId, @addedBy)
        ON CONFLICT (training_group_id, user_id) DO NOTHING
      '''),
      parameters: {'groupId': int.parse(groupId), 'userId': int.parse(userId), 'addedBy': addedById},
    );
  }

  Future<void> removeTrainingGroupMember(String groupId, String userId) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named('''
        DELETE FROM training_group_members
        WHERE training_group_id = @groupId AND user_id = @userId
      '''),
      parameters: {'groupId': int.parse(groupId), 'userId': int.parse(userId)},
    );
  }

  // --- Group Schedule Slot Methods ---

  Future<List<GroupScheduleSlot>> getGroupScheduleSlots(String groupId) async {
    final conn = await _db.connection;
    final results = await conn.execute(
      Sql.named('SELECT * FROM group_schedule_slots WHERE group_id = @groupId AND is_active = TRUE'),
      parameters: {'groupId': int.parse(groupId)},
    );
    return results.map((row) => GroupScheduleSlot.fromJson(row.toColumnMap())).toList();
  }

  Future<GroupScheduleSlot> createGroupScheduleSlot(GroupScheduleSlot slot) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('''
        INSERT INTO group_schedule_slots (group_id, day_of_week, start_time, end_time, is_active)
        VALUES (@groupId, @dayOfWeek, @startTime, @endTime, @isActive)
        RETURNING *
      '''),
      parameters: {
        'groupId': int.parse(slot.groupId),
        'dayOfWeek': slot.dayOfWeek,
        'startTime': slot.startTime.toJson(),
        'endTime': slot.endTime.toJson(),
        'isActive': slot.isActive,
      },
    );
    return GroupScheduleSlot.fromJson(result.first.toColumnMap());
  }

  Future<GroupScheduleSlot> updateGroupScheduleSlot(GroupScheduleSlot slot) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('''
        UPDATE group_schedule_slots
        SET
          day_of_week = @dayOfWeek,
          start_time = @startTime,
          end_time = @endTime,
          is_active = @isActive
        WHERE id = @id
        RETURNING *
      '''),
      parameters: {
        'id': int.parse(slot.id),
        'dayOfWeek': slot.dayOfWeek,
        'startTime': slot.startTime.toJson(),
        'endTime': slot.endTime.toJson(),
        'isActive': slot.isActive,
      },
    );
    return GroupScheduleSlot.fromJson(result.first.toColumnMap());
  }

  Future<void> deleteGroupScheduleSlot(String id) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named('DELETE FROM group_schedule_slots WHERE id = @id'),
      parameters: {'id': int.parse(id)},
    );
  }
}
