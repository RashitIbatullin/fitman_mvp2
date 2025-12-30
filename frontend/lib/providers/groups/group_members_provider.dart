import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/groups/client_group_member.dart';
import '../../services/api_service.dart';

class GroupMembersState {
  const GroupMembersState({
    this.members = const [],
    this.isLoading = false,
    this.error,
  });

  final List<ClientGroupMember> members;
  final bool isLoading;
  final String? error;

  GroupMembersState copyWith({
    List<ClientGroupMember>? members,
    bool? isLoading,
    String? error,
  }) {
    return GroupMembersState(
      members: members ?? this.members,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class GroupMembersNotifier extends Notifier<GroupMembersState> {
  @override
  GroupMembersState build() {
    return const GroupMembersState();
  }

  Future<void> fetchMembers(int groupId) async {
    try {
      state = state.copyWith(isLoading: true);
      final members = await ApiService.getGroupMembers(groupId);
      state = state.copyWith(members: members, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> addMember(int groupId, int clientId) async {
    try {
      await ApiService.addGroupMember(groupId, clientId);
      fetchMembers(groupId); // Refresh the list
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> removeMember(int groupId, int clientId) async {
    try {
      await ApiService.removeGroupMember(groupId, clientId);
      fetchMembers(groupId); // Refresh the list
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final groupMembersProvider = NotifierProvider<GroupMembersNotifier, GroupMembersState>(GroupMembersNotifier.new);