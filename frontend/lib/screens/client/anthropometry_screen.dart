import 'package:fitman_app/models/anthropometry_data.dart';
import 'package:fitman_app/screens/client/photo_comparison_screen.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

final anthropometryProvider = FutureProvider<AnthropometryData>((ref) async {
  final data = await ApiService.getAnthropometryData();
  return AnthropometryData.fromJson(data);
});

class AnthropometryScreen extends ConsumerStatefulWidget {
  const AnthropometryScreen({super.key});

  @override
  ConsumerState<AnthropometryScreen> createState() => _AnthropometryScreenState();
}

class _AnthropometryScreenState extends ConsumerState<AnthropometryScreen> {
  String? _startPhotoUrl;
  String? _finishPhotoUrl;
  DateTime? _startPhotoDateTime;
  DateTime? _finishPhotoDateTime;
  bool _isFixedEditing = false;
  bool _isStartEditing = false;
  bool _isFinishEditing = false;
  final _formKey = GlobalKey<FormState>(); // New: Form key for validation

  // Controllers for anthropometry_fix
  late TextEditingController _heightController;
  late TextEditingController _wristCircController;
  late TextEditingController _ankleCircController;

  // Controllers for anthropometry_start
  late TextEditingController _startWeightController;
  late TextEditingController _startShouldersCircController;
  late TextEditingController _startBreastCircController;
  late TextEditingController _startWaistCircController;
  late TextEditingController _startHipsCircController;
  late TextEditingController _startBmrController;

  // Controllers for anthropometry_finish
  late TextEditingController _finishWeightController;
  late TextEditingController _finishShouldersCircController;
  late TextEditingController _finishBreastCircController;
  late TextEditingController _finishWaistCircController;
  late TextEditingController _finishHipsCircController;
  late TextEditingController _finishBmrController;

  // Flag to ensure controllers are initialized only once
  bool _controllersInitialized = false;

  @override
  void initState() {
    super.initState();
    // Controllers are initialized in build method after data is available
  }

  @override
  void dispose() {
    _heightController.dispose();
    _wristCircController.dispose();
    _ankleCircController.dispose();
    _startWeightController.dispose();
    _startShouldersCircController.dispose();
    _startBreastCircController.dispose();
    _startWaistCircController.dispose();
    _startHipsCircController.dispose();
    _startBmrController.dispose();
    _finishWeightController.dispose();
    _finishShouldersCircController.dispose();
    _finishBreastCircController.dispose();
    _finishWaistCircController.dispose();
    _finishHipsCircController.dispose();
    _finishBmrController.dispose();
    super.dispose();
  }

