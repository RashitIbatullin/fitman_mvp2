import 'package:fitman_app/modules/infrastructure/models/building/building.model.dart';
import 'package:fitman_app/modules/infrastructure/providers/building_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'building_edit_screen.dart';

class BuildingDetailScreen extends ConsumerWidget {
  final String buildingId;

  const BuildingDetailScreen({super.key, required this.buildingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buildingsAsync = ref.watch(allBuildingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали здания'),
        actions: [
          buildingsAsync.when(
            data: (buildings) {
              final building = buildings.firstWhere(
                  (b) => b.id == buildingId,
                  orElse: () => const Building(id: '', name: '', address: ''));
              return IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  if (building.id.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            BuildingEditScreen(building: building),
                      ),
                    );
                  }
                },
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (e, s) => const SizedBox.shrink(),
          )
        ],
      ),
      body: buildingsAsync.when(
        data: (buildings) {
          final building = buildings.firstWhere((b) => b.id == buildingId, orElse: () => const Building(id: '', name: 'Not Found', address: ''));

          if (building.name == 'Not Found') {
            return const Center(child: Text('Здание не найдено.'));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Название: ${building.name}',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('Адрес: ${building.address}'),
                const SizedBox(height: 8),
                Text('Заметка: ${building.note ?? 'Нет'}'),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Ошибка: $err')),
      ),
    );
  }
}
