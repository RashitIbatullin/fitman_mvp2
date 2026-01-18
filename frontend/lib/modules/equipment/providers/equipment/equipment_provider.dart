import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:fitman_app/modules/equipment/models/equipment/equipment_item.model.dart';
import 'package:fitman_app/modules/equipment/models/equipment/equipment_type.model.dart';
import 'package:fitman_app/modules/equipment/models/equipment/equipment_status.enum.dart';
import 'package:fitman_app/modules/equipment/models/equipment/equipment_category.enum.dart';

// --- Filters for Equipment ---
final equipmentFilterSearchQueryProvider = StateProvider<String>((ref) => '');
final equipmentFilterEquipmentTypeProvider = StateProvider<EquipmentType?>((ref) => null);
final equipmentFilterStatusProvider = StateProvider<EquipmentStatus?>((ref) => null);
final equipmentFilterRoomIdProvider = StateProvider<String?>((ref) => null);
final equipmentFilterConditionRatingProvider = StateProvider<int?>((ref) => null);
final equipmentFilterCategoryProvider = StateProvider<EquipmentCategory?>((ref) => null);


// --- Equipment Type Providers ---

// All equipment types provider
final allEquipmentTypesProvider = FutureProvider<List<EquipmentType>>((ref) async {
  final category = ref.watch(equipmentFilterCategoryProvider);
  return ApiService.getAllEquipmentTypes(category: category);
});

// Equipment type by ID provider
final equipmentTypeByIdProvider = FutureProvider.family<EquipmentType, String>((ref, id) async {
  return ApiService.getEquipmentTypeById(id);
});

// --- Equipment Item Providers ---

// All equipment items provider
final allEquipmentItemsProvider = FutureProvider<List<EquipmentItem>>((ref) async {
  // Can add filters here if needed
  return ApiService.getAllEquipmentItems();
});

// Equipment item by ID provider
final equipmentItemByIdProvider = FutureProvider.family<EquipmentItem, String>((ref, id) async {
  return ApiService.getEquipmentItemById(id);
});

