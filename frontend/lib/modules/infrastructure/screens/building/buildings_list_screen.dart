import 'package:fitman_app/modules/infrastructure/models/building/building.model.dart';
import 'package:fitman_app/modules/infrastructure/providers/building_provider.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:fitman_app/widgets/filter_popup_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'building_create_screen.dart';
import 'building_detail_screen.dart';
import 'building_edit_screen.dart';

final buildingIsArchivedFilterProvider = StateProvider<bool?>((ref) => false);

class BuildingsListScreen extends ConsumerStatefulWidget {
  const BuildingsListScreen({super.key});

  @override
  ConsumerState<BuildingsListScreen> createState() =>
      _BuildingsListScreenState();
}

class _BuildingsListScreenState extends ConsumerState<BuildingsListScreen> {
  Building? _selectedBuilding;

  Future<void> _archiveBuilding() async {
    if (_selectedBuilding == null) return;
    try {
      await ApiService.deleteBuilding(_selectedBuilding!.id);
      ref.invalidate(allBuildingsProvider);
      if(mounted) {
        setState(() => _selectedBuilding = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Здание архивировано')),
        );
      }
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка архивации: $e')),
        );
      }
    }
  }

  Future<void> _unarchiveBuilding() async {
    if (_selectedBuilding == null) return;
    try {
      // Create a new building object with archivedAt set to null, which is what the backend expects for un-archiving
      final building = _selectedBuilding!.copyWith(archivedAt: null);
      await ApiService.updateBuilding(_selectedBuilding!.id, building);
      ref.invalidate(allBuildingsProvider);
      if(mounted) {
        setState(() => _selectedBuilding = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Здание восстановлено из архива')),
        );
      }
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка восстановления: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final buildingsAsync = ref.watch(allBuildingsProvider);
    final isArchivedFilter = ref.watch(buildingIsArchivedFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Здания'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                FilterPopupMenuButton<String>(
                  tooltip: 'Действия',
                  allOptionText: 'Действия',
                  showAllOption: false,
                  initialValue: null,
                  avatar: const Icon(Icons.more_vert),
                  onSelected: (value) async {
                    switch (value) {
                      case 'add':
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const BuildingCreateScreen()),
                        );
                        ref.read(allBuildingsProvider.notifier).refresh();
                        break;
                      case 'edit':
                        if (_selectedBuilding != null) {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  BuildingEditScreen(building: _selectedBuilding!),
                            ),
                          );
                          ref.read(allBuildingsProvider.notifier).refresh();
                        }
                        break;
                      case 'archive':
                        _archiveBuilding();
                        break;
                      case 'unarchive':
                        _unarchiveBuilding();
                        break;
                    }
                  },
                  options: [
                    const FilterOption(label: 'Добавить', value: 'add'),
                                  FilterOption(
                                      label: 'Изменить',
                                      value: 'edit',
                                      enabled: _selectedBuilding != null && _selectedBuilding?.archivedAt == null),                    FilterOption(
                        label: 'Архивировать',
                        value: 'archive',
                        enabled: _selectedBuilding != null && _selectedBuilding?.archivedAt == null),
                    FilterOption(
                        label: 'Деархивировать',
                        value: 'unarchive',
                        enabled: _selectedBuilding != null && _selectedBuilding?.archivedAt != null),
                  ],
                ),
                const SizedBox(width: 8),
                FilterPopupMenuButton<bool?>(
                  tooltip: 'Статус',
                  allOptionText: 'Статус: Все',
                  initialValue: isArchivedFilter,
                  avatar: const Icon(Icons.archive_outlined),
                  onSelected: (value) {
                    ref.read(buildingIsArchivedFilterProvider.notifier).state = value;
                  },
                  options: const [
                    FilterOption(label: 'Не в архиве', value: false),
                    FilterOption(label: 'В архиве', value: true),
                  ],
                  showAllOption: true,
                ),
              ],
            ),
          ),
        ),
      ),
      body: buildingsAsync.when(
        data: (buildings) {
          if (buildings.isEmpty) {
            return const Center(child: Text('Здания не найдены.'));
          }
          return ListView.builder(
            itemCount: buildings.length,
            itemBuilder: (context, index) {
              final building = buildings[index];
              final isSelected = _selectedBuilding?.id == building.id;

              
              return Card(
                color: building.archivedAt != null ? Colors.grey[200] : null,
                margin:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  selected: isSelected,
                  selectedTileColor: Theme.of(context).primaryColorLight,
                  title: Text(building.name),
                  subtitle: Text(building.address),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            BuildingDetailScreen(buildingId: building.id),
                      ),
                    );
                  },
                  onLongPress: () {
                    setState(() {
                      _selectedBuilding = isSelected ? null : building;
                    });
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Ошибка: $err')),
      ),
    );
  }
}

