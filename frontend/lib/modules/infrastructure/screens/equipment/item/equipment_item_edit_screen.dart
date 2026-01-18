import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/equipment/equipment_item.model.dart';
// Import other necessary models and services

class EquipmentItemEditScreen extends ConsumerStatefulWidget {
  const EquipmentItemEditScreen({super.key, required this.equipmentItem});

  final EquipmentItem equipmentItem;

  @override
  ConsumerState<EquipmentItemEditScreen> createState() =>
      _EquipmentItemEditScreenState();
}

class _EquipmentItemEditScreenState
    extends ConsumerState<EquipmentItemEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _inventoryNumberController;
  late TextEditingController _modelController;
  late TextEditingController _manufacturerController;
  // Add other controllers as needed

  @override
  void initState() {
    super.initState();
    _inventoryNumberController =
        TextEditingController(text: widget.equipmentItem.inventoryNumber);
    _modelController = TextEditingController(text: widget.equipmentItem.model);
    _manufacturerController =
        TextEditingController(text: widget.equipmentItem.manufacturer);
  }

  @override
  void dispose() {
    _inventoryNumberController.dispose();
    _modelController.dispose();
    _manufacturerController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement update logic via ApiService
      // final updatedItem = widget.equipmentItem.copyWith(
      //   inventoryNumber: _inventoryNumberController.text,
      //   model: _modelController.text,
      //   manufacturer: _manufacturerController.text,
      // );
      //
      // ref.read(apiServiceProvider).updateEquipmentItem(updatedItem).then((_) {
      //   Navigator.of(context).pop();
      // }).catchError((error) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('Failed to update item: $error')),
      //   );
      // });
      print('Form submitted!');
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактировать Оборудование'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _submitForm,
            tooltip: 'Сохранить',
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
              // TODO: Add dropdowns for Status, Room, Condition Rating etc.
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Сохранить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
