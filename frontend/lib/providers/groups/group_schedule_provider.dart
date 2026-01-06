import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:fitman_app/models/groups/group_schedule_slot.dart';

part 'group_schedule_provider.g.dart';

@Riverpod(keepAlive: true)
class GroupSchedule extends _$GroupSchedule {
  @override
  Future<List<GroupScheduleSlot>> build(int groupId) async {
    return ApiService.getGroupScheduleSlots(groupId);
  }

  Future<void> createGroupScheduleSlot(GroupScheduleSlot slot) async {
    state = const AsyncValue.loading();
    try {
      await ApiService.createGroupScheduleSlot(slot.groupId, slot);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateGroupScheduleSlot(GroupScheduleSlot slot) async {
    state = const AsyncValue.loading();
    try {
      await ApiService.updateGroupScheduleSlot(slot);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteGroupScheduleSlot(int id) async {
    state = const AsyncValue.loading();
    try {
      await ApiService.deleteGroupScheduleSlot(id);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}