import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';

import '../../config/database.dart';
import '../../models/groups/client_group.dart';
import '../../models/groups/client_group_type.dart';
import 'client_groups_controller.dart';
import 'group_members_controller.dart';

class ClientGroupsShelfController {
  static final _controller = ClientGroupsController(Database());

  static Future<Response> getAllGroups(Request request) async {
    try {
      final groups = await _controller.getAllGroups();
      final groupsJson = groups.map((g) => g.toJson()).toList();
      return Response(
        HttpStatus.ok,
        body: jsonEncode(groupsJson),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response(
        HttpStatus.internalServerError,
        body: jsonEncode({'error': 'Failed to fetch groups: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  static Future<Response> createGroup(Request request) async {
    try {
      final body = await request.readAsString();
      final jsonBody = jsonDecode(body) as Map<String, dynamic>;
      
      final name = jsonBody['name'] as String?;
      final description = jsonBody['description'] as String?;
      final typeIndex = jsonBody['type'] as int?;
      final isAutoUpdate = jsonBody['is_auto_update'] as bool?;

      if (name == null || typeIndex == null || isAutoUpdate == null) {
        return Response(
          HttpStatus.badRequest,
          body: jsonEncode({'error': 'Missing required fields: name, type, is_auto_update'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
      
      final user = request.context['user'] as Map<String, dynamic>?;
      final creatorId = user?['userId'] as int?;

      if (creatorId == null) {
        return Response(
          HttpStatus.unauthorized,
          body: jsonEncode({'error': 'Authenticated user ID not found.'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final group = ClientGroup(
        id: 0, // Will be ignored by DB
        name: name,
        description: description ?? '',
        type: ClientGroupType.values[typeIndex],
        isAutoUpdate: isAutoUpdate,
        conditions: [], // Handled separately
        clientIds: [],  // Handled separately
      );

      final createdGroup = await _controller.createGroup(group, creatorId);
      
      return Response(
        HttpStatus.created,
        body: jsonEncode(createdGroup.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response(
        HttpStatus.internalServerError,
        body: jsonEncode({'error': 'Failed to create group: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  static Future<Response> getGroupById(Request request, String id) async {
    try {
      final groupId = int.tryParse(id);
      if (groupId == null) {
        return Response(
          HttpStatus.badRequest,
          body: jsonEncode({'error': 'Invalid group ID format'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
      
      final group = await _controller.getGroupById(groupId);

      if (group == null) {
        return Response(
          HttpStatus.notFound,
          body: jsonEncode({'error': 'Group with ID $id not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
      
      return Response(
        HttpStatus.ok,
        body: jsonEncode(group.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response(
        HttpStatus.internalServerError,
        body: jsonEncode({'error': 'Failed to fetch group: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  static Future<Response> updateGroup(Request request, String id) async {
    try {
      final groupId = int.tryParse(id);
      if (groupId == null) {
        return Response(
          HttpStatus.badRequest,
          body: jsonEncode({'error': 'Invalid group ID format'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final body = await request.readAsString();
      final jsonBody = jsonDecode(body) as Map<String, dynamic>;
      
      final user = request.context['user'] as Map<String, dynamic>?;
      final updaterId = user?['userId'] as int?;

      if (updaterId == null) {
        return Response(
          HttpStatus.unauthorized,
          body: jsonEncode({'error': 'Authenticated user ID not found.'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Server-side validation: Prevent type change if group has members
      final newTypeIndex = jsonBody['type'] as int?;
      if (newTypeIndex != null) {
        final originalGroup = await _controller.getGroupById(groupId);
        if (originalGroup != null && originalGroup.type.index != newTypeIndex) {
          final membersController = GroupMembersController(Database());
          final members = await membersController.getGroupMembers(groupId);
          if (members.isNotEmpty) {
            return Response(
              HttpStatus.conflict,
              body: jsonEncode({'error': 'Cannot change group type when the group has members.'}),
              headers: {'Content-Type': 'application/json'},
            );
          }
        }
      }

      // Manually construct the group from the request body
      final name = jsonBody['name'] as String?;
      final description = jsonBody['description'] as String?;
      final typeIndex = jsonBody['type'] as int?;
      final isAutoUpdate = jsonBody['is_auto_update'] as bool?;
      
      if (name == null || typeIndex == null || isAutoUpdate == null) {
        return Response(
          HttpStatus.badRequest,
          body: jsonEncode({'error': 'Missing required fields: name, type, is_auto_update'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final group = ClientGroup(
        id: groupId,
        name: name,
        description: description ?? '',
        type: ClientGroupType.values[typeIndex],
        isAutoUpdate: isAutoUpdate,
      );

      final updatedGroup = await _controller.updateGroup(group, updaterId);
      
      return Response(
        HttpStatus.ok,
        body: jsonEncode(updatedGroup.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response(
        HttpStatus.internalServerError,
        body: jsonEncode({'error': 'Failed to update group: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  static Future<Response> deleteGroup(Request request, String id) async {
    try {
      final groupId = int.tryParse(id);
      if (groupId == null) {
        return Response(
          HttpStatus.badRequest,
          body: jsonEncode({'error': 'Invalid group ID format'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final user = request.context['user'] as Map<String, dynamic>?;
      final archiverId = user?['userId'] as int?;

      if (archiverId == null) {
        return Response(
          HttpStatus.unauthorized,
          body: jsonEncode({'error': 'Authenticated user ID not found.'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      await _controller.deleteGroup(groupId, archiverId);
      
      return Response(HttpStatus.noContent);
    } catch (e) {
      return Response(
        HttpStatus.internalServerError,
        body: jsonEncode({'error': 'Failed to delete group: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
