import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/modules/equipment/providers/equipment/equipment_provider.dart';
import 'package:fitman_app/modules/equipment/screens/equipment/type/equipment_type_edit_screen.dart';

class EquipmentTypeDetailScreen extends ConsumerWidget {
  final String equipmentTypeId;

  const EquipmentTypeDetailScreen({
    super.key,
    required this.equipmentTypeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equipmentTypeAsyncValue = ref.watch(equipmentTypeByIdProvider(equipmentTypeId));

    return Scaffold(
      appBar: AppBar(
        title: equipmentTypeAsyncValue.when(
          data: (equipmentType) => Text(equipmentType.name),
          loading: () => const Text('Загрузка...'),
          error: (error, stack) => const Text('Ошибка'),
        ),
        actions: [
          equipmentTypeAsyncValue.when(
            data: (equipmentType) => IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EquipmentTypeEditScreen(
                      equipmentTypeId: equipmentType.id,
                      // Pass the existing equipmentType object to the edit screen
                      // to pre-fill the form.
                      equipmentType: equipmentType,
                    ),
                  ),
                );
              },
            ),
            loading: () => const SizedBox.shrink(),
            error: (error, stack) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: equipmentTypeAsyncValue.when(
        data: (equipmentType) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (equipmentType.photoUrl != null && equipmentType.photoUrl!.isNotEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Image.network(
                        equipmentType.photoUrl!,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                _buildDetailRow(
                  label: 'Название:',
                  value: equipmentType.name,
                ),
                if (equipmentType.description != null && equipmentType.description!.isNotEmpty)
                  _buildDetailRow(
                    label: 'Описание:',
                    value: equipmentType.description!,
                  ),
                _buildDetailRow(
                  label: 'Категория:',
                  value: equipmentType.category.name,
                ),
                if (equipmentType.weightRange != null && equipmentType.weightRange!.isNotEmpty)
                  _buildDetailRow(
                    label: 'Диапазон веса:',
                    value: equipmentType.weightRange!,
                  ),
                if (equipmentType.dimensions != null && equipmentType.dimensions!.isNotEmpty)
                  _buildDetailRow(
                    label: 'Габариты:',
                    value: equipmentType.dimensions!,
                  ),
                if (equipmentType.powerRequirements != null && equipmentType.powerRequirements!.isNotEmpty)
                  _buildDetailRow(
                    label: 'Требования к питанию:',
                    value: equipmentType.powerRequirements!,
                  ),
                _buildDetailRow(
                  label: 'Мобильное:',
                  value: equipmentType.isMobile ? 'Да' : 'Нет',
                ),
                if (equipmentType.exerciseTypeId != null && equipmentType.exerciseTypeId!.isNotEmpty)
                  _buildDetailRow(
                    label: 'ID типа упражнения:',
                    value: equipmentType.exerciseTypeId!,
                  ),
                if (equipmentType.manualUrl != null && equipmentType.manualUrl!.isNotEmpty)
                  _buildDetailRow(
                    label: 'Ссылка на руководство:',
                    value: equipmentType.manualUrl!,
                  ),
                _buildDetailRow(
                  label: 'Активно:',
                  value: equipmentType.isActive ? 'Да' : 'Нет',
                  valueColor: equipmentType.isActive ? Colors.green : Colors.red,
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Ошибка: $error')),
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}