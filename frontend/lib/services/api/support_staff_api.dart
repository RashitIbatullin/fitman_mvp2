import 'package:fitman_app/modules/supportStaff/models/competency.model.dart';
import 'package:fitman_app/modules/supportStaff/models/support_staff.model.dart';

import 'base_api.dart';

class SupportStaffApiService extends BaseApiService {
  SupportStaffApiService({super.client});

  Future<List<SupportStaff>> getAllSupportStaff({bool? isArchived}) async {
    final queryParams = <String, String>{};
    if (isArchived != null) queryParams['includeArchived'] = isArchived.toString();

    final data = await get('/api/support-staff',
        queryParams: queryParams.isNotEmpty ? queryParams : null);
    return (data as List).map((json) => SupportStaff.fromJson(json)).toList();
  }

  Future<SupportStaff> getSupportStaffById(String id) async {
    final data = await get('/api/support-staff/$id');
    return SupportStaff.fromJson(data);
  }

  Future<SupportStaff> createSupportStaff(SupportStaff staff) async {
    final data = await post('/api/support-staff', body: staff.toJson());
    return SupportStaff.fromJson(data);
  }

  Future<SupportStaff> updateSupportStaff(String id, SupportStaff staff) async {
    final data = await put('/api/support-staff/$id', body: staff.toJson());
    return SupportStaff.fromJson(data);
  }

  Future<void> archiveSupportStaff(String id, String reason) async {
    await delete('/api/support-staff/$id', body: {'reason': reason});
  }

  Future<void> unarchiveSupportStaff(String id) async {
    await put('/api/support-staff/$id/unarchive', body: {});
  }

  Future<List<Competency>> getCompetencies(String staffId) async {
    final data = await get('/api/support-staff/$staffId/competencies');
    return (data as List).map((json) => Competency.fromJson(json)).toList();
  }

  Future<Competency> addCompetency(String staffId, Competency competency) async {
    final data = await post('/api/support-staff/$staffId/competencies',
        body: competency.toJson());
    return Competency.fromJson(data);
  }

  Future<void> deleteCompetency(String staffId, String competencyId) async {
    await delete('/api/support-staff/$staffId/competencies/$competencyId');
  }
}
