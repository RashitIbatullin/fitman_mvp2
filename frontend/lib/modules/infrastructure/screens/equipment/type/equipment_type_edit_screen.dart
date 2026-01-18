import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/modules/infrastructure/models/equipment/equipment_type.model.dart';
import 'package:fitman_app/modules/infrastructure/models/equipment/equipment_category.enum.dart';
import 'package:fitman_app/modules/infrastructure/providers/equipment_provider.dart';
import 'package:fitman_app/services/api_service.dart';

class EquipmentTypeEditScreen extends ConsumerStatefulWidget {
  final String? equipmentTypeId;
  final EquipmentType? equipmentType;

  const EquipmentTypeEditScreen({
    super.key,
    this.equipmentTypeId,
    this.equipmentType,
  });

  @override
  ConsumerState<EquipmentTypeEditScreen> createState() =>
      _EquipmentTypeEditScreenState();
}

class _EquipmentTypeEditScreenState extends ConsumerState<EquipmentTypeEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late EquipmentCategory _selectedCategory;
  late TextEditingController _weightRangeController;
  late TextEditingController _dimensionsController;
  late TextEditingController _powerRequirementsController;
  late bool _isMobile;
  late TextEditingController _exerciseTypeIdController;
  late TextEditingController _photoUrlController;
  late TextEditingController _manualUrlController;
  late bool _isActive;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _selectedCategory = EquipmentCategory.other; // Default value
    _weightRangeController = TextEditingController();
    _dimensionsController = TextEditingController();
    _powerRequirementsController = TextEditingController();
    _isMobile = true; // Default value
    _exerciseTypeIdController = TextEditingController();
    _photoUrlController = TextEditingController();
    _manualUrlController = TextEditingController();
    _isActive = true; // Default value

    if (widget.equipmentType != null) {
      _populateForm(widget.equipmentType!);
    } else if (widget.equipmentTypeId != null) {
      _loadEquipmentType();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _weightRangeController.dispose();
    _dimensionsController.dispose();
    _powerRequirementsController.dispose();
    _exerciseTypeIdController.dispose();
    _photoUrlController.dispose();
    _manualUrlController.dispose();
    super.dispose();
  }

  void _populateForm(EquipmentType equipmentType) {
    _nameController.text = equipmentType.name;
    _descriptionController.text = equipmentType.description ?? '';
    _selectedCategory = equipmentType.category;
    _weightRangeController.text = equipmentType.weightRange ?? '';
    _dimensionsController.text = equipmentType.dimensions ?? '';
    _powerRequirementsController.text = equipmentType.powerRequirements ?? '';
    _isMobile = equipmentType.isMobile;
    _exerciseTypeIdController.text = equipmentType.exerciseTypeId ?? '';
    _photoUrlController.text = equipmentType.photoUrl ?? '';
    _manualUrlController.text = equipmentType.manualUrl ?? '';
    _isActive = equipmentType.isActive;
  }

  Future<void> _loadEquipmentType() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final equipmentType = await ref.read(equipmentTypeByIdProvider(widget.equipmentTypeId!).future);
      _populateForm(equipmentType);
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

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final newEquipmentType = EquipmentType(
      id: widget.equipmentTypeId ?? '', // Will be updated by backend for new items
      name: _nameController.text,
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      category: _selectedCategory,
      weightRange: _weightRangeController.text.isEmpty ? null : _weightRangeController.text,
      dimensions: _dimensionsController.text.isEmpty ? null : _dimensionsController.text,
      powerRequirements: _powerRequirementsController.text.isEmpty ? null : _powerRequirementsController.text,
      isMobile: _isMobile,
      exerciseTypeId: _exerciseTypeIdController.text.isEmpty ? null : _exerciseTypeIdController.text,
      photoUrl: _photoUrlController.text.isEmpty ? null : _photoUrlController.text,
      manualUrl: _manualUrlController.text.isEmpty ? null : _manualUrlController.text,
      isActive: _isActive,
    );

    try {
      if (widget.equipmentTypeId == null) {
        // Create new
        await ApiService.createEquipmentType(newEquipmentType);
      } else {
        // Update existing
        await ApiService.updateEquipmentType(widget.equipmentTypeId!, newEquipmentType);
      }
      ref.invalidate(allEquipmentTypesProvider); // Refresh the list
      if (!mounted) return; // Guard against BuildContext across async gaps
      Navigator.of(context).pop(); // Go back to the list screen
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.equipmentTypeId == null
              ? 'Создать тип оборудования'
              : 'Редактировать тип оборудования',
        ),
      ),
      body: _isLoading && widget.equipmentTypeId != null && widget.equipmentType == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Описание'),
                      maxLines: 3,
                    ),
                    DropdownButtonFormField<EquipmentCategory>(
                      initialValue: _selectedCategory,
                      decoration: const InputDecoration(labelText: 'Категория'),
                      items: EquipmentCategory.values
                          .map((category) => DropdownMenuItem(
                                value: category,
                                child: Text(category.displayName),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                    TextFormField(
                      controller: _weightRangeController,
                      decoration:
                          const InputDecoration(labelText: 'Диапазон веса'),
                    ),
                    TextFormField(
                      controller: _dimensionsController,
                      decoration: const InputDecoration(labelText: 'Габариты'),
                    ),
                    TextFormField(
                      controller: _powerRequirementsController,
                      decoration: const InputDecoration(
                          labelText: 'Требования к питанию'),
                    ),
                    SwitchListTile(
                      title: const Text('Мобильное'),
                      value: _isMobile,
                      onChanged: (value) {
                        setState(() {
                          _isMobile = value;
                        });
                      },
                    ),
                    TextFormField(
                      controller: _exerciseTypeIdController,
                      decoration:
                          const InputDecoration(labelText: 'ID типа упражнения'),
                    ),
                    TextFormField(
                      controller: _photoUrlController,
                      decoration: const InputDecoration(labelText: 'URL фото'),
                    ),
                    TextFormField(
                      controller: _manualUrlController,
                      decoration:
                          const InputDecoration(labelText: 'URL руководства'),
                    ),
                    SwitchListTile(
                      title: const Text('Активно'),
                      value: _isActive,
                      onChanged: (value) {
                        setState(() {
                          _isActive = value;
                        });
                      },
                    ),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(height: 20),
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
