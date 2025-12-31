import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fitman_app/services/api_service.dart';

part 'group_members_provider.g.dart';

@Riverpod(keepAlive: true)
class GroupMembers extends _$GroupMembers {
  @override
  Future<List<String>> build(String groupId) async {
    return ApiService.getTrainingGroupMembers(groupId);
  }

  Future<void> addMember(String groupId, String userId) async {
    state = const AsyncValue.loading();
    try {
      await ApiService.addTrainingGroupMember(groupId, userId);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> removeMember(String groupId, String userId) async {
    state = const AsyncValue.loading();
    try {
      await ApiService.removeTrainingGroupMember(groupId, userId);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}