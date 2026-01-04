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

  final Connection _db;

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
  Future<List<Room>> getAll() {
    // TODO: implement getAll
    throw UnimplementedError();
  }

  @override
  Future<Room> getById(String id) {
    // TODO: implement getById
    throw UnimplementedError();
  }

  @override
  Future<Room> update(Room room) {
    // TODO: implement update
    throw UnimplementedError();
  }
}
