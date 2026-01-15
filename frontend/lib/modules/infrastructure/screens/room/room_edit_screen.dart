import 'package:fitman_app/modules/infrastructure/models/room/room.model.dart';
import 'package:fitman_app/modules/infrastructure/models/room/room_type.enum.dart';
import 'package:fitman_app/modules/infrastructure/providers/building_provider.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/room_utils.dart';
import '../../providers/room_provider.dart'; // Import from the new location

class RoomEditScreen extends ConsumerStatefulWidget {
  final Room room;
  const RoomEditScreen({super.key, required this.room});

  @override
  ConsumerState<RoomEditScreen> createState() => _RoomEditScreenState();
}

class _RoomEditScreenState extends ConsumerState<RoomEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _roomNumberController;
  late TextEditingController _floorController;
  late TextEditingController _maxCapacityController;
  late TextEditingController _areaController;
  late TextEditingController _maintenanceNoteController;

  String? _selectedBuildingId;
  late RoomType _selectedRoomType;
  late bool _hasMirrors;
  late bool _hasSoundSystem;
  late bool _isUnderMaintenance;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.room.name);
    _descriptionController = TextEditingController(text: widget.room.description);
    _roomNumberController = TextEditingController(text: widget.room.roomNumber);
    _floorController = TextEditingController(text: widget.room.floor);
    _maxCapacityController = TextEditingController(text: widget.room.maxCapacity.toString());
    _areaController = TextEditingController(text: widget.room.area?.toString());
    _maintenanceNoteController = TextEditingController(text: widget.room.maintenanceNote);

    _selectedBuildingId = widget.room.buildingId;
    _selectedRoomType = widget.room.type;
    _hasMirrors = widget.room.hasMirrors;
    _hasSoundSystem = widget.room.hasSoundSystem;
    _isUnderMaintenance = widget.room.isUnderMaintenance;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _roomNumberController.dispose();
    _floorController.dispose();
    _maxCapacityController.dispose();
    _areaController.dispose();
    _maintenanceNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buildingsAsync = ref.watch(allBuildingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактировать помещение'),
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
                decoration: const InputDecoration(labelText: 'Название *'),
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
              ),
              TextFormField(
                controller: _roomNumberController,
                decoration: const InputDecoration(labelText: 'Номер комнаты'),
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
              DropdownButtonFormField<RoomType>(
                initialValue: _selectedRoomType,
                decoration: const InputDecoration(labelText: 'Тип помещения'),
                items: RoomType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.displayName),
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
                controller: _floorController,
                decoration: const InputDecoration(labelText: 'Этаж'),
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
              CheckboxListTile(
                title: const Text('Есть зеркала'),
                value: _hasMirrors,
                onChanged: (value) {
                  setState(() {
                    _hasMirrors = value!;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Есть аудиосистема'),
                value: _hasSoundSystem,
                onChanged: (value) {
                  setState(() {
                    _hasSoundSystem = value!;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('На ремонте'),
                value: _isUnderMaintenance,
                onChanged: (value) {
                  setState(() {
                    _isUnderMaintenance = value!;
                  });
                },
              ),
              if (_isUnderMaintenance)
                TextFormField(
                  controller: _maintenanceNoteController,
                  decoration:
                      const InputDecoration(labelText: 'Причина ремонта'),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateRoom,
                child: const Text('Сохранить'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateRoom() async {
    if (_formKey.currentState!.validate()) {
      final updatedRoom = widget.room.copyWith(
        name: _nameController.text,
        description: _descriptionController.text,
        roomNumber: _roomNumberController.text,
        type: _selectedRoomType,
        floor: _floorController.text,
        buildingId: _selectedBuildingId,
        maxCapacity: int.tryParse(_maxCapacityController.text) ?? 0,
        area: double.tryParse(_areaController.text),
        hasMirrors: _hasMirrors,
        hasSoundSystem: _hasSoundSystem,
        isUnderMaintenance: _isUnderMaintenance,
        maintenanceNote: _maintenanceNoteController.text,
      );

      try {
        await ApiService.updateRoom(updatedRoom.id, updatedRoom);
        ref.invalidate(allRoomsProvider); // Invalidate provider to refetch updated rooms
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка при обновлении помещения: $e')),
          );
        }
      }
    }
  }
}