  void _initializeControllers(AnthropometryFixed fixed,
      AnthropometryMeasurements start, AnthropometryMeasurements finish) {
    _heightController =
        TextEditingController(text: fixed.height?.toString() ?? '');
    _wristCircController =
        TextEditingController(text: fixed.wristCirc?.toString() ?? '');
    _ankleCircController =
        TextEditingController(text: fixed.ankleCirc?.toString() ?? '');

    _startWeightController =
        TextEditingController(text: start.weight?.toString() ?? '');
    _startShouldersCircController =
        TextEditingController(text: start.shouldersCirc?.toString() ?? '');
    _startBreastCircController =
        TextEditingController(text: start.breastCirc?.toString() ?? '');
    _startWaistCircController =
        TextEditingController(text: start.waistCirc?.toString() ?? '');
    _startHipsCircController =
        TextEditingController(text: start.hipsCirc?.toString() ?? '');
    _startBmrController =
        TextEditingController(text: start.bmr?.toString() ?? '');

    _finishWeightController =
        TextEditingController(text: finish.weight?.toString() ?? '');
    _finishShouldersCircController =
        TextEditingController(text: finish.shouldersCirc?.toString() ?? '');
    _finishBreastCircController =
        TextEditingController(text: finish.breastCirc?.toString() ?? '');
    _finishWaistCircController =
        TextEditingController(text: finish.waistCirc?.toString() ?? '');
    _finishHipsCircController =
        TextEditingController(text: finish.hipsCirc?.toString() ?? '');
    _finishBmrController =
        TextEditingController(text: finish.bmr?.toString() ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final anthropometryData = ref.watch(anthropometryProvider);

    return Scaffold(
      appBar: AppBar(
      ),
      body: anthropometryData.when(
        data: (data) {
          if (!_controllersInitialized) {
            _initializeControllers(data.fixed, data.start, data.finish);
            _startPhotoUrl = data.start.photo;
            _finishPhotoUrl = data.finish.photo;
            _startPhotoDateTime = data.start.photoDateTime;
            _finishPhotoDateTime = data.finish.photoDateTime;
            _controllersInitialized = true;
          }
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PhotoComparisonScreen(
                            initialStartPhotoUrl: _startPhotoUrl,
                            initialFinishPhotoUrl: _finishPhotoUrl,
                            initialStartPhotoDateTime: _startPhotoDateTime,
                            initialFinishPhotoDateTime: _finishPhotoDateTime,
                          ),
                        ),
                      );

                      if (result != null && result is Map<String, dynamic>) {
                        setState(() {
                          _startPhotoUrl = result['startPhotoUrl'];
                          _finishPhotoUrl = result['finishPhotoUrl'];
                          _startPhotoDateTime = result['startPhotoDateTime'];
                          _finishPhotoDateTime = result['finishPhotoDateTime'];
                        });
                      }
                    },
                    child: const Text(
                      'Сравнение по фото',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFixedMeasurementsCard(
                    data.fixed,
                    _heightController,
                    _wristCircController,
                    _ankleCircController,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildMeasurementsCard(
                          'Начало',
                          data.start,
                          _startPhotoUrl,
                          'start',
                          _startWeightController,
                          _startShouldersCircController,
                          _startBreastCircController,
                          _startWaistCircController,
                          _startHipsCircController,
                          _startBmrController,
                          _isStartEditing,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMeasurementsCard(
                          'Окончание',
                          data.finish,
                          _finishPhotoUrl,
                          'finish',
                          _finishWeightController,
                          _finishShouldersCircController,
                          _finishBreastCircController,
                          _finishWaistCircController,
                          _finishHipsCircController,
                          _finishBmrController,
                          _isFinishEditing,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Ошибка: $error')),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller,
      {bool isInt = false, bool isDouble = false, required bool isEditing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: isEditing
          ? TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        ),
        keyboardType: isInt || isDouble ? TextInputType.number : TextInputType
            .text,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Поле не может быть пустым';
          }
          if (isInt) {
            if (int.tryParse(value) == null) {
              return 'Введите целое число';
            }
          }
          if (isDouble) {
            if (double.tryParse(value) == null) {
              return 'Введите число';
            }
          }
          return null;
        },
      )
          : Text('$label: ${controller.text.isEmpty ? 'не указано' : controller
          .text}'),
    );
  }



  Widget _buildEditControls(bool isEditing, VoidCallback onEdit, VoidCallback onSave, VoidCallback onCancel) {
    return isEditing
        ? Row(
            children: [
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: onSave,
              ),
              IconButton(
                icon: const Icon(Icons.cancel),
                onPressed: onCancel,
              ),
            ],
          )
        : IconButton(
            icon: const Icon(Icons.edit),
            onPressed: onEdit,
          );
  }

