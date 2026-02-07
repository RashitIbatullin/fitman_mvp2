import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:fitman_app/modules/equipment/providers/equipment/equipment_provider.dart';
import 'package:fitman_app/modules/equipment/models/equipment/equipment_item.model.dart';
import 'package:fitman_app/modules/equipment/models/equipment/equipment_status.enum.dart';
import 'package:fitman_app/modules/rooms/providers/room/room_provider.dart'; // For room dropdown
import 'package:fitman_app/modules/rooms/models/room/room.model.dart'; // For room dropdown
import 'package:fitman_app/modules/equipment/models/equipment/equipment_type.model.dart'; // For type dropdown

class EquipmentItemEditScreen extends ConsumerStatefulWidget {
  final String? itemId; // For existing item
  final EquipmentItem? equipmentItem; // For pre-filling existing

  const EquipmentItemEditScreen({
    super.key,
    this.itemId,
    this.equipmentItem,
  });

  @override
  ConsumerState<EquipmentItemEditScreen> createState() =>
      _EquipmentItemEditScreenState();
}

class _EquipmentItemEditScreenState
    extends ConsumerState<EquipmentItemEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _inventoryNumberController;
  late TextEditingController _serialNumberController;
  late TextEditingController _modelController;
  late TextEditingController _manufacturerController;
  late TextEditingController _placementNoteController;
  late EquipmentStatus _selectedStatus;
  late int _conditionRating;
  late TextEditingController _conditionNotesController;
  late TextEditingController _lastMaintenanceDateController;
  late TextEditingController _nextMaintenanceDateController;
  late TextEditingController _maintenanceNotesController;
  late TextEditingController _purchaseDateController;
  late TextEditingController _purchasePriceController;
  late TextEditingController _supplierController;
  late TextEditingController _warrantyMonthsController;
  late TextEditingController _usageHoursController;
  late TextEditingController _lastUsedDateController;

  EquipmentType? _selectedEquipmentType;
  Room? _selectedRoom;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _inventoryNumberController = TextEditingController();
    _serialNumberController = TextEditingController();
    _modelController = TextEditingController();
    _manufacturerController = TextEditingController();
    _placementNoteController = TextEditingController();
    _selectedStatus = EquipmentStatus.available; // Default
    _conditionRating = 5; // Default
    _conditionNotesController = TextEditingController();
    _lastMaintenanceDateController = TextEditingController();
    _nextMaintenanceDateController = TextEditingController();
    _maintenanceNotesController = TextEditingController();
    _purchaseDateController = TextEditingController();
    _purchasePriceController = TextEditingController();
    _supplierController = TextEditingController();
    _warrantyMonthsController = TextEditingController();
    _usageHoursController = TextEditingController(text: '0'); // Default
    _lastUsedDateController = TextEditingController();

    if (widget.equipmentItem != null) {
      _populateForm(widget.equipmentItem!);
    } else if (widget.itemId != null) {
      _loadEquipmentItem();
    }
  }

  @override
  void dispose() {
    _inventoryNumberController.dispose();
    _serialNumberController.dispose();
    _modelController.dispose();
    _manufacturerController.dispose();
    _placementNoteController.dispose();
    _conditionNotesController.dispose();
    _lastMaintenanceDateController.dispose();
    _nextMaintenanceDateController.dispose();
    _maintenanceNotesController.dispose();
    _purchaseDateController.dispose();
    _purchasePriceController.dispose();
    _supplierController.dispose();
    _warrantyMonthsController.dispose();
    _usageHoursController.dispose();
    _lastUsedDateController.dispose();
    super.dispose();
  }

  void _populateForm(EquipmentItem item) {
    _inventoryNumberController.text = item.inventoryNumber;
    _serialNumberController.text = item.serialNumber ?? '';
    _modelController.text = item.model ?? '';
    _manufacturerController.text = item.manufacturer ?? '';
    _placementNoteController.text = item.placementNote ?? '';
    _selectedStatus = item.status;
    _conditionRating = item.conditionRating;
    _conditionNotesController.text = item.conditionNotes ?? '';
    _lastMaintenanceDateController.text =
        item.lastMaintenanceDate?.toLocal().toIso8601String().substring(0, 10) ?? '';
    _nextMaintenanceDateController.text =
        item.nextMaintenanceDate?.toLocal().toIso8601String().substring(0, 10) ?? '';
    _maintenanceNotesController.text = item.maintenanceNotes ?? '';
    _purchaseDateController.text =
        item.purchaseDate?.toLocal().toIso8601String().substring(0, 10) ?? '';
    _purchasePriceController.text = item.purchasePrice?.toString() ?? '';
    _supplierController.text = item.supplier ?? '';
    _warrantyMonthsController.text = item.warrantyMonths?.toString() ?? '';
    _usageHoursController.text = item.usageHours.toString();
    _lastUsedDateController.text =
        item.lastUsedDate?.toLocal().toIso8601String().substring(0, 10) ?? '';

    // Set selected type and room
    ref.read(equipmentTypeByIdProvider(item.typeId)).whenData((type) {
      setState(() {
        _selectedEquipmentType = type;
      });
    });
    if (item.roomId != null) {
      ref.read(roomByIdProvider(item.roomId!)).whenData((room) {
        setState(() {
          _selectedRoom = room;
        });
      });
    }
  }

  Future<void> _loadEquipmentItem() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final item = await ref.read(equipmentItemByIdProvider(widget.itemId!).future);
      _populateForm(item);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      controller.text = picked.toLocal().toIso8601String().substring(0, 10);
    }
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedEquipmentType == null) {
      setState(() => _errorMessage = 'Пожалуйста, выберите тип оборудования.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final isCreating = widget.itemId == null && widget.equipmentItem == null;

    final equipmentItem = EquipmentItem(
      id: isCreating ? '' : widget.itemId!, // ID is empty for new, or existing for update
      typeId: _selectedEquipmentType!.id,
      inventoryNumber: _inventoryNumberController.text,
      serialNumber: _serialNumberController.text.isEmpty ? null : _serialNumberController.text,
      model: _modelController.text.isEmpty ? null : _modelController.text,
      manufacturer: _manufacturerController.text.isEmpty ? null : _manufacturerController.text,
      roomId: _selectedRoom?.id,
      placementNote: _placementNoteController.text.isEmpty ? null : _placementNoteController.text,
      status: _selectedStatus,
      conditionRating: _conditionRating,
      conditionNotes: _conditionNotesController.text.isEmpty ? null : _conditionNotesController.text,
      lastMaintenanceDate: _lastMaintenanceDateController.text.isEmpty
          ? null
          : DateTime.parse(_lastMaintenanceDateController.text),
      nextMaintenanceDate: _nextMaintenanceDateController.text.isEmpty
          ? null
          : DateTime.parse(_nextMaintenanceDateController.text),
      maintenanceNotes: _maintenanceNotesController.text.isEmpty ? null : _maintenanceNotesController.text,
      purchaseDate: _purchaseDateController.text.isEmpty
          ? null
          : DateTime.parse(_purchaseDateController.text),
      purchasePrice: _purchasePriceController.text.isEmpty
          ? null
          : double.tryParse(_purchasePriceController.text),
      supplier: _supplierController.text.isEmpty ? null : _supplierController.text,
      warrantyMonths: _warrantyMonthsController.text.isEmpty
          ? null
          : int.tryParse(_warrantyMonthsController.text),
      usageHours: int.tryParse(_usageHoursController.text) ?? 0,
      lastUsedDate: _lastUsedDateController.text.isEmpty
          ? null
          : DateTime.parse(_lastUsedDateController.text),
      photoUrls: widget.equipmentItem?.photoUrls ?? const [], // Keep existing photos for update
      archivedAt: widget.equipmentItem?.archivedAt, // Keep existing archived info
      archivedBy: widget.equipmentItem?.archivedBy,
      archivedReason: widget.equipmentItem?.archivedReason,
    );

    try {
      String message;
      if (isCreating) {
        await ApiService.createEquipmentItem(equipmentItem);
        message = 'Элемент оборудования успешно создан!';
      } else {
        await ApiService.updateEquipmentItem(widget.itemId!, equipmentItem);
        message = 'Элемент оборудования успешно обновлен!';
      }
      ref.invalidate(allEquipmentItemsProvider); // Refresh the list
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop(true); // Indicate success
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $_errorMessage'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final equipmentTypesAsync = ref.watch(allEquipmentTypesProvider);
    final roomsAsync = ref.watch(allRoomsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.itemId == null
              ? 'Создать элемент оборудования'
              : 'Редактировать элемент оборудования',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveForm,
            tooltip: 'Сохранить',
          ),
        ],
      ),
      body: _isLoading && widget.itemId != null && widget.equipmentItem == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    equipmentTypesAsync.when(
                      data: (types) => DropdownButtonFormField<EquipmentType>(
                        decoration: const InputDecoration(
                          labelText: 'Тип оборудования',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: _selectedEquipmentType,
                        items: types
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(type.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedEquipmentType = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Пожалуйста, выберите тип оборудования';
                          }
                          return null;
                        },
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (error, stack) => Text('Ошибка: $error'),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _inventoryNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Инвентарный номер',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Пожалуйста, введите инвентарный номер';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _serialNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Серийный номер',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _modelController,
                      decoration: const InputDecoration(
                        labelText: 'Модель',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _manufacturerController,
                      decoration: const InputDecoration(
                        labelText: 'Производитель',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    roomsAsync.when(
                      data: (rooms) => DropdownButtonFormField<Room>(
                        decoration: const InputDecoration(
                          labelText: 'Помещение',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: _selectedRoom,
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Не назначено')),
                          ...rooms.map(
                                (room) => DropdownMenuItem(
                              value: room,
                              child: Text(room.name),
                            ),
                          ).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedRoom = value;
                          });
                        },
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (error, stack) => Text('Ошибка: $error'),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _placementNoteController,
                      decoration: const InputDecoration(
                        labelText: 'Местоположение/Примечания',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    DropdownButtonFormField<EquipmentStatus>(
                      decoration: const InputDecoration(
                        labelText: 'Статус',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: _selectedStatus,
                      items: EquipmentStatus.values
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(status.displayName),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Пожалуйста, выберите статус';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Оценка состояния (1-5)',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: _conditionRating,
                      items: List.generate(5, (index) => index + 1)
                          .map(
                            (rating) => DropdownMenuItem(
                              value: rating,
                              child: Text('$rating'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _conditionRating = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Пожалуйста, выберите оценку';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _conditionNotesController,
                      decoration: const InputDecoration(
                        labelText: 'Заметки о состоянии',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _lastMaintenanceDateController,
                      decoration: InputDecoration(
                        labelText: 'Дата последнего ТО',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () =>
                              _selectDate(context, _lastMaintenanceDateController),
                        ),
                      ),
                      readOnly: true,
                      onTap: () =>
                          _selectDate(context, _lastMaintenanceDateController),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _nextMaintenanceDateController,
                      decoration: InputDecoration(
                        labelText: 'Дата следующего ТО',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () =>
                              _selectDate(context, _nextMaintenanceDateController),
                        ),
                      ),
                      readOnly: true,
                      onTap: () =>
                          _selectDate(context, _nextMaintenanceDateController),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _maintenanceNotesController,
                      decoration: const InputDecoration(
                        labelText: 'Заметки по ТО',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _purchaseDateController,
                      decoration: InputDecoration(
                        labelText: 'Дата покупки',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () =>
                              _selectDate(context, _purchaseDateController),
                        ),
                      ),
                      readOnly: true,
                      onTap: () =>
                          _selectDate(context, _purchaseDateController),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _purchasePriceController,
                      decoration: const InputDecoration(
                        labelText: 'Цена покупки',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _supplierController,
                      decoration: const InputDecoration(
                        labelText: 'Поставщик',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _warrantyMonthsController,
                      decoration: const InputDecoration(
                        labelText: 'Гарантия (мес.)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _usageHoursController,
                      decoration: const InputDecoration(
                        labelText: 'Часы использования',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _lastUsedDateController,
                      decoration: InputDecoration(
                        labelText: 'Дата последнего использования',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () =>
                              _selectDate(context, _lastUsedDateController),
                        ),
                      ),
                      readOnly: true,
                      onTap: () =>
                          _selectDate(context, _lastUsedDateController),
                    ),
                    const SizedBox(height: 24.0),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    Center(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveForm,
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Сохранить'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}