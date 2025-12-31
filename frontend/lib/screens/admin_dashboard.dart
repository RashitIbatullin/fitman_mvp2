import 'package:fitman_app/screens/shared/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'admin/users_list_screen.dart';
import 'admin/catalogs_screen.dart';
import 'admin/groups/training_groups_screen.dart'; // New import for training groups
import 'admin/groups/analytic_groups_screen.dart'; // New import for analytic groups
import '../providers/groups/training_groups_provider.dart'; // New import
import '../providers/groups/analytic_groups_provider.dart'; // New import
import 'admin/groups/training_group_edit_screen.dart'; // New import
import 'admin/groups/analytic_group_edit_screen.dart'; // New import

class AdminDashboard extends ConsumerStatefulWidget {
  final bool showBackButton;
  const AdminDashboard({super.key, required this.showBackButton});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  int _selectedIndex = 0;
  late ScrollController _scrollController;
  bool _showBars = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // Only react to scroll changes if the Users tab is selected (now index 2)
    if (_selectedIndex != 2) return;

    final userScrollDirection = _scrollController.position.userScrollDirection;

    if (userScrollDirection == ScrollDirection.reverse) { // Scrolling down
      if (_showBars) {
        setState(() {
          _showBars = false;
        });
      }
    } else if (userScrollDirection == ScrollDirection.forward) { // Scrolling up
      if (!_showBars) {
        setState(() {
          _showBars = true;
        });
      }
    }
  }

  final List<String> _titles = const [
    'Главное',
    'Профиль',
    'Пользователи',
    'Тренировочные группы', // Updated menu item
    'Аналитические группы', // New menu item
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
      UsersListScreen(scrollController: _scrollController, showToolbar: _showBars),
      const TrainingGroupsScreen(), // New training groups screen
      const AnalyticGroupsScreen(), // New analytic groups screen
      const Center(child: Text('Настройки - в разработке')),
      const Center(child: Text('Аналитика - в разработке')),
      const CatalogsScreen(),
    ];

    void onItemTapped(int index) {
      // When switching tabs, always show the bars.
      if (index != _selectedIndex && !_showBars) {
        setState(() {
          _showBars = true;
        });
      }
      setState(() {
        _selectedIndex = index;
      });
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(_showBars ? kToolbarHeight : 0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: _showBars ? kToolbarHeight : 0,
          child: AppBar(
            leading: widget.showBackButton ? const BackButton() : Container(),
            title: Text(_titles[_selectedIndex]),
            actions: [
              if (user.roles.any((element) => element.name == 'admin') && (_selectedIndex == 3 || _selectedIndex == 4)) // Only show for Groups screen (index 3 or 4)
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Обновить',
                  onPressed: () {
                    if (_selectedIndex == 3) {
                      ref.invalidate(trainingGroupsProvider);
                    } else if (_selectedIndex == 4) {
                      ref.invalidate(analyticGroupsProvider);
                    }
                  },
                ),
              if (user.roles.any((element) => element.name == 'admin') && (_selectedIndex == 3))
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Создать тренировочную группу',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const TrainingGroupEditScreen()),
                    );
                  },
                ),
              if (user.roles.any((element) => element.name == 'admin') && (_selectedIndex == 4))
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Создать аналитическую группу',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const AnalyticGroupEditScreen()),
                    );
                  },
                ),
              if (!widget.showBackButton)
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
              if (widget.showBackButton)
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                  ),
                ),
            ],
          ),
        ),
      ),
      body: IndexedStack(index: _selectedIndex, children: views),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: _showBars ? kBottomNavigationBarHeight : 0,
        child: Wrap(
          children: [
            BottomNavigationBar(
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
                BottomNavigationBarItem( // New BottomNavigationBarItem for Training Groups
                  icon: Icon(Icons.group),
                  label: 'Тренировки',
                ),
                BottomNavigationBarItem( // New BottomNavigationBarItem for Analytic Groups
                  icon: Icon(Icons.analytics),
                  label: 'Аналитика',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Настройки',
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
              type: BottomNavigationBarType.fixed, // To show all items
            ),
          ],
        ),
      ),
    );
  }
}