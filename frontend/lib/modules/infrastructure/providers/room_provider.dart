import 'package:fitman_app/modules/infrastructure/models/room/room.model.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final allRoomsProvider = FutureProvider<List<Room>>((ref) {
  return ApiService.getAllRooms();
});

final roomByIdProvider = FutureProvider.family<Room, String>((ref, id) {
  return ApiService.getRoomById(id);
});
