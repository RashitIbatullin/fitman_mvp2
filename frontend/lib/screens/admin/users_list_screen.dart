import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_front.dart';
import '../../models/role.dart'; // Import Role model
import '../../services/api_service.dart';
import '../../widgets/custom_app_bar.dart';
import 'create_user_screen.dart';
import 'assign_clients_screen.dart';
import 'assign_instructors_screen.dart';
import 'assign_trainers_screen.dart';
import '../client_dashboard.dart';
import '../instructor_dashboard.dart';
import '../manager_dashboard.dart';
import '../trainer_dashboard.dart';
import '../unknown_role_screen.dart';
import 'manage_user_roles_screen.dart'; // Import the new screen

class UsersListScreen extends ConsumerStatefulWidget {
  final String? initialFilter;
  const UsersListScreen({super.key, this.initialFilter});

  @override
  ConsumerState<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends ConsumerState<UsersListScreen> {
  List<User> _users = [];
  bool _isLoading = true;
  String? _error;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    if (widget.initialFilter != null) {
      _selectedFilter = widget.initialFilter!;
    }
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await ApiService.getUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<User> get _filteredUsers {
    switch (_selectedFilter) {
      case 'admin':
        return _users.where((user) => user.roles.any((role) => role.name == 'admin')).toList();
      case 'manager':
        return _users.where((user) => user.roles.any((role) => role.name == 'manager')).toList();
      case 'trainer':
        return _users.where((user) => user.roles.any((role) => role.name == 'trainer')).toList();
      case 'instructor':
        return _users.where((user) => user.roles.any((role) => role.name == 'instructor')).toList();
      case 'client':
        return _users.where((user) => user.roles.any((role) => role.name == 'client')).toList();
      default:
        return _users;
    }
  }

  String _getRoleDisplayName(Role role) {
    return role.title;
  }

  Color _getRoleColor(String roleName) {
    switch (roleName) {
      case 'admin':
        return Colors.purple;
      case 'manager':
        return Colors.orange;
      case 'trainer':
        return Colors.green;
      case 'instructor':
        return Colors.teal;
      case 'client':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Assuming the current user's role is available via a provider or similar mechanism
    // For demonstration, let's assume the current user is an admin.
    final currentUserIsAdmin = true; // TODO: Replace with actual auth check

    return Column(
        children: [
          // Фильтры
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'all', label: Text('Все')),
                ButtonSegment(value: 'admin', label: Text('Админы')),
                ButtonSegment(value: 'manager', label: Text('Менеджеры')),
                ButtonSegment(value: 'trainer', label: Text('Тренеры')),
                ButtonSegment(value: 'instructor', label: Text('Инструкторы')),
                ButtonSegment(value: 'client', label: Text('Клиенты')),
              ],
              selected: {_selectedFilter},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _selectedFilter = newSelection.first;
                });
              },
            ),
          ),
          
          // Список пользователей
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text('Ошибка: $_error'))
                    : _filteredUsers.isEmpty
                        ? const Center(child: Text('Пользователи не найдены'))
                        : ListView.builder(
                            itemCount: _filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = _filteredUsers[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: _getRoleColor(user.roles.first.name), // Use first role for avatar color
                                    child: Text(
                                      user.firstName[0],
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  title: Text(user.fullName),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(user.email),
                                      if (user.roles.length > 1) // Display roles if more than one
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4.0),
                                          child: Wrap(
                                            spacing: 4.0,
                                            runSpacing: 2.0,
                                            children: user.roles
                                                .map((role) => Chip(
                                                      label: Text(
                                                        _getRoleDisplayName(role),
                                                        style: const TextStyle(fontSize: 10),
                                                      ),
                                                      backgroundColor: _getRoleColor(role.name),
                                                      labelStyle: const TextStyle(color: Colors.white),
                                                    ))
                                                .toList(),
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (user.roles.length == 1) // Display single role chip if only one role
                                        Chip(
                                          label: Text(
                                            _getRoleDisplayName(user.roles.first),
                                            style: const TextStyle(color: Colors.white),
                                          ),
                                          backgroundColor: _getRoleColor(user.roles.first.name),
                                        ),
                                      if (user.roles.any((role) => role.name == 'manager')) ...[
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(Icons.group_add),
                                          tooltip: 'Назначить клиентов',
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => AssignClientsScreen(manager: user),
                                              ),
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.sports_kabaddi),
                                          tooltip: 'Назначить инструкторов',
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => AssignInstructorsScreen(manager: user),
                                              ),
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.fitness_center),
                                          tooltip: 'Назначить тренеров',
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => AssignTrainersScreen(manager: user),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                      if (currentUserIsAdmin && !user.roles.any((role) => role.name == 'client') && !user.roles.any((role) => role.name == 'admin')) // Only show for admin and non-client, non-admin users
                                        IconButton(
                                          icon: const Icon(Icons.manage_accounts),
                                          tooltip: 'Управление ролями',
                                          onPressed: () async {
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ManageUserRolesScreen(user: user),
                                              ),
                                            );
                                            _loadUsers(); // Reload users after returning from role management
                                          },
                                        ),
                                    ],
                                  ),
                                  onTap: () {
                                    Widget page;
                                    // Prioritize roles for navigation
                                    if (user.roles.any((role) => role.name == 'admin')) {
                                      // Admins don't have a specific dashboard to navigate to from here
                                      return;
                                    } else if (user.roles.any((role) => role.name == 'manager')) {
                                      page = ManagerDashboard(manager: user);
                                    } else if (user.roles.any((role) => role.name == 'trainer')) {
                                      page = TrainerDashboard(trainer: user);
                                    } else if (user.roles.any((role) => role.name == 'instructor')) {
                                      page = InstructorDashboard(instructor: user);
                                    } else if (user.roles.any((role) => role.name == 'client')) {
                                      page = ClientDashboard(client: user);
                                    } else {
                                      page = UnknownRoleScreen(); // Fallback for unknown roles
                                    }
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => page),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
          ),
        ],
      );
  }
}