import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../config/database.dart';

class GroupMembersController {
  final Database _db;

  GroupMembersController(this._db);

  Router get router {
    final router = Router();

    router.get('/<groupId>/members', _getTrainingGroupMembers);
    router.post('/<groupId>/members', _addTrainingGroupMember);
    router.delete('/<groupId>/members/<userId>', _removeTrainingGroupMember);

    return router;
  }

  Future<Response> _getTrainingGroupMembers(Request request, String groupId) async {
    try {
      final members = await _db.groups.getTrainingGroupMembers(groupId);
      return Response.ok(jsonEncode(members));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }

  Future<Response> _addTrainingGroupMember(Request request, String groupId) async {
    try {
      final payload = jsonDecode(await request.readAsString());
      final String userId = payload['userId'].toString();
      // TODO: Get addedById from authenticated user context
      const addedById = 1; // Placeholder for now

      await _db.groups.addTrainingGroupMember(groupId, userId, addedById);
      return Response.ok(jsonEncode({'message': 'Member added successfully'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }

  Future<Response> _removeTrainingGroupMember(Request request, String groupId, String userId) async {
    try {
      await _db.groups.removeTrainingGroupMember(groupId, userId);
      return Response(204);
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }
}