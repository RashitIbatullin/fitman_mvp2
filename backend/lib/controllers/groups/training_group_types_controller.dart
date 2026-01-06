import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../config/database.dart';

class TrainingGroupTypesController {
  final Database _db;

  TrainingGroupTypesController(this._db);

  Router get router {
    final router = Router();

    router.get('/', _getAllTrainingGroupTypes);

    return router;
  }

  Future<Response> _getAllTrainingGroupTypes(Request request) async {
    try {
      final types = await _db.groups.getAllTrainingGroupTypes();
      return Response.ok(jsonEncode(types.map((t) => t.toJson()).toList()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }
}
