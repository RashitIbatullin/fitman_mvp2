import 'package:fitman_app/modules/infrastructure/models/room/room.model.dart';
import 'package:fitman_app/modules/infrastructure/services/room_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final roomServiceProvider = Provider<RoomService>((ref) {
  return RoomService();
});

final allRoomsProvider = FutureProvider<List<Room>>((ref) {
  final roomService = ref.watch(roomServiceProvider);
  return roomService.getAllRooms();
});

final roomByIdProvider = FutureProvider.family<Room, String>((ref, id) {
  final roomService = ref.watch(roomServiceProvider);
  return roomService.getRoomById(id);
});
