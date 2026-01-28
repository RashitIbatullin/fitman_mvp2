import 'package:fitman_backend/config/database.dart';
import 'package:fitman_backend/modules/equipment/models/equipment/equipment_item.model.dart';
import 'package:postgres/postgres.dart';

abstract class EquipmentItemRepository {
  Future<EquipmentItem> getById(String id);
  Future<List<EquipmentItem>> getAll({bool includeArchived = false});
  Future<List<EquipmentItem>> getByRoomId(String roomId, {bool includeArchived = false});
  Future<EquipmentItem> create(EquipmentItem equipmentItem);
  Future<EquipmentItem> update(EquipmentItem equipmentItem);
  Future<void> delete(String id);
  Future<void> archive(String id, String reason, String userId);
  Future<void> unarchive(String id);
}

class EquipmentItemRepositoryImpl implements EquipmentItemRepository {
  EquipmentItemRepositoryImpl(this._db);

  final Database _db;

  @override
  Future<void> archive(String id, String reason, String userId) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named(
          'UPDATE equipment_items SET archived_at = NOW(), archived_by = @userId, archived_reason = @reason WHERE id = @id'),
      parameters: {
        'id': id,
        'reason': reason,
        'userId': userId,
      },
    );
  }

  @override
  Future<void> unarchive(String id) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named(
          'UPDATE equipment_items SET archived_at = NULL, archived_by = NULL, archived_reason = NULL WHERE id = @id'),
      parameters: {
        'id': id,
      },
    );
  }

  @override
  Future<EquipmentItem> create(EquipmentItem equipmentItem) {
    // TODO: implement create
    throw UnimplementedError();
  }

  @override
  Future<void> delete(String id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<List<EquipmentItem>> getAll({bool includeArchived = false}) async {
    try {
      final conn = await _db.connection;
      final whereClause = includeArchived ? 'WHERE archived_at IS NOT NULL' : 'WHERE archived_at IS NULL';
      final result =
          await conn.execute(Sql.named('SELECT * FROM equipment_items $whereClause'));

      return result
          .map(
            (row) => EquipmentItem.fromMap(row.toColumnMap()),
          )
          .toList();
    } catch (e) {
      print('Error fetching all equipment items: $e');
      rethrow;
    }
  }

  @override
  Future<List<EquipmentItem>> getByRoomId(String roomId, {bool includeArchived = false}) async {
    try {
      final conn = await _db.connection;
      
      String whereClause;
      if (includeArchived) {
        whereClause = 'WHERE room_id = @roomId AND archived_at IS NOT NULL';
      } else {
        whereClause = 'WHERE room_id = @roomId AND archived_at IS NULL';
      }

      final result = await conn.execute(
        Sql.named('SELECT * FROM equipment_items $whereClause'),
        parameters: {
          'roomId': roomId,
        },
      );

      return result
          .map(
            (row) => EquipmentItem.fromMap(row.toColumnMap()),
          )
          .toList();
    } catch (e) {
      print('Error fetching equipment items by room ID: $e');
      rethrow;
    }
  }

  @override
  Future<EquipmentItem> getById(String id) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('SELECT * FROM equipment_items WHERE id = @id'),
      parameters: {'id': id},
    );

    if (result.isEmpty) {
      throw Exception('EquipmentItem with id $id not found');
    }

    return EquipmentItem.fromMap(result.first.toColumnMap());
  }

  @override
  Future<EquipmentItem> update(EquipmentItem equipmentItem) {
    // TODO: implement update
    throw UnimplementedError();
  }
}
