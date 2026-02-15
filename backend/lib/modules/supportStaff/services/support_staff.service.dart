import 'package:fitman_backend/modules/supportStaff/models/competency.dart';
import 'package:fitman_backend/modules/supportStaff/models/support_staff.dart';
import 'package:fitman_backend/modules/supportStaff/repositories/support_staff.repository.dart';

class SupportStaffService {
  SupportStaffService(this._supportStaffRepository);

  final SupportStaffRepository _supportStaffRepository;

  Future<List<SupportStaff>> getAll({bool includeArchived = false}) {
    return _supportStaffRepository.getAll(includeArchived: includeArchived);
  }

  Future<SupportStaff> getById(int id) {
    return _supportStaffRepository.getById(id);
  }

  Future<SupportStaff> create(SupportStaff supportStaff, String userId) {
    return _supportStaffRepository.create(supportStaff, userId);
  }

  Future<SupportStaff> update(int id, SupportStaff supportStaff, String userId) {
    return _supportStaffRepository.update(id, supportStaff, userId);
  }

  Future<void> archive(int id, String userId, String reason) {
    return _supportStaffRepository.archive(id, userId, reason);
  }

  Future<void> unarchive(int id) {
    return _supportStaffRepository.unarchive(id);
  }

  Future<List<Competency>> getCompetencies(int staffId) {
    return _supportStaffRepository.getCompetencies(staffId);
  }

  Future<Competency> addCompetency(Competency competency) {
    return _supportStaffRepository.addCompetency(competency);
  }

  Future<void> deleteCompetency(int competencyId) {
    return _supportStaffRepository.deleteCompetency(competencyId);
  }
}