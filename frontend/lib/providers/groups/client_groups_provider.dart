import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/groups/client_group.dart';
import '../../services/api_service.dart';

class ClientGroupsState {
  const ClientGroupsState({
    this.groups = const [],
    this.isLoading = false,
    this.error,
  });

  final List<ClientGroup> groups;
  final bool isLoading;
  final String? error;

  ClientGroupsState copyWith({
    List<ClientGroup>? groups,
    bool? isLoading,
    String? error,
  }) {
    return ClientGroupsState(
      groups: groups ?? this.groups,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ClientGroupsNotifier extends Notifier<ClientGroupsState> {
  @override
  ClientGroupsState build() {
    // Initial state
    return const ClientGroupsState();
  }

  Future<void> fetchGroups() async {
    try {
      state = state.copyWith(isLoading: true);
      final groups = await ApiService.getAllClientGroups();
      state = state.copyWith(groups: groups, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> createGroup(ClientGroup group) async {
    try {
      await ApiService.createClientGroup(group);
      fetchGroups(); // Refresh the list
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateGroup(ClientGroup group) async {
    try {
      await ApiService.updateClientGroup(group);
      fetchGroups(); // Refresh the list
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteGroup(int groupId) async {
    try {
      await ApiService.deleteClientGroup(groupId);
      fetchGroups(); // Refresh the list
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final clientGroupsProvider = NotifierProvider<ClientGroupsNotifier, ClientGroupsState>(ClientGroupsNotifier.new);

// Assuming ApiService and its provider are defined elsewhere for now
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

