import 'package:fitman_app/models/user_front.dart';
import 'package:fitman_app/providers/auth_provider.dart';
import 'package:fitman_app/screens/instructor/clients_view.dart';
import 'package:fitman_app/screens/instructor/my_manager_view.dart';
import 'package:fitman_app/screens/instructor/my_trainer_view.dart';
import 'package:fitman_app/screens/instructor/schedule_view.dart';
import 'package:fitman_app/screens/instructor/timesheet_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/custom_app_bar.dart';

class InstructorDashboard extends ConsumerStatefulWidget {
  final User? instructor;
  const InstructorDashboard({super.key, this.instructor});

  @override
  ConsumerState<InstructorDashboard> createState() => _InstructorDashboardState();
}

class _InstructorDashboardState extends ConsumerState<InstructorDashboard> {
  int _selectedIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.instructor ?? ref.watch(authProvider).value?.user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Инициализация перенесена в build, чтобы избежать проблем с initState
    final List<Widget> views = [
      ClientsView(instructorId: user.id),
      MyTrainerView(instructorId: user.id),
      MyManagerView(instructorId: user.id),
      const ScheduleView(),
      const TimesheetView(),
    ];

    return Scaffold(
      appBar: CustomAppBar.instructor(
        title: 'Панель инструктора: ${user.firstName}',
        onTabSelected: _onTabSelected,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: views,
      ),
    );
  }
}
