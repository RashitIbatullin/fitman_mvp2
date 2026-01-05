import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/room/room.model.dart';
import '../../providers/room_provider.dart';
import '../../utils/room_utils.dart';

class RoomDetailScreen extends ConsumerWidget {
  const RoomDetailScreen({super.key, required this.roomId});

  final String roomId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomAsync = ref.watch(roomByIdProvider(roomId));

    return Scaffold(
      appBar: AppBar(
        title: roomAsync.when(
          data: (room) => Text(room.name),
          loading: () => const Text('Загрузка...'),
          error: (err, stack) => const Text('Ошибка'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Navigate to Edit Room Screen
            },
            tooltip: 'Редактировать',
          )
        ],
      ),
      body: roomAsync.when(
        data: (room) => _buildRoomDetails(context, room),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Ошибка: $err')),
      ),
    );
  }

  Widget _buildRoomDetails(BuildContext context, Room room) {
    return DefaultTabController(
      length: 5, // Number of tabs
      child: Column(
        children: [
          const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Основное'),
              Tab(text: 'Расписание'),
              Tab(text: 'Состояние'),
              Tab(text: 'Оборудование'),
              Tab(text: 'Статистика'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // 1. Основное
                _buildMainInfoTab(context, room),
                // 2. Расписание (Placeholder)
                const Center(child: Text('Информация о расписании')),
                // 3. Состояние (Placeholder)
                const Center(child: Text('Информация о состоянии')),
                // 4. Оборудование (Placeholder)
                const Center(child: Text('Информация об оборудовании')),
                // 5. Статистика (Placeholder)
                const Center(child: Text('Информация о статистике')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainInfoTab(BuildContext context, Room room) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TODO: Add Image Carousel
          _buildInfoRow(context, 'Название:', room.name),
          _buildInfoRow(context, 'Тип:', room.type.displayName),
          _buildInfoRow(context, 'Описание:', room.description ?? 'N/A'),
          _buildInfoRow(context, 'Этаж:', room.floor ?? 'N/A'),
          _buildInfoRow(context, 'Корпус:', room.building ?? 'N/A'),
          _buildInfoRow(context, 'Вместимость:', '${room.maxCapacity} чел.'),
          _buildInfoRow(context, 'Площадь:', '${room.area ?? 'N/A'} м²'),
          _buildInfoRow(context, 'Зеркала:', room.hasMirrors ? 'Да' : 'Нет'),
          _buildInfoRow(context, 'Аудиосистема:', room.hasSoundSystem ? 'Да' : 'Нет'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}
