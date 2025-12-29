import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/groups/client_group_member.dart';
import '../../services/api_service.dart';
import 'client_groups_provider.dart'; // To access apiServiceProvider

// Since this provider depends on a dynamic groupId, we use the Family modifier.
// However, the manual implementation for a Notifier with a family is more complex.
// For now, let's create a simple Notifier that can be managed by another provider
// or have its groupId set explicitly.

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

  Future<void> fetchMembers(String groupId) async {
    try {
      state = state.copyWith(isLoading: true);
      // final members = await ref.read(apiServiceProvider).getGroupMembers(groupId);
      state = state.copyWith(members: [], isLoading: false, error: null); // Placeholder
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> addMember(String groupId, String clientId) async {
    try {
      // await ref.read(apiServiceProvider).addGroupMember(groupId, clientId);
      fetchMembers(groupId); // Refresh
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

    Future<void> removeMember(String groupId, String clientId) async {
    try {
      // await ref.read(apiServiceProvider).removeGroupMember(groupId, clientId);
      fetchMembers(groupId); // Refresh
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final groupMembersProvider = NotifierProvider<GroupMembersNotifier, GroupMembersState>(GroupMembersNotifier.new);
