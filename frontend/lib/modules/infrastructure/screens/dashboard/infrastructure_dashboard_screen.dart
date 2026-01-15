import 'package:fitman_app/modules/infrastructure/providers/equipment_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/room/room.model.dart';
import '../../models/equipment/equipment_item.model.dart';
import '../../models/equipment/equipment_status.enum.dart';
import '../room/room_create_screen.dart';
import '../building/buildings_list_screen.dart';
import '../../providers/room_provider.dart'; // Import the new provider definition
import '../room/rooms_list_screen.dart';
import '../room/room_detail_screen.dart';
import '../../utils/room_utils.dart';

class InfrastructureDashboardScreen extends ConsumerWidget {
  const InfrastructureDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(allRoomsProvider);
    final equipmentItemsAsync = ref.watch(allEquipmentItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Управление помещениями'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // KPI Section
          _buildKpiSection(context, roomsAsync, equipmentItemsAsync),
          const SizedBox(height: 24.0),

          // Room Map Section
          _buildRoomMap(context, roomsAsync),
          const SizedBox(height: 24.0),

          // Quick Actions Placeholder
          _buildQuickActions(context),
        ],
      ),
    );
  }

  Widget _buildKpiSection(
    BuildContext context,
    AsyncValue<List<Room>> roomsAsync,
    AsyncValue<List<EquipmentItem>> equipmentItemsAsync,
  ) {
    final totalRooms = roomsAsync.valueOrNull?.length ?? 0;
    final activeRooms = roomsAsync.valueOrNull
            ?.where((room) => room.isActive && !room.isUnderMaintenance)
            .length ??
        0;
    final roomsUnderMaintenance =
        roomsAsync.valueOrNull?.where((room) => room.isUnderMaintenance).length ?? 0;

    final totalEquipmentItems = equipmentItemsAsync.valueOrNull?.length ?? 0;
    final availableEquipment = equipmentItemsAsync.valueOrNull
            ?.where((item) => item.status == EquipmentStatus.available)
            .length ??
        0;
    final equipmentNeedsMaintenance = equipmentItemsAsync.valueOrNull
            ?.where((item) => item.status == EquipmentStatus.maintenance)
            .length ??
        0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ключевые показатели',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12.0),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            _buildKpiChip(context, 'Всего помещений', totalRooms.toString(), roomsAsync),
            _buildKpiChip(context, 'Всего оборудования', totalEquipmentItems.toString(), equipmentItemsAsync),
            _buildKpiChip(context, 'Залы в работе', activeRooms.toString(), roomsAsync),
            _buildKpiChip(context, 'Оборудование доступно', availableEquipment.toString(), equipmentItemsAsync),
            _buildKpiChip(context, 'На ремонте', roomsUnderMaintenance.toString(), roomsAsync),
            _buildKpiChip(context, 'Требует ТО', equipmentNeedsMaintenance.toString(), equipmentItemsAsync),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiChip(BuildContext context, String title, String value, AsyncValue<dynamic> asyncValue) {
    return Chip(
      padding: const EdgeInsets.all(8.0),
      label: Text(title),
      avatar: asyncValue.when(
        data: (_) => CircleAvatar(
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        loading: () => const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.0)),
        error: (e, s) => const CircleAvatar(child: Icon(Icons.error, size: 18)),
      ),
    );
  }

  Widget _buildRoomMap(BuildContext context, AsyncValue<List<Room>> roomsAsync) {
    return Card(
      elevation: 2.0,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Карта залов',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12.0),
            roomsAsync.when(
              data: (rooms) {
                if (rooms.isEmpty) {
                  return const SizedBox(
                    height: 100,
                    child: Center(child: Text('Нет доступных залов.')),
                  );
                }
                return Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: rooms.map((room) {
                    return SizedBox(
                      width: 120, // Increased width
                      height: 120, // Increased height
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RoomDetailScreen(roomId: room.id),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: _getRoomColor(room),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(room.type.icon, size: 40.0), // Increased icon size
                              const SizedBox(height: 4.0),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: Text(
                                  room.name,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
              error: (err, stack) => SizedBox(height: 100, child: Center(child: Text('Ошибка: ${err.toString()}'))),
            ),
            const SizedBox(height: 16.0),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RoomsListViewScreen()),
                  );
                },
                child: const Text('Все помещения'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoomColor(Room room) {
    if (room.isUnderMaintenance) return Colors.orange.shade100;
    if (room.isActive) return Colors.green.shade100;
    return Colors.grey.shade300;
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Быстрые действия',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12.0),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.business),
                        label: const Text('Здания'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const BuildingsListScreen()),
                          );
                        },
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.add_home_work),
                        label: const Text('Добавить помещение'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RoomCreateScreen()),
                          );
                        },
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.book),
                        label: const Text('Забронировать'),
                        onPressed: () { /* TODO */ },
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.calendar_month),
                        label: const Text('Расписание'),
                        onPressed: () { /* TODO */ },
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
