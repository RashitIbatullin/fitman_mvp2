import 'dart:convert';
import 'package:fitman_backend/config/database.dart';
import 'package:shelf/shelf.dart';

class EquipmentTypeController {
  EquipmentTypeController(this._db);

  final Database _db;

  Future<Response> getAllEquipmentTypes(Request request) async {
    try {
      final equipmentTypes = await _db.equipmentTypes.getAll();
      final equipmentTypesJson = equipmentTypes.map((type) => type.toJson()).toList();
      return Response.ok(jsonEncode(equipmentTypesJson));
    } catch (e) {
      return Response.internalServerError(body: '{"error": "Error fetching equipment types: $e"}');
    }
  }
}
