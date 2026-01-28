import 'package:fitman_backend/config/database.dart';
import 'package:fitman_backend/modules/equipment/models/equipment/equipment_type.model.dart';
import 'package:postgres/postgres.dart';

abstract class EquipmentTypeRepository {
  Future<EquipmentType> getById(String id);
  Future<List<EquipmentType>> getAll({bool includeArchived = false});
  Future<EquipmentType> create(EquipmentType equipmentType);
  Future<EquipmentType> update(EquipmentType equipmentType);
  Future<void> delete(String id);
  Future<void> archive(String id, String reason, String userId);
  Future<void> unarchive(String id);
}

class EquipmentTypeRepositoryImpl implements EquipmentTypeRepository {
  EquipmentTypeRepositoryImpl(this._db);

  final Database _db;

  @override
  Future<void> archive(String id, String reason, String userId) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named(
          'UPDATE equipment_types SET archived_at = NOW(), archived_by = @userId, archived_reason = @reason WHERE id = @id'),
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
          'UPDATE equipment_types SET archived_at = NULL, archived_by = NULL, archived_reason = NULL WHERE id = @id'),
      parameters: {
        'id': id,
      },
    );
  }

  @override
  Future<EquipmentType> create(EquipmentType equipmentType) {
    // TODO: implement create
    throw UnimplementedError();
  }

  @override
  Future<void> delete(String id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<List<EquipmentType>> getAll({bool includeArchived = false}) async {
    try {
      final conn = await _db.connection;
      final whereClause = includeArchived ? 'WHERE archived_at IS NOT NULL' : 'WHERE archived_at IS NULL';
      final result =
          await conn.execute(Sql.named('SELECT * FROM equipment_types $whereClause'));

      return result
          .map(
            (row) => EquipmentType.fromMap(row.toColumnMap()),
          )
          .toList();
    } catch (e) {
      print('Error fetching all equipment types: $e');
      rethrow;
    }
  }

  @override
  Future<EquipmentType> getById(String id) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('SELECT * FROM equipment_types WHERE id = @id'),
      parameters: {'id': id},
    );

    if (result.isEmpty) {
      throw Exception('EquipmentType with id $id not found');
    }

    return EquipmentType.fromMap(result.first.toColumnMap());
  }

  @override
  Future<EquipmentType> update(EquipmentType equipmentType) {
    // TODO: implement update
    throw UnimplementedError();
  }
}
