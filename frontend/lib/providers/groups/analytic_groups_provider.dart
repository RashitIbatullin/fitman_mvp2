import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:fitman_app/models/groups/analytic_group.dart';

part 'analytic_groups_provider.g.dart';

@Riverpod(keepAlive: true)
class AnalyticGroups extends _$AnalyticGroups {
  @override
  Future<List<AnalyticGroup>> build() async {
    return ApiService.getAllAnalyticGroups();
  }

  Future<void> createAnalyticGroup(AnalyticGroup group) async {
    state = const AsyncValue.loading();
    try {
      await ApiService.createAnalyticGroup(group);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateAnalyticGroup(AnalyticGroup group) async {
    state = const AsyncValue.loading();
    try {
      await ApiService.updateAnalyticGroup(group);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteAnalyticGroup(String id) async {
    state = const AsyncValue.loading();
    try {
      await ApiService.deleteAnalyticGroup(id);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}