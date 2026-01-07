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
  final int? trainerId;
  final int? instructorId;
  final int? managerId;

  const TrainingGroupFilter({
    this.searchQuery = '',
    this.groupTypeId,
    this.isActive,
    this.isArchived,
    this.trainerId,
    this.instructorId,
    this.managerId,
  });

  @override
  List<Object?> get props => [searchQuery, groupTypeId, isActive, isArchived, trainerId, instructorId, managerId];
}

@Riverpod(keepAlive: true)
class TrainingGroups extends _$TrainingGroups {
  @override
  Future<List<TrainingGroup>> build({
    String searchQuery = '',
    int? groupTypeId,
    bool? isActive,
    bool? isArchived,
    int? trainerId,
    int? instructorId,
    int? managerId,
  }) async {
    // Pass ALL filter parameters to the API service
    final filteredGroups = await ApiService.getAllTrainingGroups(
      searchQuery: searchQuery,
      groupTypeId: groupTypeId,
      isActive: isActive,
      isArchived: isArchived,
      trainerId: trainerId,
      instructorId: instructorId,
      managerId: managerId,
    );

    // No more client-side filtering needed
    return filteredGroups;
  }

  Future<void> createTrainingGroup(TrainingGroup group) async {
    state = const AsyncValue.loading();
    try {
      await ApiService.createTrainingGroup(group);
      ref.invalidate(trainingGroupsProvider(
        searchQuery: '', // Invalidate with default or relevant filters
        groupTypeId: null,
        isActive: null,
        isArchived: null,
        trainerId: null,
        instructorId: null,
        managerId: null,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateTrainingGroup(TrainingGroup group) async {
    state = const AsyncValue.loading();
    try {
      await ApiService.updateTrainingGroup(group);
      ref.invalidate(trainingGroupsProvider(
        searchQuery: '', // Invalidate with default or relevant filters
        groupTypeId: null,
        isActive: null,
        isArchived: null,
        trainerId: null,
        instructorId: null,
        managerId: null,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteTrainingGroup(int id) async {
    state = const AsyncValue.loading();
    try {
      await ApiService.deleteTrainingGroup(id);
      ref.invalidate(trainingGroupsProvider(
        searchQuery: '', // Invalidate with default or relevant filters
        groupTypeId: null,
        isActive: null,
        isArchived: null,
        trainerId: null,
        instructorId: null,
        managerId: null,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

@Riverpod(keepAlive: true)
Future<List<TrainingGroupType>> trainingGroupTypes(Ref ref) async {
  return ApiService.getAllTrainingGroupTypes();
}