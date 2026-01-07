import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:fitman_app/models/groups/training_group.dart';
import 'package:fitman_app/models/groups/training_group_type.dart';
import 'package:equatable/equatable.dart';

part 'training_groups_provider.g.dart';

// Define a filter class for TrainingGroups
class TrainingGroupFilter extends Equatable {
  final String searchQuery;
  final int? groupTypeId;
  final bool? isActive;
  final bool? isArchived;

  const TrainingGroupFilter({
    this.searchQuery = '',
    this.groupTypeId,
    this.isActive,
    this.isArchived,
  });

  @override
  List<Object?> get props => [searchQuery, groupTypeId, isActive, isArchived];
}

@Riverpod(keepAlive: true)
class TrainingGroups extends _$TrainingGroups {
  @override
  Future<List<TrainingGroup>> build({
    String searchQuery = '',
    int? groupTypeId,
    bool? isActive,
    bool? isArchived,
  }) async {
    // Pass the filter parameters to the API service
    final allGroups = await ApiService.getAllTrainingGroups(
      isActive: isActive,
      isArchived: isArchived,
    );

    // Apply client-side filtering for searchQuery and groupTypeId
    final filteredGroups = allGroups.where((group) {
      final nameMatches = group.name.toLowerCase().contains(searchQuery.toLowerCase());
      final typeMatches = groupTypeId == null || group.trainingGroupTypeId == groupTypeId;
      return nameMatches && typeMatches;
    }).toList();

    return filteredGroups;
  }

  Future<void> createTrainingGroup(TrainingGroup group) async {
    state = const AsyncValue.loading();
    try {
      await ApiService.createTrainingGroup(group);
      ref.invalidate(trainingGroupsProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateTrainingGroup(TrainingGroup group) async {
    state = const AsyncValue.loading();
    try {
      await ApiService.updateTrainingGroup(group);
      ref.invalidate(trainingGroupsProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteTrainingGroup(int id) async {
    state = const AsyncValue.loading();
    try {
      await ApiService.deleteTrainingGroup(id);
      ref.invalidate(trainingGroupsProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

@Riverpod(keepAlive: true)
Future<List<TrainingGroupType>> trainingGroupTypes(Ref ref) async {
  return ApiService.getAllTrainingGroupTypes();
}