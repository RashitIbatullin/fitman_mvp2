
import 'package:fitman_backend/modules/infrastructure/models/room/room.model.dart';
import 'package:fitman_backend/modules/infrastructure/repositories/room.repository.dart';

abstract class RoomService {
  Future<Room> getById(String id);
  Future<List<Room>> getAll();
  Future<Room> create(Room room);
  Future<Room> update(Room room);
  Future<void> delete(String id);
}

class RoomServiceImpl implements RoomService {
  RoomServiceImpl(this._roomRepository);

  final RoomRepository _roomRepository;

  @override
  Future<Room> create(Room room) {
    return _roomRepository.create(room);
  }

  @override
  Future<void> delete(String id) {
    return _roomRepository.delete(id);
  }

  @override
  Future<List<Room>> getAll() {
    return _roomRepository.getAll();
  }

  @override
  Future<Room> getById(String id) {
    return _roomRepository.getById(id);
  }

  @override
  Future<Room> update(Room room) {
    return _roomRepository.update(room);
  }
}
