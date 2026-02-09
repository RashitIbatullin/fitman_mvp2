import 'package:fitman_app/modules/supportStaff/providers/support_staff_provider.dart';
import 'package:fitman_app/modules/supportStaff/screens/support_staff_detail_screen.dart';
import 'package:fitman_app/modules/supportStaff/screens/support_staff_edit_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SupportStaffListScreen extends ConsumerWidget {
  const SupportStaffListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffListAsync = ref.watch(allSupportStaffProvider());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Вспомогательный персонал'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SupportStaffEditScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: staffListAsync.when(
        data: (staffList) {
          if (staffList.isEmpty) {
            return const Center(child: Text('Нет данных'));
          }
          return ListView.builder(
            itemCount: staffList.length,
            itemBuilder: (context, index) {
              final staff = staffList[index];
              return ListTile(
                title: Text('${staff.lastName} ${staff.firstName}'),
                subtitle: Text(staff.category.toString()),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SupportStaffDetailScreen(staffId: staff.id),
                    ),
                  );
                },
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
