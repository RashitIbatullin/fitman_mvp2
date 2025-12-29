import '../../config/database.dart';
import '../../models/groups/client_group.dart';

class ClientGroupsController {
  ClientGroupsController(this._db);

  final Database _db;

  Future<List<ClientGroup>> getAllGroups() async {
    return await _db.getAllClientGroups();
  }

  Future<ClientGroup?> getGroupById(int id) async {
    return await _db.getClientGroupById(id);
  }

  Future<ClientGroup> createGroup(ClientGroup group, int creatorId) async {
    return await _db.createClientGroup(group, creatorId);
  }

  Future<ClientGroup> updateGroup(ClientGroup group, int updaterId) async {
    return await _db.updateClientGroup(group, updaterId);
  }

  Future<void> deleteGroup(int id, int archiverId) async {
    await _db.deleteClientGroup(id, archiverId);
  }
}
