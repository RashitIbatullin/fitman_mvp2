import 'package:fitman_app/models/user_front.dart';
import 'package:fitman_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/screens/manager/trainers_view.dart';
import 'package:fitman_app/screens/shared/profile_screen.dart';

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

  final List<String> _titles = const [
    'Главное',
    'Профиль',
    'Клиенты',
    'Инструкторы',
    'Тренеры',
    'Расписание',
    'Табели',
    'Каталоги',
  ];

  void _onItemTapped(int index) {
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

    final List<Widget> views = [
      const Center(child: Text('Главное')),
      ProfileScreen(user: user),
      ClientsView(managerId: user.id),
      InstructorsView(managerId: user.id),
      TrainersView(managerId: user.id),
      const ScheduleView(),
      const Center(child: Text('Табели - в разработке')),
      const Center(child: Text('Каталоги - в разработке')),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          if (widget.manager == null)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Выйти',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Подтверждение выхода'),
                      content: const Text('Вы уверены, что хотите выйти?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Нет'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Да'),
                        ),
                      ],
                    );
                  },
                ).then((value) {
                  if (value == true) {
                    ref.read(authProvider.notifier).logout();
                  }
                });
              },
            ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: views),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главное'),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Профиль',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Клиенты'),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports),
            label: 'Инструкторы',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Тренеры',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Расписание',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'Табели',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_open),
            label: 'Каталоги',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
