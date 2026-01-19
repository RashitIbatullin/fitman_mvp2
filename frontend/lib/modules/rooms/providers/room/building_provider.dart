import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:fitman_app/modules/rooms/models/building/building.model.dart';

// --- Building Providers ---

// All buildings provider with filter
final allBuildingsProvider =
    FutureProvider.family<List<Building>, bool?>((ref, isArchived) async {
  return ApiService.getAllBuildings(isArchived: isArchived);
});

// Building by ID provider
final buildingByIdProvider =
    FutureProvider.family<Building, String>((ref, id) async {
  return ApiService.getBuildingById(id);
});
