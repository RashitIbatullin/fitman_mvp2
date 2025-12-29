import '../../config/database.dart';
import '../../models/groups/client_group_member.dart';

class ClientGroupMembersController {
  ClientGroupMembersController(this._db);

  final Database _db;

  Future<List<ClientGroupMember>> getMembers(int groupId) async {
    return await _db.getGroupMembers(groupId);
  }

  Future<void> addMember(int groupId, int clientId, int addedById) async {
    await _db.addGroupMember(groupId, clientId, addedById);
  }

  Future<void> removeMember(int groupId, int clientId) async {
    await _db.removeGroupMember(groupId, clientId);
  }
}
