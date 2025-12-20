// ignore_for_file: use_build_context_synchronously
import 'package:fitman_app/models/anthropometry_data.dart';
import 'package:fitman_app/providers/recommendation_provider.dart';
import 'package:fitman_app/screens/client/photo_comparison_screen.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/providers/auth_provider.dart';
import 'package:fitman_app/utils/body_shape_calculator.dart';
import 'package:fitman_app/utils/body_shape_helper.dart';
import 'package:fitman_app/utils/somatotype_helper.dart';

import '../../models/user_front.dart';

final anthropometryProvider = FutureProvider.family<AnthropometryData, int?>((ref, clientId) async {
  Map<String, dynamic> data;
  if (clientId == null) {
    data = await ApiService.getOwnAnthropometryData();
  } else {
    data = await ApiService.getAnthropometryDataForClient(clientId);
  }
  return AnthropometryData.fromJson(data);
});

class AnthropometryScreen extends ConsumerStatefulWidget {
  final int? clientId;
  const AnthropometryScreen({super.key, this.clientId});

  @override
  ConsumerState<AnthropometryScreen> createState() =>
      _AnthropometryScreenState();
}

class _AnthropometryScreenState extends ConsumerState<AnthropometryScreen> {
  String? _startPhotoUrl;
  String? _finishPhotoUrl;
  DateTime? _startPhotoDateTime;
  DateTime? _finishPhotoDateTime;
  String? _startProfilePhotoUrl;
  String? _finishProfilePhotoUrl;
  DateTime? _startProfilePhotoDateTime;
  DateTime? _finishProfilePhotoDateTime;
  bool _isFixedEditing = false;
  bool _isStartEditing = false;
  bool _isFinishEditing = false;
  final _formKey = GlobalKey<FormState>();
  String? _startBodyShape;
  String? _finishBodyShape;
  
  // MODIFIED: _somatotypeProfile is now a Future
  Future<String>? _somatotypeProfileFuture;

  // Controllers
  late TextEditingController _heightController;
  late TextEditingController _wristCircController;
  late TextEditingController _ankleCircController;
  late TextEditingController _startWeightController;
  late TextEditingController _startShouldersCircController;
  late TextEditingController _startBreastCircController;
  late TextEditingController _startWaistCircController;
  late TextEditingController _startHipsCircController;
  late TextEditingController _finishWeightController;
  late TextEditingController _finishShouldersCircController;
  late TextEditingController _finishBreastCircController;
  late TextEditingController _finishWaistCircController;
  late TextEditingController _finishHipsCircController;

  bool _controllersInitialized = false;

  // NEW: Method to fetch somatotype from backend
  void _fetchSomatotypeProfile() {
    // Fetches the profile string from the backend and updates the state
    setState(() {
      _somatotypeProfileFuture = ApiService.getSomatotypeProfile(clientId: widget.clientId);
    });
  }

  @override
  void initState() {
    super.initState();
    // Controllers will be initialized in the build method once data is available.
    // _fetchSomatotypeProfile will also be called there for the first time.
  }

  void _initializeControllers(
    AnthropometryFixed fixed,
    AnthropometryMeasurements start,
    AnthropometryMeasurements finish,
  ) {
    _heightController = TextEditingController(text: fixed.height?.toString() ?? '');
    _wristCircController = TextEditingController(text: fixed.wristCirc?.toString() ?? '');
    _ankleCircController = TextEditingController(text: fixed.ankleCirc?.toString() ?? '');

    _startWeightController = TextEditingController(text: start.weight?.toString() ?? '');
    _startShouldersCircController = TextEditingController(text: start.shouldersCirc?.toString() ?? '');
    _startBreastCircController = TextEditingController(text: start.breastCirc?.toString() ?? '');
    _startWaistCircController = TextEditingController(text: start.waistCirc?.toString() ?? '');
    _startHipsCircController = TextEditingController(text: start.hipsCirc?.toString() ?? '');

    _finishWeightController = TextEditingController(text: finish.weight?.toString() ?? '');
    _finishShouldersCircController = TextEditingController(text: finish.shouldersCirc?.toString() ?? '');
    _finishBreastCircController = TextEditingController(text: finish.breastCirc?.toString() ?? '');
    _finishWaistCircController = TextEditingController(text: finish.waistCirc?.toString() ?? '');
    _finishHipsCircController = TextEditingController(text: finish.hipsCirc?.toString() ?? '');

    _startBodyShape = calculateBodyShape(
      shouldersCirc: start.shouldersCirc,
      waistCirc: start.waistCirc,
      hipsCirc: start.hipsCirc,
    );
    _finishBodyShape = calculateBodyShape(
      shouldersCirc: finish.shouldersCirc,
      waistCirc: finish.waistCirc,
      hipsCirc: finish.hipsCirc,
    );
  }

