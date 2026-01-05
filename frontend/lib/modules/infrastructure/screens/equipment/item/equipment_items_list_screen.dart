import 'package:fitman_app/modules/infrastructure/providers/equipment_provider.dart';
import 'package:fitman_app/modules/infrastructure/providers/room_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/equipment/equipment_item.model.dart';
import '../../../models/equipment/equipment_status.enum.dart';
import '../../../models/equipment/equipment_type.model.dart';
import '../../../models/room/room.model.dart';

class EquipmentItemsListViewScreen extends ConsumerStatefulWidget {
  const EquipmentItemsListViewScreen({super.key});

  @override
  ConsumerState<EquipmentItemsListViewScreen> createState() =>
      _EquipmentItemsListViewScreenState();
}

class _EquipmentItemsListViewScreenState
    extends ConsumerState<EquipmentItemsListViewScreen> {
  String _searchQuery = '';
  EquipmentType? _selectedEquipmentType;
  EquipmentStatus? _selectedStatus;
  String? _selectedRoomId;
  int? _selectedConditionRating;

  String? _getRoomName(List<Room>? rooms, String? roomId) {
    if (rooms == null || roomId == null) return 'Не назначено';
    try {
      return rooms.firstWhere((room) => room.id == roomId).name;
    } catch (e) {
      return 'Неизвестно';
    }
  }

  String? _getEquipmentTypeName(List<EquipmentType>? types, String typeId) {
    if (types == null) return 'N/A';
    try {
      return types.firstWhere((type) => type.id == typeId).name;
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    final equipmentItemsAsync = ref.watch(allEquipmentItemsProvider);
    final equipmentTypesAsync = ref.watch(allEquipmentTypesProvider);
    final roomsAsync = ref.watch(allRoomsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Оборудование'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navigate to Add Equipment Item Screen
            },
            tooltip: 'Добавить оборудование',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Поиск по инв. номеру, модели, производителю',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: equipmentTypesAsync.when(
                    data: (types) => DropdownButtonFormField<EquipmentType>(
                      decoration: const InputDecoration(
                        labelText: 'Тип оборудования',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: _selectedEquipmentType,
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Все')),
                        ...types.map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type.name),
                            )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedEquipmentType = value;
                        });
                      },
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) =>
                        Text('Error loading types: ${err.toString()}'),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: DropdownButtonFormField<EquipmentStatus>(
                    decoration: const InputDecoration(
                      labelText: 'Статус',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _selectedStatus,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Все')),
                      ...EquipmentStatus.values.map((status) =>
                          DropdownMenuItem(
                            value: status,
                            child: Text(status.name),
                          )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              children: [
                Expanded(
                  child: roomsAsync.when(
                    data: (rooms) => DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Помещение',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: _selectedRoomId,
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Все')),
                        ...rooms.map((room) => DropdownMenuItem(
                              value: room.id,
                              child: Text(room.name),
                            )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedRoomId = value;
                        });
                      },
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) =>
                        Text('Error loading rooms: ${err.toString()}'),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Состояние',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _selectedConditionRating,
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Все')),
                      DropdownMenuItem(value: 5, child: Text('5 - Отличное')),
                      DropdownMenuItem(value: 4, child: Text('4 - Хорошее')),
                      DropdownMenuItem(value: 3, child: Text('3 - Удовлетвор.')),
                      DropdownMenuItem(value: 2, child: Text('2 - Плохое')),
                      DropdownMenuItem(value: 1, child: Text('1 - Очень плохое')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedConditionRating = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: equipmentItemsAsync.when(
              data: (items) {
                final filteredItems = items.where((item) {
                  final matchesSearch = _searchQuery.isEmpty ||
                      item.inventoryNumber
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()) ||
                      (item.model != null &&
                          item.model!
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase())) ||
                      (item.manufacturer != null &&
                          item.manufacturer!
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()));
                  final matchesType = _selectedEquipmentType == null ||
                      item.typeId == _selectedEquipmentType!.id;
                  final matchesStatus = _selectedStatus == null ||
                      item.status == _selectedStatus;
                  final matchesRoom =
                      _selectedRoomId == null || item.roomId == _selectedRoomId;
                  final matchesCondition = _selectedConditionRating == null ||
                      item.conditionRating == _selectedConditionRating;

                  return matchesSearch &&
                      matchesType &&
                      matchesStatus &&
                      matchesRoom &&
                      matchesCondition;
                }).toList();

                if (filteredItems.isEmpty) {
                  return const Center(
                      child: Text('Экземпляры оборудования не найдены.'));
                }

                return ListView.builder(
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return EquipmentItemCard(
                      item: item,
                      roomName: _getRoomName(roomsAsync.value, item.roomId),
                      equipmentTypeName: _getEquipmentTypeName(equipmentTypesAsync.value, item.typeId),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

class EquipmentItemCard extends StatelessWidget {
  const EquipmentItemCard({
    super.key,
    required this.item,
    this.roomName,
    this.equipmentTypeName,
  });

  final EquipmentItem item;
  final String? roomName;
  final String? equipmentTypeName;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        leading: SizedBox(
          width: 50,
          height: 50,
          child: item.photoUrls.isNotEmpty
              ? Image.network(
                  item.photoUrls.first,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image),
                )
              : const Icon(Icons.fitness_center),
        ),
        title: Text(item.inventoryNumber),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Тип: ${equipmentTypeName ?? 'N/A'}'),
            Text('Модель: ${item.model ?? 'N/A'}'),
            Text('Производитель: ${item.manufacturer ?? 'N/A'}'),
            Text('Помещение: ${roomName ?? 'Не назначено'}'),
            Row(
              children: [
                const Text('Статус: '),
                Chip(
                  label: Text(item.status.name),
                  backgroundColor: _getStatusColor(item.status),
                ),
              ],
            ),
            Row(
              children: [
                const Text('Состояние: '),
                ...List.generate(5, (index) {
                  return Icon(
                    index < item.conditionRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  );
                }),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility),
              onPressed: () {
                // TODO: Navigate to Equipment Item Detail Card
              },
              tooltip: 'Просмотр',
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // TODO: Navigate to Equipment Item Edit Screen
              },
              tooltip: 'Редактировать',
            ),
            IconButton(
              icon: const Icon(Icons.calendar_month),
              onPressed: () {
                // TODO: Navigate to Booking Form for this item
              },
              tooltip: 'Бронировать',
            ),
            IconButton(
              icon: const Icon(Icons.build),
              onPressed: () {
                // TODO: Implement Mark for Maintenance functionality
              },
              tooltip: 'Отметить ТО',
            ),
            IconButton(
              icon: const Icon(Icons.archive),
              onPressed: () {
                // TODO: Implement Archive functionality
              },
              tooltip: 'Архивировать',
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(EquipmentStatus status) {
    switch (status) {
      case EquipmentStatus.available:
        return Colors.greenAccent;
      case EquipmentStatus.inUse:
        return Colors.blueAccent;
      case EquipmentStatus.reserved:
        return Colors.yellowAccent;
      case EquipmentStatus.maintenance:
        return Colors.orangeAccent;
      case EquipmentStatus.outOfOrder:
        return Colors.redAccent;
      case EquipmentStatus.storage:
        return Colors.grey;
    }
  }
}
