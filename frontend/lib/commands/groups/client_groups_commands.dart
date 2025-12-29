import '../../models/groups/client_group.dart';

// Base command class, assuming a Result type exists
abstract class Command<T> {
  Future<T> execute();
}

class CreateGroupCommand implements Command<ClientGroup> {
  CreateGroupCommand(this.group);
  final ClientGroup group;

  @override
  Future<ClientGroup> execute() async {
    // TODO: Implement API call to create a group
    print('Executing CreateGroupCommand for ${group.name}');
    return group;
  }
}

class UpdateGroupCommand implements Command<ClientGroup> {
  UpdateGroupCommand(this.group);
  final ClientGroup group;

  @override
  Future<ClientGroup> execute() async {
    // TODO: Implement API call to update a group
    print('Executing UpdateGroupCommand for ${group.name}');
    return group;
  }
}

class DeleteGroupCommand implements Command<void> {
  DeleteGroupCommand(this.groupId);
  final String groupId;

  @override
  Future<void> execute() async {
    // TODO: Implement API call to delete a group
    print('Executing DeleteGroupCommand for $groupId');
  }
}
