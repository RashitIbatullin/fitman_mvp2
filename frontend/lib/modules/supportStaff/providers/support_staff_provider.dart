import 'package:fitman_app/services/api_service.dart';
import 'package:fitman_app/modules/supportStaff/models/support_staff.model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'support_staff_provider.g.dart';

@riverpod
class SupportStaffNotifier extends _$SupportStaffNotifier {
  @override
  Future<void> build() async {
    return;
  }

  Future<void> archiveStaff(String id, String reason) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ApiService.archiveSupportStaff(id, reason);
      ref.invalidate(allSupportStaffProvider);
    });
  }

  Future<void> unarchiveStaff(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ApiService.unarchiveSupportStaff(id);
      ref.invalidate(allSupportStaffProvider);
    });
  }
}

@riverpod
Future<List<SupportStaff>> allSupportStaff(Ref ref, {bool includeArchived = false}) async {
  return ApiService.getAllSupportStaff(isArchived: includeArchived);
}

@riverpod
Future<SupportStaff> supportStaffById(Ref ref, String id) async {
  return ApiService.getSupportStaffById(id);
}
