import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/modules/equipment/providers/equipment/equipment_provider.dart';
import 'package:fitman_app/modules/equipment/models/equipment/equipment_status.enum.dart';


import 'package:fitman_app/modules/rooms/providers/room/room_provider.dart';

import 'package:fitman_app/modules/users/providers/users_provider.dart'; // For ArchivedByInfo
import 'package:fitman_app/modules/equipment/screens/equipment/item/equipment_item_edit_screen.dart'; // For edit button

class EquipmentItemDetailScreen extends ConsumerWidget {
  const EquipmentItemDetailScreen({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(equipmentItemByIdProvider(itemId));

    return Scaffold(
      appBar: AppBar(
        title: itemAsync.when(
          data: (item) => Text(item.inventoryNumber),
          loading: () => const Text('Загрузка...'),
          error: (error, stack) => const Text('Ошибка'),
        ),
        actions: [
          itemAsync.when(
            data: (item) => IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EquipmentItemEditScreen(
                      equipmentItem: item,
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
      body: itemAsync.when(
        data: (item) {
          final typeAsync = ref.watch(equipmentTypeByIdProvider(item.typeId));
          final roomAsync = item.roomId != null
              ? ref.watch(roomByIdProvider(item.roomId!))
              : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.photoUrls.isNotEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Image.network(
                        item.photoUrls.first, // Display first photo
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                _buildDetailRow(label: 'Инв. номер:', value: item.inventoryNumber),
                typeAsync.when(
                  data: (type) =>
                      _buildDetailRow(label: 'Тип:', value: type.name),
                  loading: () =>
                      _buildDetailRow(label: 'Тип:', value: 'Загрузка...'),
                  error: (err, stack) =>
                      _buildDetailRow(label: 'Тип:', value: 'Ошибка'),
                ),
                if (item.serialNumber != null && item.serialNumber!.isNotEmpty)
                  _buildDetailRow(label: 'Сер. номер:', value: item.serialNumber!),
                if (item.model != null && item.model!.isNotEmpty)
                  _buildDetailRow(label: 'Модель:', value: item.model!),
                if (item.manufacturer != null && item.manufacturer!.isNotEmpty)
                  _buildDetailRow(label: 'Производитель:', value: item.manufacturer!),
                roomAsync != null
                    ? roomAsync.when(
                        data: (room) =>
                            _buildDetailRow(label: 'Помещение:', value: room.name),
                        loading: () =>
                            _buildDetailRow(label: 'Помещение:', value: 'Загрузка...'),
                        error: (err, stack) =>
                            _buildDetailRow(label: 'Помещение:', value: 'Ошибка'),
                      )
                    : _buildDetailRow(label: 'Помещение:', value: 'Не назначено'),
                if (item.placementNote != null && item.placementNote!.isNotEmpty)
                  _buildDetailRow(label: 'Расположение:', value: item.placementNote!),
                _buildDetailRow(
                  label: 'Статус:',
                  value: item.status.displayName,
                  valueColor: item.status.color,
                ),
                _buildConditionRating(item.conditionRating),
                if (item.conditionNotes != null && item.conditionNotes!.isNotEmpty)
                  _buildDetailRow(label: 'Заметки о состоянии:', value: item.conditionNotes!),
                if (item.lastMaintenanceDate != null)
                  _buildDetailRow(
                      label: 'Последнее ТО:',
                      value: item.lastMaintenanceDate!.toLocal().toIso8601String().substring(0, 10)),
                if (item.nextMaintenanceDate != null)
                  _buildDetailRow(
                      label: 'След. ТО:',
                      value: item.nextMaintenanceDate!.toLocal().toIso8601String().substring(0, 10)),
                if (item.maintenanceNotes != null && item.maintenanceNotes!.isNotEmpty)
                  _buildDetailRow(label: 'Заметки о ТО:', value: item.maintenanceNotes!),
                if (item.purchaseDate != null)
                  _buildDetailRow(
                      label: 'Дата покупки:',
                      value: item.purchaseDate!.toLocal().toIso8601String().substring(0, 10)),
                if (item.purchasePrice != null)
                  _buildDetailRow(
                      label: 'Цена покупки:', value: '${item.purchasePrice}'),
                if (item.supplier != null && item.supplier!.isNotEmpty)
                  _buildDetailRow(label: 'Поставщик:', value: item.supplier!),
                if (item.warrantyMonths != null)
                  _buildDetailRow(
                      label: 'Гарантия (мес.):', value: '${item.warrantyMonths}'),
                _buildDetailRow(label: 'Часы использ.:', value: '${item.usageHours}'),
                if (item.lastUsedDate != null)
                  _buildDetailRow(
                      label: 'Последнее использ.:',
                      value: item.lastUsedDate!.toLocal().toIso8601String().substring(0, 10)),
                if (item.archivedAt != null) ...[
                  const Divider(),
                  _buildDetailRow(
                      label: 'Архивировано:',
                      value: item.archivedAt!.toLocal().toIso8601String().substring(0, 10)),
                  ArchivedByInfo(userId: item.archivedBy),
                  if (item.archivedReason != null && item.archivedReason!.isNotEmpty)
                    _buildDetailRow(label: 'Причина:', value: item.archivedReason!),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Ошибка: $error')),
      ),
    );
  }




}

// Helper function for building detail rows
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

// Helper function for building condition rating stars
Widget _buildConditionRating(int rating) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      children: [
        const SizedBox(
          width: 150,
          child: Text(
            'Состояние:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        ...List.generate(5, (index) {
          return Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 20,
          );
        }),
      ],
    ),
  );
}

class ArchivedByInfo extends ConsumerWidget {
  const ArchivedByInfo({super.key, this.userId});

  final String? userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (userId == null) {
      return _buildDetailRow(label: 'Кто:', value: 'N/A');
    }
    final userIdInt = int.tryParse(userId!);
    if (userIdInt == null) {
      return _buildDetailRow(label: 'Кто:', value: 'Invalid ID');
    }

    final userAsync = ref.watch(userByIdProvider(userIdInt));

    return userAsync.when(
      data: (user) => _buildDetailRow(label: 'Кто:', value: user.shortName),
      loading: () => _buildDetailRow(label: 'Кто:', value: 'Загрузка...'),
      error: (err, stack) => _buildDetailRow(label: 'Кто:', value: 'Ошибка'),
    );
  }
}