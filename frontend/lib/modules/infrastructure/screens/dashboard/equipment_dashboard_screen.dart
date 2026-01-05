import 'package:flutter/material.dart';
import '../equipment/item/equipment_items_list_screen.dart';

class EquipmentDashboardScreen extends StatelessWidget {
  const EquipmentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Управление оборудованием'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            elevation: 2.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Действия с оборудованием',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12.0),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.add_box),
                        label: const Text('Добавить оборудование'),
                        onPressed: () {
                          // TODO: Navigate to Add Equipment Screen
                        },
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.fitness_center),
                        label: const Text('Просмотр оборудования'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const EquipmentItemsListViewScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}