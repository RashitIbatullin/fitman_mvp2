import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import '../../providers/room/building_provider.dart';
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
              final building = buildings.firstWhereOrNull((b) => b.id == buildingId);
              if (building == null) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          BuildingEditScreen(building: building),
                    ),
                  );
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
           final building = buildings.firstWhereOrNull((b) => b.id == buildingId);
           if (building == null) {
            return const Center(child: Text('Здание не найдено.'));
           }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(allBuildingsProvider.future),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                ListTile(
                  title: const Text('Название'),
                  subtitle: Text(building.name, style: Theme.of(context).textTheme.titleLarge),
                ),
                ListTile(
                  title: const Text('Адрес'),
                  subtitle: Text(building.address),
                ),
                ListTile(
                  title: const Text('Заметка'),
                  subtitle: Text(building.note ?? 'Нет'),
                ),
                if (building.archivedAt != null)
                  ListTile(
                    title: const Text('Дата архивации'),
                    subtitle: Text(building.archivedAt.toString()),
                  ),
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
