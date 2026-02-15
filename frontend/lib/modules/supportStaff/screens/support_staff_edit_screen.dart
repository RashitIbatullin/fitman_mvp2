import 'package:fitman_app/modules/supportStaff/models/employment_type.enum.dart';
import 'package:fitman_app/modules/supportStaff/models/staff_category.enum.dart';
import 'package:fitman_app/modules/supportStaff/models/support_staff.model.dart';
import 'package:fitman_app/modules/supportStaff/providers/support_staff_provider.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SupportStaffEditScreen extends ConsumerStatefulWidget {
  final SupportStaff? staff;

  const SupportStaffEditScreen({super.key, this.staff});

  @override
  ConsumerState<SupportStaffEditScreen> createState() =>
      _SupportStaffEditScreenState();
}

class _SupportStaffEditScreenState
    extends ConsumerState<SupportStaffEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _middleNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _companyNameController;
  late TextEditingController _contractNumberController;
  late TextEditingController _notesController;

  late EmploymentType _employmentType;
  late StaffCategory _staffCategory;
  late bool _canMaintainEquipment;
  DateTime? _contractExpiryDate;

  bool _isLoading = false; // Added
  String? _errorMessage; // Added

  @override
  void initState() {
    super.initState();
    _firstNameController =
        TextEditingController(text: widget.staff?.firstName ?? '');
    _lastNameController =
        TextEditingController(text: widget.staff?.lastName ?? '');
    _middleNameController =
        TextEditingController(text: widget.staff?.middleName ?? '');
    _phoneController = TextEditingController(text: widget.staff?.phone ?? '');
    _emailController = TextEditingController(text: widget.staff?.email ?? '');
    _companyNameController =
        TextEditingController(text: widget.staff?.companyName ?? '');
    _contractNumberController =
        TextEditingController(text: widget.staff?.contractNumber ?? '');
    _notesController = TextEditingController(text: widget.staff?.notes ?? '');

    _employmentType =
        widget.staff?.employmentType ?? EmploymentType.fullTime;
    _staffCategory = widget.staff?.category ?? StaffCategory.technician;
    _canMaintainEquipment = widget.staff?.canMaintainEquipment ?? false;
    _contractExpiryDate = widget.staff?.contractExpiryDate;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _middleNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _companyNameController.dispose();
    _contractNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() { // Added
        _isLoading = true;
        _errorMessage = null;
      });

      final newStaff = SupportStaff(
        id: widget.staff?.id ?? '', // handled by backend
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        middleName: _middleNameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        employmentType: _employmentType,
        category: _staffCategory,
        canMaintainEquipment: _canMaintainEquipment,
        companyName: _companyNameController.text,
        contractNumber: _contractNumberController.text,
        contractExpiryDate: _contractExpiryDate,
        notes: _notesController.text,
        createdAt: widget.staff?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      try {
        if (widget.staff == null) {
          await ApiService.createSupportStaff(newStaff);
        } else {
          await ApiService.updateSupportStaff(widget.staff!.id, newStaff);
        }
        ref.invalidate(allSupportStaffProvider);
        if (widget.staff != null) {
          ref.invalidate(supportStaffByIdProvider(widget.staff!.id));
        }

        String message = widget.staff == null ? 'Сотрудник успешно создан!' : 'Данные сотрудника успешно обновлены!'; // Added
        if (mounted) { // Added
          ScaffoldMessenger.of(context).showSnackBar( // Added
            SnackBar(content: Text(message), backgroundColor: Colors.green), // Added
          ); // Added
          Navigator.of(context).pop(); // Moved into mounted check
        } // Added
      } catch (e) {
        setState(() { // Added
          _errorMessage = e.toString();
        }); // Added
        if (mounted) { // Added
          ScaffoldMessenger.of(context).showSnackBar( // Added
            SnackBar(content: Text('Ошибка: $_errorMessage'), backgroundColor: Colors.red), // Added
          ); // Added
        } // Added
      } finally { // Added
        setState(() { // Added
          _isLoading = false;
        }); // Added
      } // Added
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.staff == null ? 'Новый сотрудник' : 'Редактировать'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'Имя'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a first name' : null,
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Фамилия'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a last name' : null,
              ),
              TextFormField(
                controller: _middleNameController,
                decoration: const InputDecoration(labelText: 'Отчество'),
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Телефон'),
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              DropdownButtonFormField<EmploymentType>(
                initialValue: _employmentType,
                decoration: const InputDecoration(labelText: 'Тип занятости'),
                items: EmploymentType.values
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Row(
                            children: [
                              Icon(e.iconData), // Used iconData directly
                              const SizedBox(width: 8),
                              Text(e.localizedName), // Used localizedName
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _employmentType = value);
                  }
                },
              ),
              DropdownButtonFormField<StaffCategory>(
                initialValue: _staffCategory,
                decoration: const InputDecoration(labelText: 'Категория'),
                items: StaffCategory.values
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Row(
                            children: [
                              Icon(e.iconData), // Used iconData directly
                              const SizedBox(width: 8),
                              Text(e.localizedName), // Used localizedName
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _staffCategory = value);
                  }
                },
              ),
              SwitchListTile(
                title: const Text('Может обслуживать оборудование'),
                value: _canMaintainEquipment,
                onChanged: (value) =>
                    setState(() => _canMaintainEquipment = value),
              ),
              TextFormField(
                controller: _companyNameController,
                decoration: const InputDecoration(labelText: 'Компания'),
              ),
              TextFormField(
                controller: _contractNumberController,
                decoration: const InputDecoration(labelText: 'Номер контракта'),
              ),
              ListTile(
                title: Text('Окончание контракта: ${_contractExpiryDate?.toLocal().toString().split(' ')[0] ?? ''}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _contractExpiryDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (date != null) {
                    setState(() {
                      _contractExpiryDate = date;
                    });
                  }
                },
              ),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Заметки'),
                maxLines: 3,
              ),
              if (_errorMessage != null) // Added
                Padding( // Added
                  padding: const EdgeInsets.all(8.0), // Added
                  child: Text( // Added
                    _errorMessage!, // Added
                    style: const TextStyle(color: Colors.red), // Added
                  ), // Added
                ), // Added
              const SizedBox(height: 20), // Added
              ElevatedButton(
                onPressed: _isLoading ? null : _saveForm, // Modified
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Сохранить'), // Modified
              )
            ],
          ),
        ),
      ),
    );
  }
}
