// ignore_for_file: use_build_context_synchronously
import 'package:fitman_app/models/anthropometry_data.dart';
import 'package:fitman_app/providers/recommendation_provider.dart';
import 'package:fitman_app/screens/client/photo_comparison_screen.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/providers/auth_provider.dart';
import 'package:fitman_app/utils/body_shape_calculator.dart';

import 'package:fitman_app/utils/somatotype_calculator.dart';
import 'package:fitman_app/utils/somatotype_helper.dart';

import '../../models/user_front.dart';

final anthropometryProvider = FutureProvider.family<AnthropometryData, int?>((
  ref,
  clientId,
) async {
  final authUser = ref.watch(authProvider).value?.user;
  if (authUser == null) {
    throw Exception('User not authenticated');
  }

  final isAdmin = authUser.roles.any((role) => role.name == 'admin');
  // TODO: Expand this role check to include manager, trainer, instructor roles when they can edit client data.

  // If an admin is viewing a specific client's page, clientId will be passed.
  // If a client is viewing their own page, clientId will also be passed (it will be their own id).
  if (isAdmin && clientId != null && clientId != authUser.id) {
    final data = await ApiService.getAnthropometryDataForClient(clientId);
    return AnthropometryData.fromJson(data);
  } else {
    // This covers the client viewing their own data, and an admin viewing their own data.
    final data = await ApiService.getOwnAnthropometryData();
    return AnthropometryData.fromJson(data);
  }
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
  final _formKey = GlobalKey<FormState>(); // New: Form key for validation
  String? _startBodyShape;
  String? _finishBodyShape;
  String? _somatotypeProfile;

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

  // Controllers for anthropometry_finish
  late TextEditingController _finishWeightController;
  late TextEditingController _finishShouldersCircController;
  late TextEditingController _finishBreastCircController;
  late TextEditingController _finishWaistCircController;
  late TextEditingController _finishHipsCircController;

  // Flag to ensure controllers are initialized only once
  bool _controllersInitialized = false;

  void _initializeControllers(
    AnthropometryFixed fixed,
    AnthropometryMeasurements start,
    AnthropometryMeasurements finish,
    User? user,
  ) {
    _heightController = TextEditingController(
      text: fixed.height?.toString() ?? '',
    );
    _wristCircController = TextEditingController(
      text: fixed.wristCirc?.toString() ?? '',
    );
    _ankleCircController = TextEditingController(
      text: fixed.ankleCirc?.toString() ?? '',
    );

    _startWeightController = TextEditingController(
      text: start.weight?.toString() ?? '',
    );
    _startShouldersCircController = TextEditingController(
      text: start.shouldersCirc?.toString() ?? '',
    );
    _startBreastCircController = TextEditingController(
      text: start.breastCirc?.toString() ?? '',
    );
    _startWaistCircController = TextEditingController(
      text: start.waistCirc?.toString() ?? '',
    );
    _startHipsCircController = TextEditingController(
      text: start.hipsCirc?.toString() ?? '',
    );

    _finishWeightController = TextEditingController(
      text: finish.weight?.toString() ?? '',
    );
    _finishShouldersCircController = TextEditingController(
      text: finish.shouldersCirc?.toString() ?? '',
    );
    _finishBreastCircController = TextEditingController(
      text: finish.breastCirc?.toString() ?? '',
    );
    _finishWaistCircController = TextEditingController(
      text: finish.waistCirc?.toString() ?? '',
    );
    _finishHipsCircController = TextEditingController(
      text: finish.hipsCirc?.toString() ?? '',
    );

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
    _somatotypeProfile = calculateSomatotype(
      wristCirc: fixed.wristCirc?.toDouble(),
      ankleCirc: fixed.ankleCirc?.toDouble(),
      gender: user?.gender,
    );
  }

  @override
  Widget build(BuildContext context) {
    final anthropometryData = ref.watch(anthropometryProvider(widget.clientId));
    final authState = ref.watch(authProvider);
    final user = authState.value?.user;

    // A user is not a client if they don't have the client role, or have more than one role.
    final canEdit =
        user != null &&
        (!user.roles.any((role) => role.name == 'client') ||
            user.roles.length > 1);

    return Scaffold(
      body: anthropometryData.when(
        data: (data) {
          if (!_controllersInitialized) {
            _initializeControllers(data.fixed, data.start, data.finish, user);
            _startPhotoUrl = data.start.photo;
            _finishPhotoUrl = data.finish.photo;
            _startPhotoDateTime = data.start.photoDateTime;
            _finishPhotoDateTime = data.finish.photoDateTime;
            _startProfilePhotoUrl = data.start.profilePhoto;
            _finishProfilePhotoUrl = data.finish.profilePhoto;
            _startProfilePhotoDateTime = data.start.profilePhotoDateTime;
            _finishProfilePhotoDateTime = data.finish.profilePhotoDateTime;
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
                            clientId: widget.clientId,
                            initialStartPhotoUrl: _startPhotoUrl,
                            initialFinishPhotoUrl: _finishPhotoUrl,
                            initialStartPhotoDateTime: _startPhotoDateTime,
                            initialFinishPhotoDateTime: _finishPhotoDateTime,
                            initialStartProfilePhotoUrl: _startProfilePhotoUrl,
                            initialFinishProfilePhotoUrl:
                                _finishProfilePhotoUrl,
                            initialStartProfilePhotoDateTime:
                                _startProfilePhotoDateTime,
                            initialFinishProfilePhotoDateTime:
                                _finishProfilePhotoDateTime,
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
                    child: const Text(
                      'Сравнение по фото',
                    ),
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
                        final currentHeight = int.tryParse(
                          _heightController.text,
                        );
                        final currentWristCirc = int.tryParse(
                          _wristCircController.text,
                        );
                        final currentAnkleCirc = int.tryParse(
                          _ankleCircController.text,
                        );

                        try {
                          await ApiService.updateAnthropometryFixed(
                            clientId: widget.clientId,
                            height: currentHeight ?? 0,
                            wristCirc: currentWristCirc ?? 0,
                            ankleCirc: currentAnkleCirc ?? 0,
                          );
                          ref.invalidate(
                            anthropometryProvider(widget.clientId),
                          );
                          setState(() {
                            _isFixedEditing = false;
                            _somatotypeProfile = calculateSomatotype(
                              wristCirc: currentWristCirc?.toDouble(),
                              ankleCirc: currentAnkleCirc?.toDouble(),
                              gender: user?.gender,
                            );
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Фиксированные данные успешно обновлены!',
                              ),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Ошибка при сохранении фиксированных данных: $e',
                              ),
                            ),
                          );
                        }
                      }
                    },
                    () {
                      _heightController.text =
                          data.fixed.height?.toString() ?? '';
                      _wristCircController.text =
                          data.fixed.wristCirc?.toString() ?? '';
                      _ankleCircController.text =
                          data.fixed.ankleCirc?.toString() ?? '';
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
                          data.start,
                          _startPhotoUrl,
                          'start',
                          _startWeightController,
                          _startShouldersCircController,
                          _startBreastCircController,
                          _startWaistCircController,
                          _startHipsCircController,
                          _isStartEditing,
                          canEdit,
                          _startBodyShape,
                          () => setState(() => _isStartEditing = true),
                          () async {
                            if (_formKey.currentState!.validate()) {
                              final currentWeight = double.tryParse(
                                _startWeightController.text,
                              );
                              final currentShouldersCirc = int.tryParse(
                                _startShouldersCircController.text,
                              );
                              final currentBreastCirc = int.tryParse(
                                _startBreastCircController.text,
                              );
                              final currentWaistCirc = int.tryParse(
                                _startWaistCircController.text,
                              );
                              final currentHipsCirc = int.tryParse(
                                _startHipsCircController.text,
                              );

                              try {
                                await ApiService.updateAnthropometryMeasurements(
                                  clientId: widget.clientId,
                                  type: 'start',
                                  weight: currentWeight ?? 0.0,
                                  shouldersCirc: currentShouldersCirc ?? 0,
                                  breastCirc: currentBreastCirc ?? 0,
                                  waistCirc: currentWaistCirc ?? 0,
                                  hipsCirc: currentHipsCirc ?? 0,
                                );
                                ref.invalidate(
                                  anthropometryProvider(widget.clientId),
                                );
                                setState(() {
                                  _isStartEditing = false;
                                  _startBodyShape = calculateBodyShape(
                                    shouldersCirc: currentShouldersCirc,
                                    waistCirc: currentWaistCirc,
                                    hipsCirc: currentHipsCirc,
                                  );
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Данные Начало успешно обновлены!',
                                    ),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Ошибка при сохранении данных Начало: $e',
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          () {
                            _startWeightController.text =
                                data.start.weight?.toString() ?? '';
                            _startShouldersCircController.text =
                                data.start.shouldersCirc?.toString() ?? '';
                            _startBreastCircController.text =
                                data.start.breastCirc?.toString() ?? '';
                            _startWaistCircController.text =
                                data.start.waistCirc?.toString() ?? '';
                            _startHipsCircController.text =
                                data.start.hipsCirc?.toString() ?? '';
                            setState(() {
                              _isStartEditing = false;
                            });
                          },
                          user,
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
                          _isFinishEditing,
                          canEdit,
                          _finishBodyShape,
                          () => setState(() => _isFinishEditing = true),
                          () async {
                            if (_formKey.currentState!.validate()) {
                              final currentWeight = double.tryParse(
                                _finishWeightController.text,
                              );
                              final currentShouldersCirc = int.tryParse(
                                _finishShouldersCircController.text,
                              );
                              final currentBreastCirc = int.tryParse(
                                _finishBreastCircController.text,
                              );
                              final currentWaistCirc = int.tryParse(
                                _finishWaistCircController.text,
                              );
                              final currentHipsCirc = int.tryParse(
                                _finishHipsCircController.text,
                              );

                              try {
                                await ApiService.updateAnthropometryMeasurements(
                                  clientId: widget.clientId,
                                  type: 'finish',
                                  weight: currentWeight ?? 0.0,
                                  shouldersCirc: currentShouldersCirc ?? 0,
                                  breastCirc: currentBreastCirc ?? 0,
                                  waistCirc: currentWaistCirc ?? 0,
                                  hipsCirc: currentHipsCirc ?? 0,
                                );
                                ref.invalidate(
                                  anthropometryProvider(widget.clientId),
                                );
                                setState(() {
                                  _isFinishEditing = false;
                                  _finishBodyShape = calculateBodyShape(
                                    shouldersCirc: currentShouldersCirc,
                                    waistCirc: currentWaistCirc,
                                    hipsCirc: currentHipsCirc,
                                  );
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Данные Окончание успешно обновлены!',
                                    ),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Ошибка при сохранении данных Окончание: $e',
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          () {
                            _finishWeightController.text =
                                data.finish.weight?.toString() ?? '';
                            _finishShouldersCircController.text =
                                data.finish.shouldersCirc?.toString() ?? '';
                            _finishBreastCircController.text =
                                data.finish.breastCirc?.toString() ?? '';
                            _finishWaistCircController.text =
                                data.finish.waistCirc?.toString() ?? '';
                            _finishHipsCircController.text =
                                data.finish.hipsCirc?.toString() ?? '';
                            setState(() {
                              _isFinishEditing = false;
                            });
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

  Widget _buildRecommendationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Персональные рекомендации',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, child) {
                return ElevatedButton(
                  onPressed: () async {
                    // Show loading dialog
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );

                    try {
                      final recommendation = await ref.read(
                        recommendationProvider(widget.clientId!).future,
                      );
                      
                      Navigator.of(context).pop(); // Dismiss loading dialog

                      // Show result dialog
                      await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Ваша рекомендация'),
                          content: Text(
                            recommendation['client_recommendation'] ??
                                'Рекомендация не найдена.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    } catch (e) {
                      Navigator.of(context).pop(); // Dismiss loading dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Ошибка получения рекомендации: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
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
          contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        ),
        keyboardType: isInt || isDouble
            ? TextInputType.number
            : TextInputType.text,
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
      );
    } else {
      String differenceText = '';
      if (startValue != null) {
        if (isDouble) {
          final double? start = double.tryParse(startValue);
          final double? end = double.tryParse(controller.text);
          if (start != null && end != null) {
            final double diff = end - start;
            if (diff != 0) {
              differenceText =
                  ' (${diff > 0 ? '+' : ''}${diff.toStringAsFixed(1)})';
            }
          }
        } else {
          final int? start = int.tryParse(startValue);
          final int? end = int.tryParse(controller.text);
          if (start != null && end != null) {
            final int diff = end - start;
            if (diff != 0) {
              differenceText = ' (${diff > 0 ? '+' : ''}$diff)';
            }
          }
        }
      }

      valueWidget = RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
              text:
                  '$label: ${controller.text.isEmpty ? 'не указано' : controller.text}',
            ),
            if (differenceText.isNotEmpty)
              TextSpan(
                text: differenceText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: valueWidget,
    );
  }

  Widget _buildEditControls(
    bool isEditing,
    VoidCallback onEdit,
    VoidCallback onSave,
    VoidCallback onCancel,
  ) {
    return isEditing
        ? Row(
            children: [
              IconButton(icon: const Icon(Icons.save), onPressed: onSave),
              IconButton(icon: const Icon(Icons.cancel), onPressed: onCancel),
            ],
          )
        : IconButton(icon: const Icon(Icons.edit), onPressed: onEdit);
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
                Text(
                  'Фиксированные значения',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (canEdit)
                  _buildEditControls(isEditing, onEdit, onSave, onCancel),
              ],
            ),
            const SizedBox(height: 8),
            _buildEditableField(
              'Рост',
              heightController,
              isInt: true,
              isEditing: isEditing,
            ),
            _buildEditableField(
              'Обхват запястья',
              wristCircController,
              isInt: true,
              isEditing: isEditing,
            ),
            _buildEditableField(
              'Обхват лодыжки',
              ankleCircController,
              isInt: true,
              isEditing: isEditing,
            ),
            if (!isEditing) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Соматотип:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  IconButton(
                    icon: const Icon(Icons.help_outline, size: 20),
                    onPressed: _showSomatotypeHelp,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _somatotypeProfile ?? 'Недостаточно данных',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
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
    bool isEditing, // New parameter
    bool canEdit,
    String? bodyShape,
    VoidCallback onEdit,
    VoidCallback onSave,
    VoidCallback onCancel,
    User? user,
  ) {
    final height = int.tryParse(_heightController.text);
    final waistCirc = int.tryParse(waistCircController.text);
    final whtrRatio = (height != null && waistCirc != null && height > 0)
        ? (waistCirc / height)
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              // New: Row for title and edit button
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                if (canEdit)
                  _buildEditControls(isEditing, onEdit, onSave, onCancel),
              ],
            ),
            const SizedBox(height: 8),
            _buildEditableField(
              'Вес',
              weightController,
              isDouble: true,
              isEditing: isEditing,
              startValue: type == 'finish' ? _startWeightController.text : null,
            ),
            _buildEditableField(
              'Обхват плеч',
              shouldersCircController,
              isInt: true,
              isEditing: isEditing,
              startValue: type == 'finish'
                  ? _startShouldersCircController.text
                  : null,
            ),
            _buildEditableField(
              'Обхват груди',
              breastCircController,
              isInt: true,
              isEditing: isEditing,
              startValue: type == 'finish'
                  ? _startBreastCircController.text
                  : null,
            ),
            _buildEditableField(
              'Обхват талии',
              waistCircController,
              isInt: true,
              isEditing: isEditing,
              startValue: type == 'finish'
                  ? _startWaistCircController.text
                  : null,
            ),
            _buildEditableField(
              'Обхват бедер',
              hipsCircController,
              isInt: true,
              isEditing: isEditing,
              startValue: type == 'finish'
                  ? _startHipsCircController.text
                  : null,
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Тип фигуры',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  bodyShape ?? 'Недостаточно данных',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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

  Widget _buildWhtrIndex(double whtr, int? age) {
    String message;
    Color color;
    double progress = (whtr - 0.3) / (0.7 - 0.3); // Normalize for progress bar
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
        // 0.05 is an arbitrary lower bound for 'low risk'
        message = 'Высокий риск истощения';
        color = Colors.red;
      } else if (whtr >= normalWhtrThreshold - 0.05 &&
          whtr < normalWhtrThreshold) {
        message = 'Повышенный риск истощения';
        color = Colors.orange;
      } else if (whtr >= normalWhtrThreshold &&
          whtr <= normalWhtrThreshold + 0.05) {
        // 0.05 is an arbitrary upper bound for 'low risk'
        message = 'Норма, риск низкий';
        color = Colors.green;
      } else if (whtr > normalWhtrThreshold + 0.05 &&
          whtr <= normalWhtrThreshold + 0.1) {
        // 0.1 is an arbitrary upper bound for 'increased risk'
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
        const Text(
          'Индекс здоровья WHtR:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
        const SizedBox(height: 4),
        Text(
          message,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
  void _showSomatotypeHelp() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Справка по соматотипу'),
        content: SingleChildScrollView(
          child: Text(getSomatotypeHelpText(_somatotypeProfile)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }
}