  Widget _buildFixedMeasurementsCard(AnthropometryFixed fixed,
      TextEditingController heightController,
      TextEditingController wristCircController,
      TextEditingController ankleCircController,) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Фиксированные значения',
                  style: Theme
                      .of(context)
                      .textTheme
                      .titleLarge,
                ),
                _buildEditControls(
                  _isFixedEditing,
                  () {
                    setState(() {
                      _isFixedEditing = true;
                    });
                  },
                  () async {
                    if (_formKey.currentState!.validate()) {
                      final currentHeight = int.tryParse(heightController.text);
                      final currentWristCirc = int.tryParse(wristCircController.text);
                      final currentAnkleCirc = int.tryParse(ankleCircController.text);

                      try {
                        await ApiService.updateAnthropometryFixed(
                          height: currentHeight ?? 0,
                          wristCirc: currentWristCirc ?? 0,
                          ankleCirc: currentAnkleCirc ?? 0,
                        );
                        ref.invalidate(anthropometryProvider);
                        setState(() {
                          _isFixedEditing = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Фиксированные данные успешно обновлены!')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Ошибка при сохранении фиксированных данных: $e')),
                        );
                      }
                    }
                  },
                  () {
                    heightController.text = fixed.height?.toString() ?? '';
                    wristCircController.text = fixed.wristCirc?.toString() ?? '';
                    ankleCircController.text = fixed.ankleCirc?.toString() ?? '';
                    setState(() {
                      _isFixedEditing = false;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildEditableField('Рост', heightController, isInt: true,
                isEditing: _isFixedEditing),
            _buildEditableField(
                'Обхват запястья', wristCircController, isInt: true,
                isEditing: _isFixedEditing),
            _buildEditableField(
                'Обхват лодыжки', ankleCircController, isInt: true,
                isEditing: _isFixedEditing),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementsCard(String title,
      AnthropometryMeasurements measurements,
      String? photoUrl,
      String type,
      TextEditingController weightController,
      TextEditingController shouldersCircController,
      TextEditingController breastCircController,
      TextEditingController waistCircController,
      TextEditingController hipsCircController,
      TextEditingController bmrController,
      bool isEditing, // New parameter
      ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row( // New: Row for title and edit button
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme
                      .of(context)
                      .textTheme
                      .titleLarge,
                ),
                _buildEditControls(
                  isEditing,
                  () {
                    setState(() {
                      if (type == 'start') _isStartEditing = true;
                      if (type == 'finish') _isFinishEditing = true;
                    });
                  },
                  () async {
                    if (_formKey.currentState!.validate()) {
                      final currentWeight = double.tryParse(weightController.text);
                      final currentShouldersCirc = int.tryParse(shouldersCircController.text);
                      final currentBreastCirc = int.tryParse(breastCircController.text);
                      final currentWaistCirc = int.tryParse(waistCircController.text);
                      final currentHipsCirc = int.tryParse(hipsCircController.text);
                      final currentBmr = int.tryParse(bmrController.text);

                      try {
                        await ApiService.updateAnthropometryMeasurements(
                          type: type,
                          weight: currentWeight ?? 0.0,
                          shouldersCirc: currentShouldersCirc ?? 0,
                          breastCirc: currentBreastCirc ?? 0,
                          waistCirc: currentWaistCirc ?? 0,
                          hipsCirc: currentHipsCirc ?? 0,
                          bmr: currentBmr ?? 0,
                        );
                        ref.invalidate(anthropometryProvider);
                        setState(() {
                          if (type == 'start') _isStartEditing = false;
                          if (type == 'finish') _isFinishEditing = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Данные $title успешно обновлены!')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Ошибка при сохранении данных $title: $e')),
                        );
                      }
                    }
                  },
                  () {
                    // Revert changes
                    if (type == 'start') {
                      weightController.text = measurements.weight?.toString() ?? '';
                      shouldersCircController.text = measurements.shouldersCirc?.toString() ?? '';
                      breastCircController.text = measurements.breastCirc?.toString() ?? '';
                      waistCircController.text = measurements.waistCirc?.toString() ?? '';
                      hipsCircController.text = measurements.hipsCirc?.toString() ?? '';
                      bmrController.text = measurements.bmr?.toString() ?? '';
                      setState(() { _isStartEditing = false; });
                    } else if (type == 'finish') {
                      weightController.text = measurements.weight?.toString() ?? '';
                      shouldersCircController.text = measurements.shouldersCirc?.toString() ?? '';
                      breastCircController.text = measurements.breastCirc?.toString() ?? '';
                      waistCircController.text = measurements.waistCirc?.toString() ?? '';
                      hipsCircController.text = measurements.hipsCirc?.toString() ?? '';
                      bmrController.text = measurements.bmr?.toString() ?? '';
                      setState(() { _isFinishEditing = false; });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildEditableField(
                'Вес', weightController, isDouble: true, isEditing: isEditing),
            _buildEditableField(
                'Обхват плеч', shouldersCircController, isInt: true,
                isEditing: isEditing),
            _buildEditableField(
                'Обхват груди', breastCircController, isInt: true,
                isEditing: isEditing),
            _buildEditableField(
                'Обхват талии', waistCircController, isInt: true,
                isEditing: isEditing),
            _buildEditableField('Обхват бедер', hipsCircController, isInt: true,
                isEditing: isEditing),
            _buildEditableField(
                'BMR', bmrController, isInt: true, isEditing: isEditing),
          ],
        ),
      ),
    );
  }
}