  @override
  Widget build(BuildContext context) {
    final anthropometryData = ref.watch(anthropometryProvider(widget.clientId));
    final authState = ref.watch(authProvider);
    final user = authState.value?.user;

    final canEdit = user != null && (!user.roles.any((role) => role.name == 'client') || user.roles.length > 1);

    return Scaffold(
      body: anthropometryData.when(
        data: (data) {
          if (!_controllersInitialized) {
            _initializeControllers(data.fixed, data.start, data.finish);
            _startPhotoUrl = data.start.photo;
            _finishPhotoUrl = data.finish.photo;
            _startPhotoDateTime = data.start.photoDateTime;
            _finishPhotoDateTime = data.finish.photoDateTime;
            _startProfilePhotoUrl = data.start.profilePhoto;
            _finishProfilePhotoUrl = data.finish.profilePhoto;
            _startProfilePhotoDateTime = data.start.profilePhotoDateTime;
            _finishProfilePhotoDateTime = data.finish.profilePhotoDateTime;
            _controllersInitialized = true;
            
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _fetchSomatotypeProfile();
            });
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
                            clientId: widget.clientId,
                            initialStartPhotoUrl: _startPhotoUrl,
                            initialFinishPhotoUrl: _finishPhotoUrl,
                            initialStartPhotoDateTime: _startPhotoDateTime,
                            initialFinishPhotoDateTime: _finishPhotoDateTime,
                            initialStartProfilePhotoUrl: _startProfilePhotoUrl,
                            initialFinishProfilePhotoUrl: _finishProfilePhotoUrl,
                            initialStartProfilePhotoDateTime: _startProfilePhotoDateTime,
                            initialFinishProfilePhotoDateTime: _finishProfilePhotoDateTime,
                          ),
                        ),
                      );

