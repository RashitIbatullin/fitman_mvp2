import 'dart:convert';
import 'package:fitman_backend/config/database.dart';
import 'package:fitman_backend/modules/infrastructure/models/equipment/equipment_item.model.dart';
import 'package:shelf/shelf.dart';

class EquipmentItemController {
  EquipmentItemController(this._db);

  final Database _db;

  Future<Response> getAllEquipmentItems(Request request) async {
    try {
      final roomId = request.url.queryParameters['roomId'];

      late final List<EquipmentItem> equipmentItems;

      if (roomId != null && roomId.isNotEmpty) {
        equipmentItems = await _db.equipmentItems.getByRoomId(roomId);
      } else {
        equipmentItems = await _db.equipmentItems.getAll();
      }

      final equipmentItemsJson =
          equipmentItems.map((item) => item.toJson()).toList();
      return Response.ok(jsonEncode(equipmentItemsJson));
    } catch (e) {
      return Response.internalServerError(
          body: '{"error": "Error fetching equipment items: $e"}');
    }
  }
}
