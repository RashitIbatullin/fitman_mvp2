import 'package:fitman_app/modules/infrastructure/providers/room_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/room/room.model.dart';
import '../../models/room/room_type.enum.dart'; // Import RoomType enum
import 'room_detail_screen.dart';
import '../../utils/room_utils.dart';

class RoomsListViewScreen extends ConsumerStatefulWidget {
  const RoomsListViewScreen({super.key});

  @override
  ConsumerState<RoomsListViewScreen> createState() =>
      _RoomsListViewScreenState();
}

class _RoomsListViewScreenState extends ConsumerState<RoomsListViewScreen> {
  String _searchQuery = '';
  RoomType? _selectedRoomType;
  String? _selectedFloor;
  bool? _isActiveFilter;

  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(allRoomsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Помещения'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navigate to Add Room Screen
            },
            tooltip: 'Создать помещение',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Поиск по названию',
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
                  child: DropdownButtonFormField<RoomType>(
                    decoration: const InputDecoration(
                      labelText: 'Тип помещения',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _selectedRoomType,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Все')),
                      ...RoomType.values.map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type.displayName),
                          )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedRoomType = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Этаж',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _selectedFloor,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Все')),
                      // TODO: Fetch available floors from data or hardcode for now
                      const DropdownMenuItem(
                          value: '1', child: Text('1 этаж')),
                      const DropdownMenuItem(
                          value: '2', child: Text('2 этаж')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedFloor = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: DropdownButtonFormField<bool>(
                    decoration: const InputDecoration(
                      labelText: 'Статус',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _isActiveFilter,
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Все')),
                      DropdownMenuItem(value: true, child: Text('Активные')),
                      DropdownMenuItem(value: false, child: Text('На ремонте')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _isActiveFilter = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: roomsAsync.when(
              data: (rooms) {
                final filteredRooms = rooms.where((room) {
                  final matchesSearch = _searchQuery.isEmpty ||
                      room.name
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase());
                  final matchesType = _selectedRoomType == null ||
                      room.type == _selectedRoomType;
                  final matchesFloor = _selectedFloor == null ||
                      room.floor == _selectedFloor;
                  final matchesStatus = _isActiveFilter == null ||
                      (_isActiveFilter! && !room.isUnderMaintenance) ||
                      (!_isActiveFilter! && room.isUnderMaintenance);
                  return matchesSearch &&
                      matchesType &&
                      matchesFloor &&
                      matchesStatus;
                }).toList();

                if (filteredRooms.isEmpty) {
                  return const Center(child: Text('Помещения не найдены.'));
                }

                return ListView.builder(
                  itemCount: filteredRooms.length,
                  itemBuilder: (context, index) {
                    final room = filteredRooms[index];
                    return RoomCard(room: room); // Use a dedicated RoomCard widget
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

class RoomCard extends StatelessWidget {
  const RoomCard({super.key, required this.room});

  final Room room;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        leading: SizedBox(
          width: 50,
          height: 50,
          child: room.photoUrls.isNotEmpty
              ? Image.network(
                  room.photoUrls.first,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image),
                )
              : const Icon(Icons.meeting_room),
        ),
        title: Text(room.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Тип: ${room.type.displayName}'),
            Text('Вместимость: ${room.maxCapacity} чел.'),
            Text('Площадь: ${room.area ?? 'N/A'} м²'),
            Row(
              children: [
                Text('Статус: '),
                room.isUnderMaintenance
                    ? const Chip(
                        label: Text('На ремонте'),
                        backgroundColor: Colors.orangeAccent,
                      )
                    : const Chip(
                        label: Text('Активно'),
                        backgroundColor: Colors.greenAccent,
                      ),
              ],
            ),
            // TODO: Add Occupancy (прогресс-бар с % занятости на текущий день)
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RoomDetailScreen(roomId: room.id),
                  ),
                );
              },
              tooltip: 'Просмотр',
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // TODO: Navigate to Room Edit Screen
              },
              tooltip: 'Редактировать',
            ),
            IconButton(
              icon: const Icon(Icons.calendar_month),
              onPressed: () {
                // TODO: Navigate to Booking Form for this room
              },
              tooltip: 'Бронировать',
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
}
