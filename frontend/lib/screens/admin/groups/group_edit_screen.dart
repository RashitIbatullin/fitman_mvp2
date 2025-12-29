import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/groups/client_group.dart';
import '../../../models/groups/group_types.dart';
import '../../../providers/groups/client_groups_provider.dart';

class GroupEditScreen extends ConsumerStatefulWidget {
  final ClientGroup? group;

  const GroupEditScreen({super.key, this.group});

  @override
  ConsumerState<GroupEditScreen> createState() => _GroupEditScreenState();
}

class _GroupEditScreenState extends ConsumerState<GroupEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late ClientGroupType _selectedType;
  late bool _isAutoUpdate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.group?.name ?? '');
    _descriptionController = TextEditingController(text: widget.group?.description ?? '');
    _selectedType = widget.group?.type ?? ClientGroupType.custom;
    _isAutoUpdate = widget.group?.isAutoUpdate ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveGroup() async {
    if (_formKey.currentState!.validate()) {
      final newGroup = ClientGroup(
        id: widget.group?.id ?? 0, // 0 for new group, actual ID for existing
        name: _nameController.text.trim(),
        type: _selectedType,
        description: _descriptionController.text.trim(),
        isAutoUpdate: _isAutoUpdate,
      );

      final messenger = ScaffoldMessenger.of(context); // Capture context-dependent objects
      final navigator = Navigator.of(context);

      try {
        if (widget.group == null) {
          // Create new group
          await ref.read(clientGroupsProvider.notifier).createGroup(newGroup);
        } else {
          // Update existing group
          await ref.read(clientGroupsProvider.notifier).updateGroup(newGroup);
        }
        if (!mounted) return;
        navigator.pop();
      } catch (e) {
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(content: Text('Ошибка сохранения группы: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group == null ? 'Создать группу' : 'Редактировать группу'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Название группы'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите название группы';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Описание'),
                maxLines: 3,
              ),
              DropdownButtonFormField<ClientGroupType>(
                initialValue: _selectedType,
                decoration: const InputDecoration(labelText: 'Тип группы'),
                items: ClientGroupType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.name), // TODO: Localize enum names
                  );
                }).toList(),
                onChanged: (type) {
                  if (type != null) {
                    setState(() {
                      _selectedType = type;
                    });
                  }
                },
              ),
              SwitchListTile(
                title: const Text('Автоматическое обновление'),
                value: _isAutoUpdate,
                onChanged: (value) {
                  setState(() {
                    _isAutoUpdate = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveGroup,
                child: const Text('Сохранить'),
              ),
              if (widget.group != null)
                ElevatedButton(
                  onPressed: () async {
                    if (widget.group == null || widget.group!.id == 0) return;
                    final messenger = ScaffoldMessenger.of(context); // Capture context-dependent objects
                    final navigator = Navigator.of(context);
                    try {
                      await ref.read(clientGroupsProvider.notifier).deleteGroup(widget.group!.id);
                      if (!mounted) return;
                      navigator.pop();
                    } catch (e) {
                      if (!mounted) return;
                      messenger.showSnackBar(
                        SnackBar(content: Text('Ошибка удаления группы: $e')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Удалить группу'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
