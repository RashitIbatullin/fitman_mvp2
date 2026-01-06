import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/providers/groups/training_groups_provider.dart';
import 'package:fitman_app/models/groups/training_group.dart';
import 'package:fitman_app/widgets/groups/group_member_list.dart'; // For later use
import 'package:fitman_app/services/api_service.dart'; // For fetching users for dropdowns
import 'package:fitman_app/models/user_front.dart'; // For user dropdown
import 'package:intl/intl.dart'; // New import

class TrainingGroupEditScreen extends ConsumerStatefulWidget {
  final String? groupId;
  const TrainingGroupEditScreen({super.key, this.groupId});

  @override
  ConsumerState<TrainingGroupEditScreen> createState() => _TrainingGroupEditScreenState();
}

class _TrainingGroupEditScreenState extends ConsumerState<TrainingGroupEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  int? _selectedGroupTypeId;
  String? _selectedPrimaryTrainerId;
  String? _selectedPrimaryInstructorId;
  String? _selectedResponsibleManagerId;
  late TextEditingController _maxParticipantsController;
  late TextEditingController _currentParticipantsController;
  late DateTime _startDate;
  DateTime? _endDate;
  bool _isActive = true;
  String? _chatId; // Assuming chat_id is managed elsewhere or auto-generated

  TrainingGroup? _initialGroup;
  List<User> _trainers = [];
  List<User> _instructors = [];
  List<User> _managers = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _maxParticipantsController = TextEditingController();
    _currentParticipantsController = TextEditingController();
    _startDate = DateTime.now();
    _fetchUsers();

    if (widget.groupId != null) {
      _loadGroupData();
    } else {
      _maxParticipantsController.text = '15';
      _currentParticipantsController.text = '0';
    }
  }

  Future<void> _fetchUsers() async {
    try {
      final users = await ApiService.getUsers();
      setState(() {
        _trainers = users.where((u) => u.roles.any((r) => r.name == 'trainer')).toList();
        _instructors = users.where((u) => u.roles.any((r) => r.name == 'instructor')).toList();
        _managers = users.where((u) => u.roles.any((r) => r.name == 'manager')).toList();
      });
    } catch (e) {
      // Handle error
      print('Failed to fetch users: $e');
    }
  }

  Future<void> _loadGroupData() async {
    try {
      final group = await ApiService.getTrainingGroupById(widget.groupId!);
      if (!mounted) return; // Add check
      setState(() {
        _initialGroup = group;
        _nameController.text = group.name;
        _descriptionController.text = group.description ?? '';
        _selectedGroupTypeId = group.trainingGroupTypeId;
        _selectedPrimaryTrainerId = group.primaryTrainerId;
        _selectedPrimaryInstructorId = group.primaryInstructorId;
        _selectedResponsibleManagerId = group.responsibleManagerId;
        _maxParticipantsController.text = group.maxParticipants.toString();
        _currentParticipantsController.text = group.currentParticipants.toString();
        _startDate = group.startDate;
        _endDate = group.endDate;
        _isActive = group.isActive;
        _chatId = group.chatId;
      });
    } catch (e) {
      // Handle error
      print('Failed to load group data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load group: $e')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _maxParticipantsController.dispose();
    _currentParticipantsController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newGroup = TrainingGroup(
        id: widget.groupId ?? '', // ID will be assigned by backend for new groups
        name: _nameController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        trainingGroupTypeId: _selectedGroupTypeId!,
        primaryTrainerId: _selectedPrimaryTrainerId!,
        primaryInstructorId: _selectedPrimaryInstructorId,
        responsibleManagerId: _selectedResponsibleManagerId,
        maxParticipants: int.parse(_maxParticipantsController.text),
        currentParticipants: int.parse(_currentParticipantsController.text),
        startDate: _startDate,
        endDate: _endDate,
        isActive: _isActive,
        chatId: _chatId,
        clientIds: _initialGroup?.clientIds ?? [], // ClientIds are managed separately
      );

      try {
        if (widget.groupId == null) {
          // Create new group
          await ref.read(trainingGroupsProvider.notifier).createTrainingGroup(newGroup);
        } else {
          // Update existing group
          await ref.read(trainingGroupsProvider.notifier).updateTrainingGroup(newGroup);
        }
        if (!mounted) return; // Add check
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Группа успешно сохранена!')),
        );
        if (!mounted) return; // Add check
        Navigator.of(context).pop();
      } catch (e) {
        if (!mounted) return; // Add check
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка сохранения группы: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupId == null ? 'Создать тренировочную группу' : 'Редактировать тренировочную группу'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Название группы'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите название';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Описание'),
                maxLines: 3,
              ),
              ref.watch(trainingGroupTypesProvider).when(
                data: (types) => DropdownButtonFormField<int>(
                  initialValue: _selectedGroupTypeId,
                  decoration: const InputDecoration(labelText: 'Тип группы'),
                  items: types.map((type) {
                    return DropdownMenuItem(
                      value: type.id,
                      child: Text(type.title),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGroupTypeId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Пожалуйста, выберите тип группы';
                    }
                    return null;
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Ошибка: $err')),
              ),
              DropdownButtonFormField<String>(
                initialValue: _selectedPrimaryTrainerId,
                decoration: const InputDecoration(labelText: 'Основной тренер'),
                items: _trainers.map((user) {
                  return DropdownMenuItem(
                    value: user.id.toString(),
                    child: Text(user.fullName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPrimaryTrainerId = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, выберите основного тренера';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                initialValue: _selectedPrimaryInstructorId,
                decoration: const InputDecoration(labelText: 'Основной инструктор (опционально)'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Нет')),
                  ..._instructors.map((user) {
                    return DropdownMenuItem(
                      value: user.id.toString(),
                      child: Text(user.fullName),
                    );
                  }), // Removed .toList()
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedPrimaryInstructorId = value;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                initialValue: _selectedResponsibleManagerId,
                decoration: const InputDecoration(labelText: 'Ответственный менеджер (опционально)'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Нет')),
                  ..._managers.map((user) {
                    return DropdownMenuItem(
                      value: user.id.toString(),
                      child: Text(user.fullName),
                    );
                  }), // Removed .toList()
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedResponsibleManagerId = value;
                  });
                },
              ),
              TextFormField(
                controller: _maxParticipantsController,
                decoration: const InputDecoration(labelText: 'Макс. участников'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null) {
                    return 'Пожалуйста, введите число';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _currentParticipantsController,
                decoration: const InputDecoration(labelText: 'Тек. участников'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null) {
                    return 'Пожалуйста, введите число';
                  }
                  return null;
                },
              ),
              ListTile(
                title: Text('Дата начала: ${DateFormat('dd.MM.yyyy').format(_startDate)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _startDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _startDate = pickedDate;
                    });
                  }
                },
              ),
              ListTile(
                title: Text('Дата окончания: ${_endDate != null ? DateFormat('dd.MM.yyyy').format(_endDate!) : 'Не указана'}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _endDate ?? _startDate.add(const Duration(days: 365)),
                    firstDate: _startDate,
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _endDate = pickedDate;
                    });
                  }
                },
              ),
              SwitchListTile(
                title: const Text('Активна'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
              const Divider(),
              Text('Члены группы', style: Theme.of(context).textTheme.titleMedium),
              if (widget.groupId != null) ...[
                GroupMemberList(groupId: widget.groupId!), // Placeholder for member list widget
              ] else ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text('Членов можно добавить после создания группы.'),
                ),
              ],
              const Divider(),
              Text('Расписание группы', style: Theme.of(context).textTheme.titleMedium),
              if (widget.groupId != null) ...[
                // TODO: Implement Group Schedule Slots management widget
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text('Расписание можно настроить после создания группы.'),
                ),
              ] else ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text('Расписание можно настроить после создания группы.'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}