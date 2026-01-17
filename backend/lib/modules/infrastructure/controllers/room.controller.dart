import 'dart:async';
import 'dart:convert';
import 'package:fitman_backend/config/database.dart';
import 'package:fitman_backend/modules/infrastructure/models/room/room.model.dart';
import 'package:fitman_backend/modules/infrastructure/repositories/room.repository.dart';
import 'package:fitman_backend/modules/infrastructure/services/room.service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class RoomController {
  RoomController(Database db)
      : _roomService =
            RoomService(RoomRepositoryImpl(db));

  final RoomService _roomService;

  Router get router {
    final router = Router()
      ..get('/', _getRooms)
      ..post('/', _createRoom)
      ..get('/<id>', _getRoomById)
      ..put('/<id>', _updateRoom)
      ..delete('/<id>', _archiveRoom);
    return router;
  }

  Future<Response> _getRooms(Request request) async {
    final queryParams = request.url.queryParameters;
    final isArchived = queryParams['isArchived'] == null
        ? null
        : queryParams['isArchived'] == 'true';
    final isActive = queryParams['isActive'] == null
        ? null
        : queryParams['isActive'] == 'true';

    final rooms =
        await _roomService.getRooms(isArchived: isArchived, isActive: isActive);
    final roomsJson = rooms.map((r) => r.toJson()).toList();
    return Response.ok(jsonEncode(roomsJson));
  }

  Future<Response> _getRoomById(Request request, String id) async {
    try {
      final room = await _roomService.getRoomById(id);
      if (room == null) {
        return Response.notFound('{"error": "Room not found"}');
      }
      return Response.ok(jsonEncode(room.toJson()));
    } on Exception catch (e) {
      return Response.internalServerError(body: '{"error": "Error fetching room: $e"}');
    }
  }

  Future<Response> _createRoom(Request request) async {
    try {
      final body = await request.readAsString();
      final room = Room.fromJson(jsonDecode(body));
      final newRoom = await _roomService.createRoom(room);
      return Response(
        201,
        body: jsonEncode(newRoom.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } on Exception catch (e) {
      return Response.internalServerError(body: '{"error": "$e"}');
    }
  }

  Future<Response> _updateRoom(Request request, String id) async {
    try {
      final body = await request.readAsString();
      final room = Room.fromJson(jsonDecode(body));
      final updatedRoom = await _roomService.updateRoom(id, room);
      return Response.ok(
        jsonEncode(updatedRoom.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } on Exception catch (e) {
      return Response.internalServerError(body: '{"error": "$e"}');
    }
  }

  Future<Response> _archiveRoom(Request request, String id) async {
    try {
      await _roomService.archiveRoom(id);
      return Response(204);
    } on Exception catch (e) {
      return Response.internalServerError(body: '{"error": "$e"}');
    }
  }
}