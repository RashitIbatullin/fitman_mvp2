import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:fitman_app/models/groups/analytic_group.dart';
import 'package:equatable/equatable.dart';

part 'analytic_groups_provider.g.dart';

// Define a filter class for AnalyticGroups
class AnalyticGroupFilter extends Equatable {
  final String searchQuery;
  final bool? isArchived;

  const AnalyticGroupFilter({
    this.searchQuery = '',
    this.isArchived,
  });

  @override
  List<Object?> get props => [searchQuery, isArchived];
}

@Riverpod(keepAlive: true)
class AnalyticGroups extends _$AnalyticGroups {
  @override
  Future<List<AnalyticGroup>> build({
    String searchQuery = '',
    bool? isArchived,
  }) async {
    final allGroups = await ApiService.getAllAnalyticGroups(
      isArchived: isArchived,
    );

    // Apply client-side filtering for searchQuery
    final filteredGroups = allGroups.where((group) {
      final nameMatches = group.name.toLowerCase().contains(searchQuery.toLowerCase());
      return nameMatches;
    }).toList();

    return filteredGroups;
  }

  Future<void> createAnalyticGroup(AnalyticGroup group) async {
    state = const AsyncValue.loading();
    try {
      await ApiService.createAnalyticGroup(group);
      ref.invalidate(analyticGroupsProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateAnalyticGroup(AnalyticGroup group) async {
    state = const AsyncValue.loading();
    try {
      await ApiService.updateAnalyticGroup(group);
      ref.invalidate(analyticGroupsProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteAnalyticGroup(int id) async {
    state = const AsyncValue.loading();
    try {
      await ApiService.deleteAnalyticGroup(id);
      ref.invalidate(analyticGroupsProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}