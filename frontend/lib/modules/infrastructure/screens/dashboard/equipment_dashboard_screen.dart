import 'package:fitman_app/modules/infrastructure/providers/equipment_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EquipmentDashboardScreen extends ConsumerWidget {
  const EquipmentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equipmentItemsAsync = ref.watch(allEquipmentItemsProvider);
    final equipmentTypesAsync = ref.watch(allEquipmentTypesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipment Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            equipmentTypesAsync.when(
              data: (types) => Text('Total equipment types: ${types.length}'),
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => Text('Error: $err'),
            ),
            equipmentItemsAsync.when(
              data: (items) => Text('Total equipment items: ${items.length}'),
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => Text('Error: $err'),
            ),
          ],
        ),
      ),
    );
  }
}
