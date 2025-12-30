import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'group_members_controller.dart';
import '../../config/database.dart';

class ClientGroupMembersShelfController {
  static final _controller = GroupMembersController(Database());

  static Future<Response> getGroupMembers(Request request, String groupIdStr) async {
    try {
      final groupId = int.tryParse(groupIdStr);
      if (groupId == null) {
        return Response(
          HttpStatus.badRequest,
          body: jsonEncode({'error': 'Invalid group ID format'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final members = await _controller.getGroupMembers(groupId);
      final membersJson = members.map((m) => m.toJson()).toList();
      return Response(
        HttpStatus.ok,
        body: jsonEncode(membersJson),
        headers: {'Content-Type': 'application/json'},
      );

    } catch (e) {
      return Response(
        HttpStatus.internalServerError,
        body: jsonEncode({'error': 'Failed to fetch group members: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  static Future<Response> addGroupMember(Request request, String groupIdStr) async {
    try {
      final groupId = int.tryParse(groupIdStr);
      if (groupId == null) {
        return Response(
          HttpStatus.badRequest,
          body: jsonEncode({'error': 'Invalid group ID format'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final body = await request.readAsString();
      final jsonBody = jsonDecode(body) as Map<String, dynamic>;
      final clientId = jsonBody['clientId'] as int?;

      if (clientId == null) {
        return Response(
          HttpStatus.badRequest,
          body: jsonEncode({'error': 'Missing required field: clientId'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final user = request.context['user'] as Map<String, dynamic>?;
      final addedById = user?['userId'] as int?;

      if (addedById == null) {
        return Response(
          HttpStatus.unauthorized,
          body: jsonEncode({'error': 'Authenticated user ID not found.'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      await _controller.addGroupMember(groupId, clientId, addedById);

      return Response(HttpStatus.created);

    } catch (e) {
      return Response(
        HttpStatus.internalServerError,
        body: jsonEncode({'error': 'Failed to add member to group: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  static Future<Response> removeGroupMember(Request request, String groupIdStr, String memberIdStr) async {
    try {
      final groupId = int.tryParse(groupIdStr);
      final memberId = int.tryParse(memberIdStr);

      if (groupId == null || memberId == null) {
        return Response(
          HttpStatus.badRequest,
          body: jsonEncode({'error': 'Invalid group ID or member ID format'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      await _controller.removeGroupMember(groupId, memberId);

      return Response(HttpStatus.noContent);

    } catch (e) {
      return Response(
        HttpStatus.internalServerError,
        body: jsonEncode({'error': 'Failed to remove member from group: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
