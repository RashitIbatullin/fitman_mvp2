import 'package:fitman_app/modules/infrastructure/providers/equipment_provider.dart';
import 'package:fitman_app/modules/infrastructure/providers/room_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InfrastructureDashboardScreen extends ConsumerWidget {
  const InfrastructureDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(allRoomsProvider);
    final equipmentItemsAsync = ref.watch(allEquipmentItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Infrastructure Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            roomsAsync.when(
              data: (rooms) => Text('Total rooms: ${rooms.length}'),
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
