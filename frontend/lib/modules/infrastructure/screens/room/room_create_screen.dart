import 'package:fitman_app/modules/infrastructure/models/room/room.model.dart';
import 'package:fitman_app/modules/infrastructure/models/room/room_type.enum.dart';
import 'package:fitman_app/modules/infrastructure/providers/building_provider.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/room_utils.dart';

class RoomCreateScreen extends ConsumerStatefulWidget {
  const RoomCreateScreen({super.key});

  @override
  ConsumerState<RoomCreateScreen> createState() => _RoomCreateScreenState();
}

class _RoomCreateScreenState extends ConsumerState<RoomCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _roomNumberController = TextEditingController(); // New controller
  final _floorController = TextEditingController();
  final _maxCapacityController = TextEditingController();
  final _areaController = TextEditingController();

  String? _selectedBuildingId;
  RoomType _selectedRoomType = RoomType.groupHall;

  @override
  Widget build(BuildContext context) {
    final buildingsAsync = ref.watch(allBuildingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Создать помещение'),
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
                decoration: const InputDecoration(labelText: 'Название'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите название';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<RoomType>(
                initialValue: _selectedRoomType,
                decoration: const InputDecoration(labelText: 'Тип помещения'),
                items: RoomType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(type.icon, size: 24),
                        const SizedBox(width: 10),
                        Text(type.displayName),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedRoomType = value;
                    });
                  }
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Описание'),
              ),
              TextFormField(
                controller: _maxCapacityController,
                decoration:
                    const InputDecoration(labelText: 'Макс. вместимость'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null &&
                      value.isNotEmpty &&
                      int.tryParse(value) == null) {
                    return 'Введите корректное число';
                  }
                  return null;
                },
              ),
              buildingsAsync.when(
                data: (buildings) => DropdownButtonFormField<String>(
                  initialValue: _selectedBuildingId,
                  decoration: const InputDecoration(labelText: 'Здание'),
                  items: buildings
                      .where((b) => b.archivedAt == null)
                      .map((building) {
                    return DropdownMenuItem<String>(
                      value: building.id,
                      child: Text(building.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBuildingId = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Выберите здание' : null,
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) =>
                    Text('Не удалось загрузить здания: $err'),
              ),
              TextFormField(
                controller: _floorController,
                decoration: const InputDecoration(labelText: 'Этаж'),
              ),
              TextFormField(
                controller: _roomNumberController,
                decoration: const InputDecoration(labelText: 'Номер комнаты'),
              ),
              TextFormField(
                controller: _areaController,
                decoration: const InputDecoration(labelText: 'Площадь (м²)'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value != null &&
                      value.isNotEmpty &&
                      double.tryParse(value) == null) {
                    return 'Введите корректное число';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createRoom,
                child: const Text('Сохранить'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createRoom() async {
    if (_formKey.currentState!.validate()) {
      final newRoom = Room(
        id: '', // ID will be generated by the backend
        name: _nameController.text,
        description: _descriptionController.text,
        roomNumber: _roomNumberController.text, // New field
        type: _selectedRoomType,
        floor: _floorController.text,
        buildingId: _selectedBuildingId,
        maxCapacity: int.tryParse(_maxCapacityController.text) ?? 0,
        area: double.tryParse(_areaController.text),
        photoUrls: [],
        workingDays: [], // Default to empty
      );

      try {
        await ApiService.createRoom(newRoom);
        // ref.refresh(allRoomsProvider); //This provider does not exist, so commenting out
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка при создании помещения: $e')),
          );
        }
      }
    }
  }
}

