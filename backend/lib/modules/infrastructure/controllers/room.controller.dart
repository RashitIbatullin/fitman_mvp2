import 'dart:convert';

import 'package:fitman_backend/modules/infrastructure/services/room.service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class RoomController {
  RoomController(this._roomService);

  final RoomService _roomService;

  Router get router {
    final router = Router();

    router.get('/', (Request request) async {
      final rooms = await _roomService.getAll();
      return Response.ok(jsonEncode(rooms));
    });

    router.get('/<id>', (Request request, String id) async {
      final room = await _roomService.getById(id);
      if (room == null) {
        return Response.notFound('Room not found');
      }
      return Response.ok(jsonEncode(room));
    });

    // Other routes for create, update, delete, etc. will be added here.

    return router;
  }
}
