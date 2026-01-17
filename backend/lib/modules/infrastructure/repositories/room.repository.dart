import 'dart:convert';
import 'package:fitman_backend/config/database.dart';
import 'package:fitman_backend/modules/infrastructure/models/room/room.model.dart';
import 'package:postgres/postgres.dart';

abstract class RoomRepository {
  Future<Room?> getById(String id);
  Future<List<Room>> getAll({bool? isArchived});
  Future<Room> create(Room room);
  Future<Room> update(String id, Room room);
  Future<void> archive(String id);
}

class RoomRepositoryImpl implements RoomRepository {
  RoomRepositoryImpl(this._db);

  final Database _db;

  @override
  Future<Room> create(Room room) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('''
        WITH new_row AS (
          INSERT INTO rooms (name, description, room_number, type, floor, building_id, max_capacity, area, open_time, close_time, working_days, is_active, deactivate_reason, deactivate_at, deactivate_by) 
          VALUES (@name, @description, @room_number, @type, @floor, @building_id, @max_capacity, @area, @open_time, @close_time, @working_days, @is_active, @deactivate_reason, @deactivate_at, @deactivate_by) 
          RETURNING *
        )
        SELECT nr.*, b.name as building_name 
        FROM new_row nr
        LEFT JOIN buildings b ON nr.building_id = b.id
      '''),
      parameters: {
        'name': room.name,
        'description': room.description,
        'room_number': room.roomNumber,
        'type': room.type.value,
        'floor': room.floor,
        'building_id': room.buildingId != null ? int.parse(room.buildingId!) : null,
        'max_capacity': room.maxCapacity,
        'area': room.area,
        'open_time': room.openTime,
        'close_time': room.closeTime,
        'working_days': jsonEncode(room.workingDays),
        'is_active': room.isActive,
        'deactivate_reason': room.deactivateReason,
        'deactivate_at': room.deactivateAt,
        'deactivate_by': room.deactivateBy != null ? int.parse(room.deactivateBy!) : null,
      },
    );
    return Room.fromMap(result.first.toColumnMap());
  }

  @override
  Future<void> archive(String id) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named('UPDATE rooms SET archived_at = NOW() WHERE id = @id'),
      parameters: {'id': int.parse(id)},
    );
  }

  @override
  Future<List<Room>> getAll({bool? isArchived}) async {
    try {
      final conn = await _db.connection;
      var query =
          'SELECT r.*, b.name as building_name FROM rooms r LEFT JOIN buildings b ON r.building_id = b.id';
      if (isArchived != null) {
        query += isArchived
            ? ' WHERE r.archived_at IS NOT NULL'
            : ' WHERE r.archived_at IS NULL';
      }
      final result = await conn.execute(query);

      return result
          .map(
            (row) => Room.fromMap(row.toColumnMap()),
          )
          .toList();
    } catch (e) {
      print('Error fetching all rooms: $e');
      rethrow;
    }
  }

  @override
  Future<Room?> getById(String id) async {
    try {
      final conn = await _db.connection;
      final result = await conn.execute(
        Sql.named(
            'SELECT r.*, b.name as building_name FROM rooms r LEFT JOIN buildings b ON r.building_id = b.id WHERE r.id = @id'),
        parameters: {'id': int.parse(id)},
      );

      if (result.isEmpty) {
        return null;
      }

      return Room.fromMap(result.first.toColumnMap());
    } catch (e) {
      print('Error fetching room by ID $id: $e');
      rethrow;
    }
  }

  @override
  Future<Room> update(String id, Room room) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('''
        WITH updated AS (
          UPDATE rooms 
          SET 
            name = @name, 
            description = @description, 
            room_number = @room_number, 
            type = @type, 
            floor = @floor, 
            building_id = @building_id, 
            max_capacity = @max_capacity, 
            area = @area, 
            open_time = @open_time, 
            close_time = @close_time, 
            working_days = @working_days, 
            photo_urls = @photo_urls, 
            is_active = @is_active, 
            deactivate_reason = @deactivate_reason, 
            deactivate_at = @deactivate_at, 
            deactivate_by = @deactivate_by, 
            archived_at = @archived_at, 
            updated_at = NOW() 
          WHERE id = @id 
          RETURNING *
        )
        SELECT u.*, b.name as building_name 
        FROM updated u
        LEFT JOIN buildings b ON u.building_id = b.id
      '''),
      parameters: {
        'id': int.parse(id),
        'name': room.name,
        'description': room.description,
        'room_number': room.roomNumber,
        'type': room.type.value,
        'floor': room.floor,
        'building_id': room.buildingId != null ? int.parse(room.buildingId!) : null,
        'max_capacity': room.maxCapacity,
        'area': room.area,
        'open_time': room.openTime,
        'close_time': room.closeTime,
        'working_days': jsonEncode(room.workingDays),
        'photo_urls': jsonEncode(room.photoUrls),
        'is_active': room.isActive,
        'deactivate_reason': room.deactivateReason,
        'deactivate_at': room.deactivateAt,
        'deactivate_by': room.deactivateBy != null ? int.parse(room.deactivateBy!) : null,
        'archived_at': room.archivedAt,
      },
    );
    return Room.fromMap(result.first.toColumnMap());
  }
}
