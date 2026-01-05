import 'dart:convert';
import 'package:fitman_backend/config/database.dart';
import 'package:shelf/shelf.dart';

class RoomController {
  RoomController(this._db);

  final Database _db;

  Future<Response> getAllRooms(Request request) async {
    try {
      final rooms = await _db.rooms.getAll();
      final roomsJson = rooms.map((r) => r.toJson()).toList();
      return Response.ok(jsonEncode(roomsJson));
    } catch (e) {
      return Response.internalServerError(body: '{"error": "Error fetching rooms: $e"}');
    }
  }

  Future<Response> getRoomById(Request request, String id) async {
    try {
      final room = await _db.rooms.getById(id);
      return Response.ok(jsonEncode(room.toJson()));
    } on Exception catch (e) {
      // Specifically catch the "not found" exception from the repository
      if (e.toString().contains('not found')) {
        return Response.notFound('{"error": "${e.toString()}"}');
      }
      return Response.internalServerError(body: '{"error": "Error fetching room: $e"}');
    }
  }
}