                      if (result != null && result is Map<String, dynamic>) {
                        setState(() {
                           _startPhotoUrl = result['startPhotoUrl'];
                          _finishPhotoUrl = result['finishPhotoUrl'];
                          _startPhotoDateTime = result['startPhotoDateTime'];
                          _finishPhotoDateTime = result['finishPhotoDateTime'];
                          _startProfilePhotoUrl =
                              result['startProfilePhotoUrl'];
                          _finishProfilePhotoUrl =
                              result['finishProfilePhotoUrl'];
                          _startProfilePhotoDateTime =
                              result['startProfilePhotoDateTime'];
                          _finishProfilePhotoDateTime =
                              result['finishProfilePhotoDateTime'];
                        });
                      }
                    },
                    child: const Text('Сравнение по фото'),
                  ),
                  const SizedBox(height: 16),
                  _buildFixedMeasurementsCard(
                    data.fixed,
                    _heightController,
                    _wristCircController,
                    _ankleCircController,
                    canEdit,
                    _isFixedEditing,
                    () => setState(() => _isFixedEditing = true),
                    () async {
                      if (_formKey.currentState!.validate()) {
                        final currentHeight = int.tryParse(_heightController.text);
                        final currentWristCirc = int.tryParse(_wristCircController.text);
                        final currentAnkleCirc = int.tryParse(_ankleCircController.text);

                        try {
                          await ApiService.updateAnthropometryFixed(
                            clientId: widget.clientId,
                            height: currentHeight ?? 0,
                            wristCirc: currentWristCirc ?? 0,
                            ankleCirc: currentAnkleCirc ?? 0,
                          );
                          ref.invalidate(anthropometryProvider(widget.clientId));
                          setState(() {
                            _isFixedEditing = false;
                            // MODIFIED: Re-fetch from backend
                            _fetchSomatotypeProfile();
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
                      _heightController.text = data.fixed.height?.toString() ?? '';
                      _wristCircController.text = data.fixed.wristCirc?.toString() ?? '';
                      _ankleCircController.text = data.fixed.ankleCirc?.toString() ?? '';
                      setState(() {
                        _isFixedEditing = false;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildMeasurementsCard(
                          'Начало',
                          data.start, _startPhotoUrl, 'start',
                          _startWeightController, _startShouldersCircController, _startBreastCircController,
                          _startWaistCircController, _startHipsCircController, _isStartEditing, canEdit,
                          _startBodyShape,
                          () => setState(() => _isStartEditing = true),
                          () async {
                             if (_formKey.currentState!.validate()) {
                              final currentWeight = double.tryParse(_startWeightController.text);
                              final currentShouldersCirc = int.tryParse(_startShouldersCircController.text);
                              final currentBreastCirc = int.tryParse(_startBreastCircController.text);
                              final currentWaistCirc = int.tryParse(_startWaistCircController.text);
                              final currentHipsCirc = int.tryParse(_startHipsCircController.text);

                              try {
                                await ApiService.updateAnthropometryMeasurements(
                                  clientId: widget.clientId, type: 'start',
                                  weight: currentWeight ?? 0.0,
                                  shouldersCirc: currentShouldersCirc ?? 0,
                                  breastCirc: currentBreastCirc ?? 0,
                                  waistCirc: currentWaistCirc ?? 0,
                                  hipsCirc: currentHipsCirc ?? 0,
                                );
                                ref.invalidate(anthropometryProvider(widget.clientId));
                                setState(() {
                                  _isStartEditing = false;
                                  _startBodyShape = calculateBodyShape(
                                    shouldersCirc: currentShouldersCirc,
                                    waistCirc: currentWaistCirc,
                                    hipsCirc: currentHipsCirc,
                                  );
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Данные Начало успешно обновлены!')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Ошибка при сохранении данных Начало: $e')),
                                );
                              }
                            }
                          },
                          () {
                            _startWeightController.text = data.start.weight?.toString() ?? '';
                            _startShouldersCircController.text = data.start.shouldersCirc?.toString() ?? '';
                            _startBreastCircController.text = data.start.breastCirc?.toString() ?? '';
                            _startWaistCircController.text = data.start.waistCirc?.toString() ?? '';
                            _startHipsCircController.text = data.start.hipsCirc?.toString() ?? '';
                            setState(() => _isStartEditing = false);
                          },
                          user,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMeasurementsCard(
                          'Окончание',
                          data.finish, _finishPhotoUrl, 'finish',
                          _finishWeightController, _finishShouldersCircController, _finishBreastCircController,
                          _finishWaistCircController, _finishHipsCircController, _isFinishEditing, canEdit,
                          _finishBodyShape,
                          () => setState(() => _isFinishEditing = true),
                          () async {
                            if (_formKey.currentState!.validate()) {
                              final currentWeight = double.tryParse(_finishWeightController.text);
                              final currentShouldersCirc = int.tryParse(_finishShouldersCircController.text);
                              final currentBreastCirc = int.tryParse(_finishBreastCircController.text);
                              final currentWaistCirc = int.tryParse(_finishWaistCircController.text);
                              final currentHipsCirc = int.tryParse(_finishHipsCircController.text);

                              try {
                                await ApiService.updateAnthropometryMeasurements(
                                  clientId: widget.clientId, type: 'finish',
                                  weight: currentWeight ?? 0.0,
                                  shouldersCirc: currentShouldersCirc ?? 0,
                                  breastCirc: currentBreastCirc ?? 0,
                                  waistCirc: currentWaistCirc ?? 0,
                                  hipsCirc: currentHipsCirc ?? 0,
                                );
                                ref.invalidate(anthropometryProvider(widget.clientId));
                                setState(() {
                                  _isFinishEditing = false;
                                  _finishBodyShape = calculateBodyShape(
                                    shouldersCirc: currentShouldersCirc,
                                    waistCirc: currentWaistCirc,
                                    hipsCirc: currentHipsCirc,
                                  );
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Данные Окончание успешно обновлены!')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Ошибка при сохранении данных Окончание: $e')),
                                );
                              }
                            }
                          },
                          () {
                            _finishWeightController.text = data.finish.weight?.toString() ?? '';
                            _finishShouldersCircController.text = data.finish.shouldersCirc?.toString() ?? '';
                            _finishBreastCircController.text = data.finish.breastCirc?.toString() ?? '';
                            _finishWaistCircController.text = data.finish.waistCirc?.toString() ?? '';
                            _finishHipsCircController.text = data.finish.hipsCirc?.toString() ?? '';
                            setState(() => _isFinishEditing = false);
                          },
                          user,
                        ),
                      ),
                    ],
                  ),
                  _buildRecommendationCard(),
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

  Widget _buildFixedMeasurementsCard(
    AnthropometryFixed fixed,
    TextEditingController heightController,
    TextEditingController wristCircController,
    TextEditingController ankleCircController,
    bool canEdit,
    bool isEditing,
    VoidCallback onEdit,
    VoidCallback onSave,
    VoidCallback onCancel,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Фиксированные значения', style: Theme.of(context).textTheme.titleLarge),
                if (canEdit) _buildEditControls(isEditing, onEdit, onSave, onCancel),
              ],
            ),
            const SizedBox(height: 8),
            _buildEditableField('Рост', heightController, isInt: true, isEditing: isEditing),
            _buildEditableField('Обхват запястья', wristCircController, isInt: true, isEditing: isEditing),
            _buildEditableField('Обхват лодыжки', ankleCircController, isInt: true, isEditing: isEditing),
            if (!isEditing) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('Соматотип:', style: Theme.of(context).textTheme.titleMedium),
                  IconButton(icon: const Icon(Icons.help_outline, size: 20), onPressed: _showSomatotypeHelp),
                ],
              ),
              const SizedBox(height: 8),
              FutureBuilder<String>(
                future: _somatotypeProfileFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('Расчет...');
                  } else if (snapshot.hasError) {
                    return Text('Ошибка: ${snapshot.error}', style: const TextStyle(color: Colors.red));
                  } else if (snapshot.hasData) {
                    return Text(
                      snapshot.data ?? 'Недостаточно данных',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    );
                  } else {
                    return const Text('Недостаточно данных для расчета.');
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementsCard(
    String title,
    AnthropometryMeasurements measurements,
    String? photoUrl,
    String type,
    TextEditingController weightController,
    TextEditingController shouldersCircController,
    TextEditingController breastCircController,
    TextEditingController waistCircController,
    TextEditingController hipsCircController,
    bool isEditing,
    bool canEdit,
    String? bodyShape,
    VoidCallback onEdit,
    VoidCallback onSave,
    VoidCallback onCancel,
    User? user,
  ) {
    final height = int.tryParse(_heightController.text);
    final waistCirc = int.tryParse(waistCircController.text);
    final whtrRatio = (height != null && waistCirc != null && height > 0) ? (waistCirc / height) : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                if (canEdit) _buildEditControls(isEditing, onEdit, onSave, onCancel),
              ],
            ),
            const SizedBox(height: 8),
            _buildEditableField('Вес', weightController, isDouble: true, isEditing: isEditing, startValue: type == 'finish' ? _startWeightController.text : null),
            _buildEditableField('Обхват плеч', shouldersCircController, isInt: true, isEditing: isEditing, startValue: type == 'finish' ? _startShouldersCircController.text : null),
            _buildEditableField('Обхват груди', breastCircController, isInt: true, isEditing: isEditing, startValue: type == 'finish' ? _startBreastCircController.text : null),
            _buildEditableField('Обхват талии', waistCircController, isInt: true, isEditing: isEditing, startValue: type == 'finish' ? _startWaistCircController.text : null),
            _buildEditableField('Обхват бедер', hipsCircController, isInt: true, isEditing: isEditing, startValue: type == 'finish' ? _startHipsCircController.text : null),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Тип фигуры', style: Theme.of(context).textTheme.titleMedium),
                    IconButton(icon: const Icon(Icons.help_outline, size: 20), onPressed: () => _showBodyShapeHelp(bodyShape)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(bodyShape ?? 'Недостаточно данных', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            if (whtrRatio != null) ...[
              const SizedBox(height: 8),
              Text('WHtR: ${whtrRatio.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              _buildWhtrIndex(whtrRatio, user?.age),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller, {
    bool isInt = false,
    bool isDouble = false,
    required bool isEditing,
    String? startValue,
  }) {
    Widget valueWidget;
    if (isEditing) {
      valueWidget = TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        ),
        keyboardType: isInt || isDouble ? TextInputType.number : TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) return 'Поле не может быть пустым';
          if (isInt && int.tryParse(value) == null) return 'Введите целое число';
          if (isDouble && double.tryParse(value) == null) return 'Введите число';
          return null;
        },
      );
    } else {
      String differenceText = '';
      if (startValue != null) {
        if (isDouble) {
          final double? start = double.tryParse(startValue);
          final double? end = double.tryParse(controller.text);
          if (start != null && end != null) {
            final double diff = end - start;
            if (diff != 0) differenceText = ' (${diff > 0 ? '+' : ''}${diff.toStringAsFixed(1)})';
          }
        } else {
          final int? start = int.tryParse(startValue);
          final int? end = int.tryParse(controller.text);
          if (start != null && end != null) {
            final int diff = end - start;
            if (diff != 0) differenceText = ' (${diff > 0 ? '+' : ''}$diff)';
          }
        }
      }
      valueWidget = RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(text: '$label: ${controller.text.isEmpty ? 'не указано' : controller.text}'),
            if (differenceText.isNotEmpty)
              TextSpan(text: differenceText, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          ],
        ),
      );
    }
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4.0), child: valueWidget);
  }

  Widget _buildEditControls(bool isEditing, VoidCallback onEdit, VoidCallback onSave, VoidCallback onCancel) {
    return isEditing
        ? Row(children: [
            IconButton(icon: const Icon(Icons.save), onPressed: onSave),
            IconButton(icon: const Icon(Icons.cancel), onPressed: onCancel),
          ])
        : IconButton(icon: const Icon(Icons.edit), onPressed: onEdit);
  }
  
  Widget _buildRecommendationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Персональные рекомендации', style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, child) {
                return ElevatedButton(
                  onPressed: () async {
                    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));
                    try {
                      final recommendation = await ref.read(recommendationProvider(widget.clientId!).future);
                      Navigator.of(context).pop();
                      await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Ваша рекомендация'),
                          content: SingleChildScrollView(child: Text(recommendation['client_recommendation'] ?? 'Рекомендация не найдена.')),
                          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
                        ),
                      );
                    } catch (e) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка получения рекомендации: $e'), backgroundColor: Colors.red));
                    }
                  },
                  child: const Text('Получить рекомендацию'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhtrIndex(double whtr, int? age) {
    String message;
    Color color;
    double progress = (whtr - 0.3) / (0.7 - 0.3);
    progress = progress.clamp(0.0, 1.0);
    double normalWhtrThreshold;
    if (age == null) {
      normalWhtrThreshold = 0;
    } else if (age <= 25) {
      normalWhtrThreshold = 0.5;
    } else if (age <= 40) {
      normalWhtrThreshold = 0.48;
    } else if (age <= 60) {
      normalWhtrThreshold = 0.46;
    } else {
      normalWhtrThreshold = 0.45;
    }
    if (age == null) {
      message = 'Расчет невозможен, не указан возраст';
      color = Colors.grey;
    } else {
      if (whtr < normalWhtrThreshold - 0.05) {
        message = 'Высокий риск истощения';
        color = Colors.red;
      } else if (whtr >= normalWhtrThreshold - 0.05 && whtr < normalWhtrThreshold) {
        message = 'Повышенный риск истощения';
        color = Colors.orange;
      } else if (whtr >= normalWhtrThreshold && whtr <= normalWhtrThreshold + 0.05) {
        message = 'Норма, риск низкий';
        color = Colors.green;
      } else if (whtr > normalWhtrThreshold + 0.05 && whtr <= normalWhtrThreshold + 0.1) {
        message = 'Повышенный риск ожирения';
        color = Colors.orange;
      } else {
        message = 'Высокий риск ожирения';
        color = Colors.red;
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Индекс здоровья WHtR:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        LinearProgressIndicator(value: progress, backgroundColor: Colors.grey[300], valueColor: AlwaysStoppedAnimation<Color>(color)),
        const SizedBox(height: 4),
        Text(message, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }
  
  void _showBodyShapeHelp(String? bodyShape) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Справка по типу фигуры'),
        content: SingleChildScrollView(child: Text(getBodyShapeHelpText(bodyShape))),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Закрыть'))],
      ),
    );
  }

  void _showSomatotypeHelp() {
    // This now needs to deal with the future
    _somatotypeProfileFuture?.then((profileString) {
        showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Справка по соматотипу'),
          content: SingleChildScrollView(child: Text(getSomatotypeHelpText(profileString))),
          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Закрыть'))],
        ),
      );
    });
  }
}
