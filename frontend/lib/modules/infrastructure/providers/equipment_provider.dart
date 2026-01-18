import 'package:fitman_app/modules/infrastructure/models/equipment/equipment_item.model.dart';
import 'package:fitman_app/modules/infrastructure/models/equipment/equipment_type.model.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final allEquipmentTypesProvider = FutureProvider<List<EquipmentType>>((ref) {
  return ApiService.getAllEquipmentTypes();
});

final allEquipmentItemsProvider = FutureProvider<List<EquipmentItem>>((ref) {
  return ApiService.getAllEquipmentItems();
});

final equipmentByRoomProvider =
    FutureProvider.family<List<EquipmentItem>, String>((ref, roomId) {
  return ApiService.getAllEquipmentItems(roomId: roomId);
});
