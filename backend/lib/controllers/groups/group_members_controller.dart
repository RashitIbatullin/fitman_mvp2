import '../../config/database.dart';
import '../../models/groups/client_group_member.dart';

class GroupMembersController {
  GroupMembersController(this._db);

  final Database _db;

  Future<List<ClientGroupMember>> getGroupMembers(int groupId) async {
    return await _db.getGroupMembers(groupId);
  }

  Future<void> addGroupMember(int groupId, int clientId, int addedById) async {
    await _db.addGroupMember(groupId, clientId, addedById);
  }

  Future<void> removeGroupMember(int groupId, int clientId) async {
    await _db.removeGroupMember(groupId, clientId);
  }
}
