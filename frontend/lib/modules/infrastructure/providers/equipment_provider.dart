import 'package:fitman_app/modules/infrastructure/models/equipment/equipment_item.model.dart';
import 'package:fitman_app/modules/infrastructure/models/equipment/equipment_type.model.dart';
import 'package:fitman_app/modules/infrastructure/services/equipment_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final equipmentServiceProvider = Provider<EquipmentService>((ref) {
  return EquipmentService();
});

final allEquipmentTypesProvider = FutureProvider<List<EquipmentType>>((ref) {
  final equipmentService = ref.watch(equipmentServiceProvider);
  return equipmentService.getAllTypes();
});

final allEquipmentItemsProvider = FutureProvider<List<EquipmentItem>>((ref) {
  final equipmentService = ref.watch(equipmentServiceProvider);
  return equipmentService.getAllItems();
});
