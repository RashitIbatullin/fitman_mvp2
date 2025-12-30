import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/groups/client_group.dart';
import '../../models/groups/group_types.dart';
import '../../services/api_service.dart';

class ClientGroupsState {
  const ClientGroupsState({
    this.groups = const [],
    this.isLoading = false,
    this.error,
    this.filterType,
    this.searchQuery = '',
  });

  final List<ClientGroup> groups;
  final bool isLoading;
  final String? error;
  final ClientGroupType? filterType;
  final String searchQuery;

  ClientGroupsState copyWith({
    List<ClientGroup>? groups,
    bool? isLoading,
    String? error,
    ClientGroupType? filterType,
    String? searchQuery,
  }) {
    return ClientGroupsState(
      groups: groups ?? this.groups,
      isLoading: isLoading ?? this.isLoading,
      error: error, // Don't carry over old errors
      filterType: filterType ?? this.filterType,
      searchQuery: searchQuery ?? this.searchQuery,
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

  void setFilter(ClientGroupType? type) {
    // Manually create a new state to ensure nullable filterType is handled correctly
    state = ClientGroupsState(
      groups: state.groups,
      isLoading: state.isLoading,
      error: state.error,
      searchQuery: state.searchQuery,
      filterType: type, // Directly assign the new value
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> createGroup(ClientGroup group) async {
    try {
      await ApiService.createClientGroup(group);
      fetchGroups(); // Refresh the list
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> updateGroup(ClientGroup group) async {
    try {
      await ApiService.updateClientGroup(group);
      fetchGroups(); // Refresh the list
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteGroup(int groupId) async {
    try {
      await ApiService.deleteClientGroup(groupId);
      fetchGroups(); // Refresh the list
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
}

final clientGroupsProvider = NotifierProvider<ClientGroupsNotifier, ClientGroupsState>(ClientGroupsNotifier.new);

// Derived provider for the filtered and searched list of groups
final filteredGroupsProvider = Provider<List<ClientGroup>>((ref) {
  final state = ref.watch(clientGroupsProvider);
  final groups = state.groups;
  final filterType = state.filterType;
  final searchQuery = state.searchQuery.toLowerCase();

  List<ClientGroup> filteredGroups = groups;

  // Apply type filter
  if (filterType != null) {
    filteredGroups = filteredGroups.where((group) => group.type == filterType).toList();
  }

  // Apply search query
  if (searchQuery.isNotEmpty) {
    filteredGroups = filteredGroups.where((group) {
      return group.name.toLowerCase().contains(searchQuery);
    }).toList();
  }

  return filteredGroups;
});

