import 'package:fitman_backend/config/database.dart';
import 'package:fitman_backend/modules/rooms/models/building/building.model.dart';
import 'package:postgres/postgres.dart';

class BuildingRepository {
  const BuildingRepository(this._db);

  final Database _db;

  Future<List<Building>> selectAll({bool? isArchived}) async {
    final conn = await _db.connection;
    var query = 'SELECT * FROM buildings';
    if (isArchived != null) {
      query += isArchived
          ? ' WHERE archived_at IS NOT NULL'
          : ' WHERE archived_at IS NULL';
    }
    final result = await conn.execute(query);
    return result.map((row) => Building.fromMap(row.toColumnMap())).toList();
  }

  Future<Building?> selectById(String id) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('SELECT * FROM buildings WHERE id = @id AND archived_at IS NULL'),
      parameters: {'id': int.parse(id)},
    );
    return result.isEmpty ? null : Building.fromMap(result.first.toColumnMap());
  }

  Future<Building?> selectByName(String name) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('SELECT * FROM buildings WHERE name = @name AND archived_at IS NULL'),
      parameters: {'name': name},
    );
    return result.isEmpty ? null : Building.fromMap(result.first.toColumnMap());
  }

  Future<Building> insert(Building building) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('INSERT INTO buildings (name, address, note) VALUES (@name, @address, @note) RETURNING *'),
      parameters: {
        'name': building.name,
        'address': building.address,
        'note': building.note,
      },
    );
    return Building.fromMap(result.first.toColumnMap());
  }

  Future<Building> update(String id, Building building) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('UPDATE buildings SET name = @name, address = @address, note = @note, updated_at = NOW(), archived_at = @archived_at WHERE id = @id RETURNING *'),
      parameters: {
        'id': int.parse(id),
        'name': building.name,
        'address': building.address,
        'note': building.note,
        'archived_at': building.archivedAt,
      },
    );
    return Building.fromMap(result.first.toColumnMap());
  }

  Future<void> archive(String id, int userId) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named('UPDATE buildings SET archived_at = NOW(), archived_by = @userId WHERE id = @id'),
      parameters: {'id': int.parse(id), 'userId': userId},
    );
  }
}
