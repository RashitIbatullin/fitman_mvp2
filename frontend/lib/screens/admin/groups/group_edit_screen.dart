import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/groups/client_group.dart';
import '../../../models/groups/group_types.dart';
import '../../../providers/groups/client_groups_provider.dart';
import '../../../providers/groups/group_members_provider.dart';
import 'auto_group_edit_form.dart'; // Import the auto group form
import 'manual_group_edit_form.dart'; // Import the manual group form
import '../../../widgets/groups/group_type_badge.dart'; // Import GroupTypeBadge for localized names

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

    // If editing an existing group, fetch its members
    if (widget.group != null && widget.group!.id != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(groupMembersProvider.notifier).fetchMembers(widget.group!.id);
      });
    }
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
        // Correct logic: check if the group is new based on its ID
        if (widget.group?.id == null || widget.group!.id == 0) {
          print('--- Saving new group ---');
          // Create new group
          await ref.read(clientGroupsProvider.notifier).createGroup(newGroup);
        } else {
          print('--- Updating existing group with id: ${newGroup.id} ---');
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
    // Watch the members provider
    final groupMembersState = ref.watch(groupMembersProvider);
    final bool hasMembers = groupMembersState.members.isNotEmpty;

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
                decoration: const InputDecoration(labelText: 'Название группы *'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите название группы';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Описание *'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите описание';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<ClientGroupType>(
                initialValue: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Тип группы *',
                  helperText: hasMembers ? 'Нельзя изменить тип группы, пока в ней есть участники.' : null,
                ),
                items: ClientGroupType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(GroupTypeBadge.getLocalizedTypeName(type)),
                  );
                }).toList(),
                onChanged: hasMembers ? null : (type) { // Disable if group has members
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
                onChanged: hasMembers ? null : (value) { // Also disable this switch
                  setState(() {
                    _isAutoUpdate = value;
                  });
                },
              ),
              // Member management UI should only be shown for existing groups
              if (widget.group != null && widget.group!.id != 0)
                if (_isAutoUpdate)
                  const AutoGroupEditForm() // Assuming this will also need the group
                else
                  ManualGroupEditForm(group: widget.group!),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveGroup,
                child: const Text('Сохранить'),
              ),
              if (widget.group != null)
                ElevatedButton(
                  onPressed: () async {
                    if (widget.group == null || widget.group!.id == 0) return;
                    
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);

                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Подтверждение'),
                        content: const Text('Вы уверены, что хотите удалить группу? Это действие нельзя отменить.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Отмена'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Удалить'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      try {
                        await ref.read(clientGroupsProvider.notifier).deleteGroup(widget.group!.id);
                        if (!navigator.mounted) return;
                        navigator.pop();
                      } catch (e) {
                        if (!messenger.mounted) return;
                        messenger.showSnackBar(
                          SnackBar(content: Text('Ошибка удаления группы: $e')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.errorContainer),
                  child: const Text('Удалить группу'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
