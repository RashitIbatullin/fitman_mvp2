import 'dart:convert';

import 'package:fitman_backend/modules/infrastructure/services/equipment.service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class EquipmentController {
  EquipmentController(this._equipmentService);

  final EquipmentService _equipmentService;

  Router get router {
    final router = Router();

    router.get('/types', (Request request) async {
      final types = await _equipmentService.getAllTypes();
      return Response.ok(jsonEncode(types));
    });

    router.get('/types/<id>', (Request request, String id) async {
      final type = await _equipmentService.getTypeById(id);
      if (type == null) {
        return Response.notFound('EquipmentType not found');
      }
      return Response.ok(jsonEncode(type));
    });

    router.get('/items', (Request request) async {
      final items = await _equipmentService.getAllItems();
      return Response.ok(jsonEncode(items));
    });

    router.get('/items/<id>', (Request request, String id) async {
      final item = await _equipmentService.getItemById(id);
      if (item == null) {
        return Response.notFound('EquipmentItem not found');
      }
      return Response.ok(jsonEncode(item));
    });

    // Other routes will be added here

    return router;
  }
}
