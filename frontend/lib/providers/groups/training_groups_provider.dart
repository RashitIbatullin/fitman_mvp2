import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Added import for Ref
import 'package:fitman_app/services/api_service.dart';
import 'package:fitman_app/models/groups/training_group.dart';
import 'package:fitman_app/models/groups/training_group_type.dart';

part 'training_groups_provider.g.dart';

@Riverpod(keepAlive: true)
class TrainingGroups extends _$TrainingGroups {
  @override
  Future<List<TrainingGroup>> build() async {
    return ApiService.getAllTrainingGroups();
  }

  Future<void> createTrainingGroup(TrainingGroup group) async {
    state = const AsyncValue.loading();
    try {
      await ApiService.createTrainingGroup(group);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateTrainingGroup(TrainingGroup group) async {
    state = const AsyncValue.loading();
    try {
      await ApiService.updateTrainingGroup(group);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteTrainingGroup(int id) async {
    state = const AsyncValue.loading();
    try {
      await ApiService.deleteTrainingGroup(id);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

@Riverpod(keepAlive: true)
Future<List<TrainingGroupType>> trainingGroupTypes(Ref ref) async {
  return ApiService.getAllTrainingGroupTypes();
}