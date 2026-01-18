import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/modules/equipment/providers/equipment/equipment_provider.dart';

import 'package:fitman_app/modules/equipment/models/equipment/equipment_category.enum.dart';
import 'package:fitman_app/modules/equipment/screens/equipment/type/equipment_type_detail_screen.dart';
import 'package:fitman_app/modules/equipment/screens/equipment/type/equipment_type_edit_screen.dart';

class EquipmentTypesListScreen extends ConsumerWidget {
  const EquipmentTypesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equipmentTypesAsyncValue = ref.watch(allEquipmentTypesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Типы оборудования'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
          PopupMenuButton<EquipmentCategory>(
            onSelected: (category) {
              // TODO: Implement filter functionality
              print('Filter by: $category');
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: null,
                  child: Text('Все категории'),
                ),
                ...EquipmentCategory.values.map((category) => PopupMenuItem(
                      value: category,
                      child: Text(category.displayName),
                    )),
              ];
            },
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EquipmentTypeEditScreen(), // For creating new
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: equipmentTypesAsyncValue.when(
        data: (equipmentTypes) {
          if (equipmentTypes.isEmpty) {
            return const Center(
              child: Text('Нет типов оборудования'),
            );
          }
          return ListView.builder(
            itemCount: equipmentTypes.length,
            itemBuilder: (context, index) {
              final equipmentType = equipmentTypes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColorLight, // Add a background color for visibility
                    child: Icon(
                      equipmentType.category.icon,
                      color: Theme.of(context).primaryColorDark, // Ensure icon color contrasts with background
                    ),
                    // If a photoUrl exists, it will be ignored here to prioritize the icon.
                    // If photo display is critical, a different UI approach (e.g., Stack) would be needed.
                  ),
                  title: Text(equipmentType.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Категория: ${equipmentType.category.displayName}'),
                      if (equipmentType.weightRange != null && equipmentType.weightRange!.isNotEmpty)
                        Text('Вес: ${equipmentType.weightRange}'),
                      if (equipmentType.dimensions != null && equipmentType.dimensions!.isNotEmpty)
                        Text('Габариты: ${equipmentType.dimensions}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        equipmentType.isActive ? Icons.check_circle : Icons.cancel,
                        color: equipmentType.isActive ? Colors.green : Colors.red,
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'view') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EquipmentTypeDetailScreen(equipmentTypeId: equipmentType.id),
                              ),
                            );
                          } else if (value == 'edit') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EquipmentTypeEditScreen(equipmentTypeId: equipmentType.id),
                              ),
                            );
                          } else if (value == 'archive') {
                            // TODO: Implement archive logic
                            print('Archive ${equipmentType.name}');
                          }
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'view',
                            child: Text('Просмотр'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'edit',
                            child: Text('Редактировать'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'archive',
                            child: Text('Архивировать'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Ошибка: $error')),
      ),
    );
  }
}
