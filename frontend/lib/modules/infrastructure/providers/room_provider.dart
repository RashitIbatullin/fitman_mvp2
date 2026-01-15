import 'package:fitman_app/services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/room/room.model.dart';
import '../models/room/room_type.enum.dart'; // Ensure RoomType is imported

// Providers for filters
final roomTypeFilterProvider = StateProvider<RoomType?>((ref) => null);
final roomIsUnderMaintenanceFilterProvider = StateProvider<bool?>((ref) => null);
final roomIsArchivedFilterProvider = StateProvider<bool?>((ref) => null); // New filter provider

// Provider to fetch rooms based on filters
class RoomsNotifier extends AsyncNotifier<List<Room>> {
  @override
  Future<List<Room>> build() async {
    final selectedRoomType = ref.watch(roomTypeFilterProvider);
    final isUnderMaintenance = ref.watch(roomIsUnderMaintenanceFilterProvider);
    final isArchived = ref.watch(roomIsArchivedFilterProvider);

    return ApiService.getAllRooms(
        roomType: selectedRoomType?.value,
        isUnderMaintenance: isUnderMaintenance,
        isArchived: isArchived);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }
}

final allRoomsProvider = AsyncNotifierProvider<RoomsNotifier, List<Room>>(() {
  return RoomsNotifier();
});

final roomByIdProvider =
    FutureProvider.family<Room, String>((ref, roomId) async {
  return ApiService.getRoomById(roomId);
});