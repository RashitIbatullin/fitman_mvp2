import 'package:flutter/material.dart';

class ManualGroupEditForm extends StatefulWidget {
  const ManualGroupEditForm({super.key});

  @override
  State<ManualGroupEditForm> createState() => _ManualGroupEditFormState();
}

class _ManualGroupEditFormState extends State<ManualGroupEditForm> {
  final List<String> _memberIds = [];
  final TextEditingController _newMemberIdController = TextEditingController();

  void _addMember() {
    if (_newMemberIdController.text.isNotEmpty) {
      setState(() {
        _memberIds.add(_newMemberIdController.text.trim());
        _newMemberIdController.clear();
      });
    }
  }

  void _removeMember(int index) {
    setState(() {
      _memberIds.removeAt(index);
    });
  }

  @override
  void dispose() {
    _newMemberIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Управление участниками вручную',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _memberIds.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Client ID: ${_memberIds[index]}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle),
                    onPressed: () => _removeMember(index),
                  ),
                );
              },
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newMemberIdController,
                    decoration: const InputDecoration(
                      hintText: 'Добавить ID клиента',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addMember,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'TODO: Реализовать выбор клиентов из списка и интеграцию с ClientGroupMembersController',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
