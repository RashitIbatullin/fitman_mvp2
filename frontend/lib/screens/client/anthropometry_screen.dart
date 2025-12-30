// ignore_for_file: use_build_context_synchronously, require_trailing_commas

import 'dart:async';

import 'package:fitman_app/models/anthropometry_data.dart';
import 'package:fitman_app/models/whtr_profiles.dart';
import 'package:fitman_app/providers/recommendation_provider.dart';
import 'package:fitman_app/screens/client/photo_comparison_screen.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/providers/auth_provider.dart';
import 'package:fitman_app/utils/body_shape_calculator.dart';
import 'package:fitman_app/utils/body_shape_helper.dart';

final anthropometryProvider =
    FutureProvider.family<AnthropometryData, int?>((ref, clientId) {
  final authState = ref.watch(authProvider);

  return authState.when(
    data: (authData) async {
      final user = authData.user;
      if (user == null) throw Exception('User not authenticated');

      final bool isAdmin = user.roles.any((r) => r.name == 'admin');
      Map<String, dynamic> data;
      if (isAdmin && clientId != null) {
        data = await ApiService.getAnthropometryDataForClient(clientId);
      } else {
        data = await ApiService.getOwnAnthropometryData();
      }
      return AnthropometryData.fromJson(data);
    },
    loading: () => Completer<AnthropometryData>().future,
    error: (e, s) => throw e,
  );
});

// A single provider to get both WHtR profiles at once
final whtrProfilesProvider =
    FutureProvider.family<WhtrProfiles, int?>((ref, clientId) {
  final authState = ref.watch(authProvider);

  return authState.when(
    data: (authData) async {
      final user = authData.user;
      if (user == null) throw Exception('User not authenticated');

      final bool isAdmin = user.roles.any((r) => r.name == 'admin');
      return ApiService.getWhtrProfiles(clientId: clientId, isAdmin: isAdmin);
    },
    loading: () => Completer<WhtrProfiles>().future,
    error: (e, s) => throw e,
  );
});

class AnthropometryScreen extends ConsumerStatefulWidget {
  final int? clientId;
  const AnthropometryScreen({super.key, this.clientId});

  @override
  ConsumerState<AnthropometryScreen> createState() =>
      _AnthropometryScreenState();
}

