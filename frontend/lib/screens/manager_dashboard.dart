import 'package:fitman_app/models/user_front.dart';
import 'package:fitman_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/screens/manager/trainers_view.dart';

import '../widgets/custom_app_bar.dart';
import 'manager/clients_view.dart';
import 'manager/instructors_view.dart';
import 'manager/schedule_view.dart';

class ManagerDashboard extends ConsumerStatefulWidget {
  final User? manager;
  const ManagerDashboard({super.key, this.manager});

  @override
  ConsumerState<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends ConsumerState<ManagerDashboard> {
  int _selectedIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.manager ?? ref.watch(authProvider).value?.user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    // Инициализация перенесена в build
    final List<Widget> views = [
      ClientsView(managerId: user.id),
      InstructorsView(managerId: user.id),
      TrainersView(managerId: user.id),
      const ScheduleView(),
      const Center(child: Text('Табели - в разработке')),
      const Center(child: Text('Каталоги - в разработке')),
    ];

    return Scaffold(
      appBar: CustomAppBar.manager(
        title: 'Панель менеджера: ${user.firstName}',
        onTabSelected: _onTabSelected,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: views,
      ),
    );
  }
}
