import 'package:fitman_backend/config/database.dart';
import 'package:fitman_backend/modules/infrastructure/models/room/room.model.dart';
import 'package:postgres/postgres.dart';

abstract class RoomRepository {
  Future<Room> getById(String id);
  Future<List<Room>> getAll();
  Future<Room> create(Room room);
  Future<Room> update(Room room);
  Future<void> delete(String id);
}

class RoomRepositoryImpl implements RoomRepository {
  RoomRepositoryImpl(this._db);

  final Database _db;

  @override
  Future<Room> create(Room room) {
    // TODO: implement create
    throw UnimplementedError();
  }

  @override
  Future<void> delete(String id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<List<Room>> getAll() async {
    try {
      final conn = await _db.connection;
      final result = await conn.execute('SELECT * FROM rooms WHERE archived_at IS NULL');

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
  Future<Room> getById(String id) async {
    try {
      final conn = await _db.connection;
      final result = await conn.execute(
        Sql.named('SELECT * FROM rooms WHERE id = @id AND archived_at IS NULL'),
        parameters: {'id': int.parse(id)},
      );

      if (result.isEmpty) {
        throw Exception('Room with ID $id not found');
      }

      return Room.fromMap(result.first.toColumnMap());
    } catch (e) {
      print('Error fetching room by ID $id: $e');
      rethrow;
    }
  }

  @override
  Future<Room> update(Room room) {
    // TODO: implement update
    throw UnimplementedError();
  }
}
