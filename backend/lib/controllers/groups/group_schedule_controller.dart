import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../config/database.dart';
import '../../models/groups/group_schedule_slot.dart';

class GroupScheduleController {
  final Database _db;

  GroupScheduleController(this._db);

  Router get router {
    final router = Router();

    router.get('/<groupId>', _getGroupScheduleSlots);
    router.post('/<groupId>', _createGroupScheduleSlot);
    router.put('/<id>', _updateGroupScheduleSlot);
    router.delete('/<id>', _deleteGroupScheduleSlot);

    return router;
  }

  Future<Response> _getGroupScheduleSlots(Request request, String groupId) async {
    try {
      final slots = await _db.groups.getGroupScheduleSlots(groupId);
      return Response.ok(jsonEncode(slots.map((s) => s.toJson()).toList()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }

  Future<Response> _createGroupScheduleSlot(Request request, String groupId) async {
    try {
      final payload = jsonDecode(await request.readAsString());
      final newSlot = GroupScheduleSlot.fromJson({...payload, 'groupId': groupId}); // Ensure groupId is from path
      final createdSlot = await _db.groups.createGroupScheduleSlot(newSlot);
      return Response(201, headers: {'Content-Type': 'application/json', 'Location': '/group_schedules/${createdSlot.id}'}, body: jsonEncode(createdSlot.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }

  Future<Response> _updateGroupScheduleSlot(Request request, String id) async {
    try {
      final payload = jsonDecode(await request.readAsString());
      final updatedSlot = GroupScheduleSlot.fromJson({...payload, 'id': id}); // Ensure ID is from path
      final resultSlot = await _db.groups.updateGroupScheduleSlot(updatedSlot);
      return Response.ok(jsonEncode(resultSlot.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }

  Future<Response> _deleteGroupScheduleSlot(Request request, String id) async {
    try {
      await _db.groups.deleteGroupScheduleSlot(id);
      return Response(204);
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }
}