import 'package:fitman_app/screens/shared/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'admin/users_list_screen.dart';
import 'admin/catalogs_screen.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  final bool showBackButton;
  const AdminDashboard({super.key, required this.showBackButton});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  int _selectedIndex = 0;

  final List<String> _titles = const [
    'Главное',
    'Профиль',
    'Пользователи',
    'Настройки',
    'Аналитика',
    'Каталоги',
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value?.user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final List<Widget> views = [
      const Center(child: Text('Главное')),
      ProfileScreen(user: user),
      const UsersListScreen(),
      const Center(child: Text('Настройки - в разработке')),
      const Center(child: Text('Аналитика - в разработке')),
      const CatalogsScreen(),
    ];

    void onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    return Scaffold(
      appBar: AppBar(
        leading: widget.showBackButton ? const BackButton() : Container(),
        title: Text(_titles[_selectedIndex]),
        actions: [
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
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Пользователи',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Настройки',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Аналитика',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_open),
            label: 'Каталоги',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        onTap: onItemTapped,
      ),
    );
  }
}