class _AnthropometryScreenState extends ConsumerState<AnthropometryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

  void _fetchSomatotypeProfile() {
    final user = ref.read(authProvider).value?.user;
    if (user == null) return;

    final bool isAdmin = user.roles.any((r) => r.name == 'admin');

    setState(() {
      _somatotypeProfileFuture = ApiService.getSomatotypeProfile(
        clientId: widget.clientId,
        isAdmin: isAdmin,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      // Refresh recommendations when the "Рекомендации" tab (index 3) is selected.
      if (!_tabController.indexIsChanging && _tabController.index == 3) {
        if (widget.clientId != null) {
          ref.invalidate(recommendationProvider(widget.clientId!));
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initializeControllers(
    AnthropometryFixed fixed,
    AnthropometryMeasurements start,
    AnthropometryMeasurements finish,
  ) {
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
    final anthropometryDataAsync =
        ref.watch(anthropometryProvider(widget.clientId));
    final authState = ref.watch(authProvider);
    final loggedInUser = authState.value?.user;

    return anthropometryDataAsync.when(
      data: (anthropometryData) {
        if (!_controllersInitialized) {
          _initializeControllers(anthropometryData.fixed,
              anthropometryData.start, anthropometryData.finish);
          _startPhotoUrl = anthropometryData.start.photo;
          _finishPhotoUrl = anthropometryData.finish.photo;
          _startPhotoDateTime = anthropometryData.start.photoDateTime;
          _finishPhotoDateTime = anthropometryData.finish.photoDateTime;
          _startProfilePhotoUrl = anthropometryData.start.profilePhoto;
          _finishProfilePhotoUrl = anthropometryData.finish.profilePhoto;
          _startProfilePhotoDateTime =
              anthropometryData.start.profilePhotoDateTime;
          _finishProfilePhotoDateTime =
              anthropometryData.finish.profilePhotoDateTime;
          _controllersInitialized = true;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _fetchSomatotypeProfile();
          });
        }

        final canEdit = loggedInUser != null &&
            (!loggedInUser.roles.any((r) => r.name == 'client') ||
                loggedInUser.roles.length > 1);


        return Form(
          key: _formKey,
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).colorScheme.primary,
                indicatorColor: Theme.of(context).colorScheme.primary,
                tabs: const [
                  Tab(text: 'Фиксированные'),
                  Tab(text: 'Начальные'),
                  Tab(text: 'Конечные'),
                  Tab(text: 'Рекомендации'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Fixed Tab
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildFixedMeasurementsCard(
                        anthropometryData.fixed,
                        _heightController,
                        _wristCircController,
                        _ankleCircController,
                        canEdit,
                        _isFixedEditing,
                        () => setState(() => _isFixedEditing = true),
                        () async {
                          if (_formKey.currentState!.validate()) {
                            final currentHeight =
                                int.tryParse(_heightController.text);
                            final currentWristCirc =
                                int.tryParse(_wristCircController.text);
                            final currentAnkleCirc =
                                int.tryParse(_ankleCircController.text);

                            try {
                              await ApiService.updateAnthropometryFixed(
                                clientId: widget.clientId,
                                height: currentHeight ?? 0,
                                wristCirc: currentWristCirc ?? 0,
                                ankleCirc: currentAnkleCirc ?? 0,
                              );
                              ref.invalidate(
                                  anthropometryProvider(widget.clientId));
                              ref.invalidate(
                                  whtrProfilesProvider(widget.clientId));
                              setState(() {
                                _isFixedEditing = false;
                                _fetchSomatotypeProfile();
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Фиксированные данные успешно обновлены!')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Ошибка при сохранении фиксированных данных: $e')),
                              );
                            }
                          }
                        },
                        () {
                          _heightController.text =
                              anthropometryData.fixed.height?.toString() ?? '';
                          _wristCircController.text =
                              anthropometryData.fixed.wristCirc?.toString() ??
                                  '';
                          _ankleCircController.text =
                              anthropometryData.fixed.ankleCirc?.toString() ??
                                  '';
                          setState(() => _isFixedEditing = false);
                        },
                      ),
                    ),

                    // Start Tab
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildMeasurementsCard(
                        title: 'Начальные значения',
                        type: 'start',
                        weightController: _startWeightController,
                        shouldersCircController: _startShouldersCircController,
                        breastCircController: _startBreastCircController,
                        waistCircController: _startWaistCircController,
                        hipsCircController: _startHipsCircController,
                        isEditing: _isStartEditing,
                        canEdit: canEdit,
                        bodyShape: _startBodyShape,
                        onEdit: () => setState(() => _isStartEditing = true),
                        onSave: () async {
                          if (_formKey.currentState!.validate()) {
                            final currentWeight =
                                double.tryParse(_startWeightController.text);
                            final currentShouldersCirc =
                                int.tryParse(_startShouldersCircController.text);
                            final currentBreastCirc =
                                int.tryParse(_startBreastCircController.text);
                            final currentWaistCirc =
                                int.tryParse(_startWaistCircController.text);
                            final currentHipsCirc =
                                int.tryParse(_startHipsCircController.text);

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
                                  anthropometryProvider(widget.clientId));
                              ref.invalidate(
                                  whtrProfilesProvider(widget.clientId));
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
                                    content:
                                        Text('Данные Начало успешно обновлены!')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Ошибка при сохранении данных Начало: $e')),
                              );
                            }
                          }
                        },
                        onCancel: () {
                          _startWeightController.text =
                              anthropometryData.start.weight?.toString() ?? '';
                          _startShouldersCircController.text =
                              anthropometryData.start.shouldersCirc
                                      ?.toString() ??
                                  '';
                          _startBreastCircController.text =
                              anthropometryData.start.breastCirc?.toString() ??
                                  '';
                          _startWaistCircController.text =
                              anthropometryData.start.waistCirc?.toString() ??
                                  '';
                          _startHipsCircController.text =
                              anthropometryData.start.hipsCirc?.toString() ?? '';
                          setState(() => _isStartEditing = false);
                        },
                      ),
                    ),

                    // Finish Tab
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildMeasurementsCard(
                        title: 'Конечные значения',
                        type: 'finish',
                        weightController: _finishWeightController,
                        shouldersCircController: _finishShouldersCircController,
                        breastCircController: _finishBreastCircController,
                        waistCircController: _finishWaistCircController,
                        hipsCircController: _finishHipsCircController,
                        isEditing: _isFinishEditing,
                        canEdit: canEdit,
                        bodyShape: _finishBodyShape,
                        onEdit: () => setState(() => _isFinishEditing = true),
                        onSave: () async {
                          if (_formKey.currentState!.validate()) {
                            final currentWeight =
                                double.tryParse(_finishWeightController.text);
                            final currentShouldersCirc = int.tryParse(
                                _finishShouldersCircController.text);
                            final currentBreastCirc =
                                int.tryParse(_finishBreastCircController.text);
                            final currentWaistCirc =
                                int.tryParse(_finishWaistCircController.text);
                            final currentHipsCirc =
                                int.tryParse(_finishHipsCircController.text);

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
                                  anthropometryProvider(widget.clientId));
                              ref.invalidate(
                                  whtrProfilesProvider(widget.clientId));
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
                                        'Данные Окончание успешно обновлены!')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Ошибка при сохранении данных Окончание: $e')),
                              );
                            }
                          }
                        },
                        onCancel: () {
                          _finishWeightController.text =
                              anthropometryData.finish.weight?.toString() ?? '';
                          _finishShouldersCircController.text =
                              anthropometryData.finish.shouldersCirc
                                      ?.toString() ??
                                  '';
                          _finishBreastCircController.text =
                              anthropometryData.finish.breastCirc?.toString() ??
                                  '';
                          _finishWaistCircController.text =
                              anthropometryData.finish.waistCirc?.toString() ??
                                  '';
                          _finishHipsCircController.text =
                              anthropometryData.finish.hipsCirc?.toString() ??
                                  '';
                          setState(() => _isFinishEditing = false);
                        },
                      ),
                    ),
                    // Recommendation Tab
                    SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildRecommendationCard()),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
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
                            initialStartProfilePhotoUrl:
                                _startProfilePhotoUrl,
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
                          _startPhotoDateTime =
                              result['startPhotoDateTime'];
                          _finishPhotoDateTime =
                              result['finishPhotoDateTime'];
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
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) =>
          Center(child: Text('Ошибка загрузки антропометрии: $e')),
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
                Text('Фиксированные значения',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold, color: Colors.blue)),
                if (canEdit)
                  _buildEditControls(isEditing, onEdit, onSave, onCancel),
              ],
            ),
            const SizedBox(height: 8),
            _buildEditableField('Рост', heightController,
                isInt: true, isEditing: isEditing),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Определение соматотипа',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  const SizedBox(height: 8),
                  _buildEditableField('Обхват запястья', wristCircController,
                      isInt: true, isEditing: isEditing),
                  _buildEditableField('Обхват лодыжки', ankleCircController,
                      isInt: true, isEditing: isEditing),
                  if (!isEditing) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text('Соматотип:',
                            style: Theme.of(context).textTheme.titleMedium),
                        IconButton(
                            icon: const Icon(Icons.help_outline, size: 20),
                            onPressed: _showSomatotypeHelp),
                      ],
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<String>(
                      future: _somatotypeProfileFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text('Расчет...');
                        } else if (snapshot.hasError) {
                          return const Text('Недостаточно данных',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold));
                        } else if (snapshot.hasData) {
                          return Text(
                            snapshot.data ?? 'Недостаточно данных',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          );
                        } else {
                          return const Text(
                              'Недостаточно данных для расчета.');
                        }
                      },
                    ),
                  ],
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementsCard({
    required String title,
    required String type,
    required TextEditingController weightController,
    required TextEditingController shouldersCircController,
    required TextEditingController breastCircController,
    required TextEditingController waistCircController,
    required TextEditingController hipsCircController,
    required bool isEditing,
    required bool canEdit,
    required String? bodyShape,
    required VoidCallback onEdit,
    required VoidCallback onSave,
    required VoidCallback onCancel,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold, color: Colors.blue)),
                if (canEdit)
                  _buildEditControls(isEditing, onEdit, onSave, onCancel),
              ],
            ),
            const SizedBox(height: 8),
            _buildEditableField('Вес', weightController,
                isDouble: true,
                isEditing: isEditing,
                startValue:
                    type == 'finish' ? _startWeightController.text : null),
            _buildEditableField('Обхват плеч', shouldersCircController,
                isInt: true,
                isEditing: isEditing,
                startValue: type == 'finish'
                    ? _startShouldersCircController.text
                    : null),
            _buildEditableField('Обхват груди', breastCircController,
                isInt: true,
                isEditing: isEditing,
                startValue: type == 'finish'
                    ? _startBreastCircController.text
                    : null),
            _buildEditableField('Обхват талии', waistCircController,
                isInt: true,
                isEditing: isEditing,
                startValue:
                    type == 'finish' ? _startWaistCircController.text : null),
            _buildEditableField('Обхват бедер', hipsCircController,
                isInt: true,
                isEditing: isEditing,
                startValue:
                    type == 'finish' ? _startHipsCircController.text : null),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Тип фигуры',
                        style: Theme.of(context).textTheme.titleMedium),
                    IconButton(
                        icon: const Icon(Icons.help_outline, size: 20),
                        onPressed: () => _showBodyShapeHelp(bodyShape)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(bodyShape ?? 'Недостаточно данных',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Индекс здоровья WHtR:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Consumer(
              builder: (context, ref, child) {
                final whtrAsync =
                    ref.watch(whtrProfilesProvider(widget.clientId));

                return whtrAsync.when(
                  data: (profiles) {
                    final profile =
                        type == 'start' ? profiles.start : profiles.finish;

                    final colors = {
                      'Риск истощения': Colors.red,
                      'Норма': Colors.green,
                      'Избыточный вес': Colors.orange,
                      'Ожирение': Colors.red,
                    };
                    final color = colors[profile.gradation] ?? Colors.grey;
                    final progress =
                        (profile.ratio - 0.3).clamp(0.0, 1.0) / (0.7 - 0.3);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey[300],
                            valueColor:
                                AlwaysStoppedAnimation<Color>(color)),
                        const SizedBox(height: 4),
                        Text(
                            '${profile.gradation} (коэф: ${profile.ratio.toStringAsFixed(2)})',
                            style: TextStyle(
                                color: color, fontWeight: FontWeight.bold)),
                      ],
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text('Расчет...'),
                  ),
                  error: (e, s) => Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text('Ошибка: $e',
                        style: const TextStyle(color: Colors.red)),
                  ),
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
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        ),
        keyboardType:
            isInt || isDouble ? TextInputType.number : TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Поле не может быть пустым';
          }
          if (isInt && int.tryParse(value) == null) {
            return 'Введите целое число';
          }
          if (isDouble && double.tryParse(value) == null) {
            return 'Введите число';
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
            if (diff != 0) differenceText = ' (${diff > 0 ? '+' : ''}$diff)';
          }
        }
      }
      valueWidget = RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium, // Explicitly set style
          children: [
            TextSpan(
                text:
                    '$label: ${controller.text.isEmpty ? 'не указано' : controller.text}'),
            if (differenceText.isNotEmpty)
              TextSpan(
                  text: differenceText,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black)),
          ],
        ),
      );
    }
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: valueWidget);
  }

  Widget _buildEditControls(bool isEditing, VoidCallback onEdit,
      VoidCallback onSave, VoidCallback onCancel) {
    return isEditing
        ? Row(children: [
            IconButton(icon: const Icon(Icons.save), onPressed: onSave),
            IconButton(icon: const Icon(Icons.cancel), onPressed: onCancel),
          ])
        : IconButton(icon: const Icon(Icons.edit), onPressed: onEdit);
  }

  Widget _buildRecommendationCard() {
    if (widget.clientId == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('ID клиента не указан, рекомендации не могут быть загружены.'),
          ),
        ),
      );
    }

    final recommendationAsync =
        ref.watch(recommendationProvider(widget.clientId!));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Персональные рекомендации',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 16),
            recommendationAsync.when(
              data: (recommendation) => Text(
                  recommendation['client_recommendation'] ??
                      'Рекомендация не найдена.'),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('Ошибка загрузки: $e',
                  style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  void _showBodyShapeHelp(String? bodyShape) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Справка по типу фигуры'),
        content:
            SingleChildScrollView(child: Text(getBodyShapeHelpText(bodyShape))),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Закрыть'))
        ],
      ),
    );
  }

  void _showSomatotypeHelp() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Справка по соматотипу'),
          content: const SingleChildScrollView(
            child: Text(
              'Это экспериментальное определение генетического строения тела по методу ученого Соловьева. В расчет рекомендаций включается, только если одно из значений будет больше 70%.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }
}