import 'dart:convert';
import 'package:fitman_backend/config/database.dart';
import 'package:shelf/shelf.dart';

class EquipmentItemController {
  EquipmentItemController(this._db);

  final Database _db;

  Future<Response> getAllEquipmentItems(Request request) async {
    try {
      final equipmentItems = await _db.equipmentItems.getAll();
      final equipmentItemsJson = equipmentItems.map((item) => item.toJson()).toList();
      return Response.ok(jsonEncode(equipmentItemsJson));
    } catch (e) {
      return Response.internalServerError(body: '{"error": "Error fetching equipment items: $e"}');
    }
  }
}
