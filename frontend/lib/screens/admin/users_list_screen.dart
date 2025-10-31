import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_front.dart';
import '../../models/role.dart'; // Import Role model
import '../../services/api_service.dart';
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
import '../../widgets/role_dialog_manager.dart';
import '../../widgets/reset_password_dialog.dart';

class UsersListScreen extends ConsumerStatefulWidget {
  final String? initialFilter;
  const UsersListScreen({super.key, this.initialFilter});

  @override
  ConsumerState<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends ConsumerState<UsersListScreen> {
  List<User> _users = [];

  List<User> _filteredUsers = [];

  bool _isLoading = true;

  String? _error;

  String _selectedFilter = 'all';

  User? _selectedUser;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.initialFilter != null) {
      _selectedFilter = widget.initialFilter!;
    }

    _loadUsers();

    _searchController.addListener(_filterUsers);
  }

  void _navigateToDashboard(BuildContext context, User user, String roleName) {
    Widget page;
    switch (roleName) {
      case 'admin':
        return;
      case 'manager':
        page = ManagerDashboard(manager: user);
        break;
      case 'trainer':
        page = TrainerDashboard(trainer: user);
        break;
      case 'instructor':
        page = InstructorDashboard(instructor: user);
        break;
      case 'client':
        page = ClientDashboard(client: user);
        break;
      default:
        page = const UnknownRoleScreen();
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await ApiService.getUsers();

      setState(() {
        _users = users;

        _filterUsers();

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();

        _isLoading = false;
      });
    }
  }

  void _filterUsers() {
    List<User> users;

    switch (_selectedFilter) {
      case 'admin':
        users = _users
            .where((user) => user.roles.any((role) => role.name == 'admin'))
            .toList();

        break;

      case 'manager':
        users = _users
            .where((user) => user.roles.any((role) => role.name == 'manager'))
            .toList();

        break;

      case 'trainer':
        users = _users
            .where((user) => user.roles.any((role) => role.name == 'trainer'))
            .toList();

        break;

      case 'instructor':
        users = _users
            .where(
              (user) => user.roles.any((role) => role.name == 'instructor'),
            )
            .toList();

        break;

      case 'client':
        users = _users
            .where((user) => user.roles.any((role) => role.name == 'client'))
            .toList();

        break;

      default:
        users = _users;
    }

    final searchQuery = _searchController.text.toLowerCase();

    if (searchQuery.isNotEmpty) {
      users = users.where((user) {
        return user.fullName.toLowerCase().contains(searchQuery) ||
            (user.phone?.toLowerCase().contains(searchQuery) ?? false) ||
            user.email.toLowerCase().contains(searchQuery);
      }).toList();
    }

    setState(() {
      _filteredUsers = users;

      _selectedUser = null;
    });
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

  void _navigateToCreateUser(BuildContext context, String role) {
    Navigator.push(
      context,

      MaterialPageRoute(builder: (context) => CreateUserScreen(userRole: role)),
    ).then((created) {
      if (created == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Пользователь успешно создан')),
        );

        _loadUsers();
      }
    });
  }

  void _showCreateUserDialog(BuildContext context) {
    showDialog(
      context: context,

      builder: (context) => AlertDialog(
        title: const Text('Создать пользователя'),

        content: const Text('Выберите роль нового пользователя:'),

        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);

              _navigateToCreateUser(context, 'client');
            },

            child: const Text('Клиент'),
          ),

          TextButton(
            onPressed: () {
              Navigator.pop(context);

              _navigateToCreateUser(context, 'instructor');
            },

            child: const Text('Инструктор'),
          ),

          TextButton(
            onPressed: () {
              Navigator.pop(context);

              _navigateToCreateUser(context, 'trainer');
            },

            child: const Text('Тренер'),
          ),

          TextButton(
            onPressed: () {
              Navigator.pop(context);

              _navigateToCreateUser(context, 'admin');
            },

            child: const Text('Администратор'),
          ),

          TextButton(
            onPressed: () => Navigator.pop(context),

            child: const Text('Отмена'),
          ),
        ],
      ),
    );
  }

  void _showResetPasswordDialog(BuildContext context) {
    if (_selectedUser == null) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ResetPasswordDialog(userLogin: _selectedUser!.email);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserIsAdmin = true; // TODO: Replace with actual auth check

    return Column(
      children: [
        _UsersToolbar(
          searchController: _searchController,

          selectedFilter: _selectedFilter,

          onFilterChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedFilter = value;

                _filterUsers();
              });
            }
          },

          onCreate: () => _showCreateUserDialog(context),

          onEdit: _selectedUser == null
              ? null
              : () {
                  // TODO: Implement Edit User

                  print('Edit user: ${_selectedUser!.fullName}');
                },

          onArchive: _selectedUser == null
              ? null
              : () {
                  // TODO: Implement Archive User

                  print('Archive user: ${_selectedUser!.fullName}');
                },

          onResetPassword: _selectedUser == null
              ? null
              : () => _showResetPasswordDialog(context),
        ),

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

                    final isSelected = _selectedUser?.id == user.id;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),

                      color: isSelected
                          ? Theme.of(context).primaryColor.withOpacity(0.1)
                          : null,

                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: user.roles.isNotEmpty
                              ? _getRoleColor(user.roles.first.name)
                              : Colors.grey,
                          child: Text(
                            user.firstName.isNotEmpty ? user.firstName[0] : '?',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),

                        title: Text(user.fullName),

                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IntrinsicHeight(
                              child: Row(
                                children: [
                                  Text(user.email),
                                  const VerticalDivider(
                                    width: 10,
                                    thickness: 1,
                                    color: Colors.grey,
                                  ),
                                  Text(user.phone ?? 'Нет телефона'),
                                  if (user.roles.any(
                                    (role) => role.name == 'client',
                                  )) ...[
                                    const VerticalDivider(
                                      width: 10,
                                      thickness: 1,
                                      color: Colors.grey,
                                    ),
                                    Text('Пол: ${user.gender ?? 'Н/Д'}'),
                                    const VerticalDivider(
                                      width: 10,
                                      thickness: 1,
                                      color: Colors.grey,
                                    ),
                                    Text(
                                      'Возраст: ${user.age?.toString() ?? 'Н/Д'}',
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (user.roles.length > 1)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Wrap(
                                  spacing: 4.0,
                                  runSpacing: 2.0,
                                  children: user.roles
                                      .map(
                                        (role) => Chip(
                                          label: Text(
                                            _getRoleDisplayName(role),
                                            style: const TextStyle(
                                              fontSize: 10,
                                            ),
                                          ),
                                          backgroundColor: _getRoleColor(
                                            role.name,
                                          ),
                                          labelStyle: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                          ],
                        ),

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,

                          children: [
                            if (user.roles.length == 1)
                              Chip(
                                label: Text(
                                  _getRoleDisplayName(user.roles.first),
                                  style: const TextStyle(color: Colors.white),
                                ),
                                backgroundColor: user.roles.isNotEmpty
                                    ? _getRoleColor(user.roles.first.name)
                                    : Colors.grey,
                              ),

                            if (user.roles.any(
                              (role) => role.name == 'manager',
                            )) ...[
                              const SizedBox(width: 8),

                              IconButton(
                                icon: const Icon(Icons.group_add),

                                tooltip: 'Назначить клиентов',

                                onPressed: () {
                                  Navigator.push(
                                    context,

                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AssignClientsScreen(manager: user),
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
                                      builder: (context) =>
                                          AssignInstructorsScreen(
                                            manager: user,
                                          ),
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
                                      builder: (context) =>
                                          AssignTrainersScreen(manager: user),
                                    ),
                                  );
                                },
                              ),
                            ],

                            if (currentUserIsAdmin &&
                                !user.roles.any(
                                  (role) => role.name == 'client',
                                ))
                              IconButton(
                                icon: const Icon(Icons.manage_accounts),

                                tooltip: 'Управление ролями',

                                onPressed: () async {
                                  await Navigator.push(
                                    context,

                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ManageUserRolesScreen(user: user),
                                    ),
                                  );

                                  _loadUsers();
                                },
                              ),
                          ],
                        ),

                        onTap: () async {
                          if (user.roles.length > 1) {
                            final selectedRole = await RoleDialogManager.show(
                              context,
                              user.roles,
                            );
                            if (selectedRole != null) {
                              _navigateToDashboard(
                                context,
                                user,
                                selectedRole.name,
                              );
                            }
                          } else if (user.roles.isNotEmpty) {
                            _navigateToDashboard(
                              context,
                              user,
                              user.roles.first.name,
                            );
                          } else {
                            _navigateToDashboard(context, user, '');
                          }
                        },

                        onLongPress: () {
                          setState(() {
                            if (isSelected) {
                              _selectedUser = null;
                            } else {
                              _selectedUser = user;
                            }
                          });
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

class _UsersToolbar extends StatelessWidget {
  final TextEditingController searchController;

  final String selectedFilter;

  final ValueChanged<String?> onFilterChanged;

  final VoidCallback onCreate;

  final VoidCallback? onEdit;

  final VoidCallback? onArchive;

  final VoidCallback? onResetPassword;

  const _UsersToolbar({
    required this.searchController,

    required this.selectedFilter,

    required this.onFilterChanged,

    required this.onCreate,

    this.onEdit,

    this.onArchive,

    this.onResetPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),

      child: Column(
        children: [
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: onCreate,

                icon: const Icon(Icons.add),

                label: const Text('Создать'),
              ),

              const SizedBox(width: 8),

              ElevatedButton.icon(
                onPressed: onEdit,

                icon: const Icon(Icons.edit),

                label: const Text('Изменить'),
              ),

              const SizedBox(width: 8),

              ElevatedButton.icon(
                onPressed: onArchive,

                icon: const Icon(Icons.archive),

                label: const Text('Архивировать'),
              ),

              const SizedBox(width: 8),

              ElevatedButton.icon(
                onPressed: onResetPassword,

                icon: const Icon(Icons.password),

                label: const Text('Сброс пароля'),
              ),

              const Spacer(),

              SizedBox(
                width: 250,

                child: TextField(
                  controller: searchController,

                  decoration: InputDecoration(
                    hintText: 'Поиск по ФИО/телефону/почте',

                    prefixIcon: const Icon(Icons.search),

                    border: const OutlineInputBorder(),

                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),

                      onPressed: () => searchController.clear(),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'all', label: Text('Все')),

              ButtonSegment(value: 'admin', label: Text('Администраторы')),

              ButtonSegment(value: 'manager', label: Text('Менеджеры')),

              ButtonSegment(value: 'trainer', label: Text('Тренеры')),

              ButtonSegment(value: 'instructor', label: Text('Инструкторы')),

              ButtonSegment(value: 'client', label: Text('Клиенты')),
            ],

            selected: {selectedFilter},

            onSelectionChanged: (newSelection) =>
                onFilterChanged(newSelection.first),
          ),
        ],
      ),
    );
  }
}
