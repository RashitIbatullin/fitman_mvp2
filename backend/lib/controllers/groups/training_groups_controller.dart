import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../config/database.dart';
import '../../models/groups/training_group.dart';

class TrainingGroupsController {
  final Database _db;

  TrainingGroupsController(this._db);

  Router get router {
    final router = Router();

    router.get('/', _getAllTrainingGroups);
    router.get('/<id>', _getTrainingGroupById);
    router.post('/', _createTrainingGroup);
    router.put('/<id>', _updateTrainingGroup);
    router.delete('/<id>', _deleteTrainingGroup);

    return router;
  }

  Future<Response> _getAllTrainingGroups(Request request) async {
    try {
      final groups = await _db.groups.getAllTrainingGroups();
      return Response.ok(jsonEncode(groups.map((g) => g.toJson()).toList()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }

  Future<Response> _getTrainingGroupById(Request request, String id) async {
    try {
      final group = await _db.groups.getTrainingGroupById(id);
      if (group == null) {
        return Response.notFound(jsonEncode({'error': 'TrainingGroup not found'}));
      }
      return Response.ok(jsonEncode(group.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }

  Future<Response> _createTrainingGroup(Request request) async {
    try {
      final payload = jsonDecode(await request.readAsString());
      // TODO: Get creatorId from authenticated user context
      const creatorId = 1; // Placeholder for now

      final newGroup = TrainingGroup.fromJson(payload);
      final createdGroup = await _db.groups.createTrainingGroup(newGroup, creatorId);
      return Response(201, headers: {'Content-Type': 'application/json', 'Location': '/training_groups/${createdGroup.id}'}, body: jsonEncode(createdGroup.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }

  Future<Response> _updateTrainingGroup(Request request, String id) async {
    try {
      final payload = jsonDecode(await request.readAsString());
      // TODO: Get updaterId from authenticated user context
      const updaterId = 1; // Placeholder for now

      final updatedGroup = TrainingGroup.fromJson(payload.copyWith({'id': id})); // Ensure ID is from path
      final resultGroup = await _db.groups.updateTrainingGroup(updatedGroup, updaterId);
      return Response.ok(jsonEncode(resultGroup.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }

  Future<Response> _deleteTrainingGroup(Request request, String id) async {
    try {
      // TODO: Get archiverId from authenticated user context
      const archiverId = 1; // Placeholder for now
      await _db.groups.deleteTrainingGroup(id, archiverId);
      return Response(204);
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }
}