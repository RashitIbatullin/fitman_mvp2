// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/user_front.dart';
import '../../models/role.dart';
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
import 'edit_user_screen.dart';
import 'manage_user_roles_screen.dart';
import '../../widgets/role_dialog_manager.dart';
import '../../widgets/reset_password_dialog.dart';

// 1. Create a FutureProvider to fetch users.
final usersProvider = FutureProvider<List<User>>((ref) async {
  return ApiService.getUsers();
});

final newlyCreatedUserProvider = StateProvider<User?>((ref) => null);

class UsersListScreen extends ConsumerStatefulWidget {
  final String? initialFilter;
  final ScrollController scrollController;
  final bool showToolbar;

  const UsersListScreen({
    super.key,
    this.initialFilter,
    required this.scrollController,
    required this.showToolbar,
  });

  @override
  ConsumerState<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends ConsumerState<UsersListScreen> {
  String _selectedFilter = 'all';
  User? _selectedUser;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialFilter != null) {
      _selectedFilter = widget.initialFilter!;
    }
    _searchController.addListener(() {
      // Trigger a rebuild to apply search filter
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<User> _filterUsers(List<User> allUsers) {
    List<User> users;
    switch (_selectedFilter) {
      case 'admin':
        users = allUsers.where((user) => user.roles.any((role) => role.name == 'admin')).toList();
        break;
      case 'manager':
        users = allUsers.where((user) => user.roles.any((role) => role.name == 'manager')).toList();
        break;
      case 'trainer':
        users = allUsers.where((user) => user.roles.any((role) => role.name == 'trainer')).toList();
        break;
      case 'instructor':
        users = allUsers.where((user) => user.roles.any((role) => role.name == 'instructor')).toList();
        break;
      case 'client':
        users = allUsers.where((user) => user.roles.any((role) => role.name == 'client')).toList();
        break;
      default:
        users = allUsers;
    }

    final searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isNotEmpty) {
      users = users.where((user) {
        return user.fullName.toLowerCase().contains(searchQuery) ||
            (user.phone?.toLowerCase().contains(searchQuery) ?? false) ||
            user.email.toLowerCase().contains(searchQuery);
      }).toList();
    }
    
    // This is a workaround to deselect user if they are filtered out.
    if (_selectedUser != null && !users.any((u) => u.id == _selectedUser!.id)) {
      Future.microtask(() => setState(() => _selectedUser = null));
    }

    return users;
  }
  
  Future<void> _navigateToDashboard(BuildContext context, User user, String roleName) async {
    Widget page;
    switch (roleName) {
      case 'admin':
        return;
      case 'manager':
        page = ManagerDashboard(manager: user, showBackButton: true);
        break;
      case 'trainer':
        page = TrainerDashboard(trainer: user, showBackButton: true);
        break;
      case 'instructor':
        page = InstructorDashboard(instructor: user, showBackButton: true);
        break;
      case 'client':
        page = ClientDashboard(client: user, showBackButton: true);
        break;
      default:
        page = const UnknownRoleScreen();
    }
    await Navigator.push(context, MaterialPageRoute(builder: (context) => page));
    // Invalidate provider on return to refresh data
    ref.invalidate(usersProvider);
  }

  String _getRoleDisplayName(Role role) {
    return role.title;
  }

  Color _getRoleColor(String roleName) {
    switch (roleName) {
      case 'admin': return Colors.purple;
      case 'manager': return Colors.orange;
      case 'trainer': return Colors.green;
      case 'instructor': return Colors.teal;
      case 'client': return Colors.blue;
      default: return Colors.grey;
    }
  }

  void _navigateToCreateUser(BuildContext context, String role) async {
    final newUser = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateUserScreen(userRole: role)),
    );

    if (newUser != null && newUser is User) {
      ref.invalidate(usersProvider); // Invalidate and refetch
      ref.read(newlyCreatedUserProvider.notifier).state = newUser;
    }
  }

  void _showCreateUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Создать пользователя'),
        content: const Text('Выберите роль нового пользователя:'),
        actions: [
          TextButton(onPressed: () { Navigator.pop(context); _navigateToCreateUser(context, 'client'); }, child: const Text('Клиент')),
          TextButton(onPressed: () { Navigator.pop(context); _navigateToCreateUser(context, 'instructor'); }, child: const Text('Инструктор')),
          TextButton(onPressed: () { Navigator.pop(context); _navigateToCreateUser(context, 'trainer'); }, child: const Text('Тренер')),
          TextButton(onPressed: () { Navigator.pop(context); _navigateToCreateUser(context, 'admin'); }, child: const Text('Администратор')),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
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
    ref.listen<User?>(newlyCreatedUserProvider, (previous, next) {
      if (next != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final roleName = next.roles.first.name;
          Widget? page;
          switch (roleName) {
            case 'client':
              page = ClientDashboard(client: next, showBackButton: true);
              break;
            case 'manager':
              page = ManagerDashboard(manager: next, showBackButton: true);
              break;
            case 'trainer':
              page = TrainerDashboard(trainer: next, showBackButton: true);
              break;
            case 'instructor':
              page = InstructorDashboard(instructor: next, showBackButton: true);
              break;
            case 'admin':
              // Admins likely stay on the users list, so no navigation.
              break;
          }

          if (page != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page!),
            ).then((_) {
              // Reset the provider after navigation
              ref.read(newlyCreatedUserProvider.notifier).state = null;
            });
          } else {
            // Reset the provider even if there's no navigation
            ref.read(newlyCreatedUserProvider.notifier).state = null;
          }
        });
      }
    });

    final usersAsyncValue = ref.watch(usersProvider);
    final currentUserIsAdmin = true; // TODO: Replace with actual auth check

    return Column(
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: widget.showToolbar ? 1.0 : 0.0,
            child: SizedBox( // Use SizedBox to control height when hidden
              height: widget.showToolbar ? null : 0.0,
              child: _UsersToolbar(
                searchController: _searchController,
                selectedFilter: _selectedFilter,
                onFilterChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedFilter = value;
                      _selectedUser = null;
                    });
                  }
                },
                onCreate: () => _showCreateUserDialog(context),
                onEdit: _selectedUser == null
                    ? null
                    : () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditUserScreen(user: _selectedUser!),
                          ),
                        );
                        // No need to handle result, invalidation will be done in EditUserScreen
                      },
                onArchive: _selectedUser == null ? null : () => print('Archive user: ${_selectedUser!.fullName}'),
                onResetPassword: _selectedUser == null ? null : () => _showResetPasswordDialog(context),
              ),
            ),
          ),
        ),
        Expanded(
          child: usersAsyncValue.when(
            data: (allUsers) {
              final filteredUsers = _filterUsers(allUsers);
              if (filteredUsers.isEmpty) {
                return const Center(child: Text('Пользователи не найдены'));
              }
              return ListView.builder(
                controller: widget.scrollController, // Attach controller here
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  final isSelected = _selectedUser?.id == user.id;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
                    color: isSelected ? Theme.of(context).primaryColor.withAlpha(25) : null,
                    child: ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundImage: user.photoUrl != null
                            ? NetworkImage(Uri.parse(ApiService.baseUrl).replace(path: user.photoUrl!).toString())
                            : null,
                        child: user.photoUrl == null ? Text(user.firstName.isNotEmpty ? user.firstName[0] : '?') : null,
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.fullName),
                          if (user.roles.isNotEmpty)
                            Wrap(
                              spacing: 4.0,
                              runSpacing: 2.0,
                              children: user.roles.map((role) => Chip(
                                      label: Text(_getRoleDisplayName(role), style: const TextStyle(fontSize: 10,),),
                                      backgroundColor: _getRoleColor(role.name,),
                                      labelStyle: const TextStyle(color: Colors.white,),
                                    ),
                                  )
                                  .toList(),
                            ),
                        ],
                      ),
                      subtitle: Wrap(
                          spacing: 8.0, // horizontal space between chips
                          runSpacing: 4.0, // vertical space between lines
                          children: [
                            Text(user.email),
                            const Text('•'),
                            Text(user.phone ?? 'Нет телефона'),
                            if (user.roles.any((role) => role.name == 'client',)) ...[
                              const Text('•'),
                              Text('Пол: ${user.gender ?? 'Н/Д'}'),
                              const Text('•'),
                              Text('ДР: ${user.dateOfBirth != null ? '${user.dateOfBirth!.day}.${user.dateOfBirth!.month}.${user.dateOfBirth!.year}' : 'Н/Д'}',),
                              const Text('•'),
                              Text('Возраст: ${user.age?.toString() ?? 'Н/Д'}',),
                            ],
                          ],
                        ),
                      trailing: user.roles.any((r) => r.name == 'manager') || (currentUserIsAdmin && !user.roles.any((r) => r.name == 'client'))
                          ? PopupMenuButton<String>(
                              onSelected: (value) async {
                                switch (value) {
                                  case 'assign_clients':
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => AssignClientsScreen(manager: user),),);
                                    break;
                                  case 'assign_instructors':
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => AssignInstructorsScreen(manager: user,),),);
                                    break;
                                  case 'assign_trainers':
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => AssignTrainersScreen(manager: user,),),);
                                    break;
                                  case 'manage_roles':
                                    await Navigator.push(context, MaterialPageRoute(builder: (context) => ManageUserRolesScreen(user: user),),);
                                    ref.invalidate(usersProvider);
                                    break;
                                }
                              },
                              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                if (user.roles.any((role) => role.name == 'manager',))
                                  const PopupMenuItem<String>(
                                    value: 'assign_clients',
                                    child: ListTile(leading: Icon(Icons.group_add), title: Text('Назначить клиентов')),
                                  ),
                                if (user.roles.any((role) => role.name == 'manager',))
                                  const PopupMenuItem<String>(
                                    value: 'assign_instructors',
                                    child: ListTile(leading: Icon(Icons.sports_kabaddi), title: Text('Назна-чить инструкторов')),
                                  ),
                                if (user.roles.any((role) => role.name == 'manager',))
                                  const PopupMenuItem<String>(
                                    value: 'assign_trainers',
                                    child: ListTile(leading: Icon(Icons.fitness_center), title: Text('Назначить тренеров')),
                                  ),
                                if (currentUserIsAdmin && !user.roles.any((role) => role.name == 'client',))
                                  const PopupMenuItem<String>(
                                    value: 'manage_roles',
                                    child: ListTile(leading: Icon(Icons.manage_accounts), title: Text('Управление ролями')),
                                  ),
                              ],
                            )
                          : null,
                      onTap: () async {
                        final context_ = context;
                        if (user.roles.length > 1) {
                          final selectedRole = await RoleDialogManager.show(context_, user.roles,);
                          if (selectedRole != null) {
                            await _navigateToDashboard(context_, user, selectedRole.name,);
                          }
                        } else if (user.roles.isNotEmpty) {
                          await _navigateToDashboard(context_, user, user.roles.first.name,);
                        } else {
                          await _navigateToDashboard(context_, user, '');
                        }
                      },
                      onLongPress: () {
                        setState(() {
                          _selectedUser = isSelected ? null : user;
                        });
                      },
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Ошибка: $error')),
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
              ElevatedButton.icon(onPressed: onCreate, icon: const Icon(Icons.add), label: const Text('Создать'),),
              const SizedBox(width: 8),
              ElevatedButton.icon(onPressed: onEdit, icon: const Icon(Icons.edit), label: const Text('Изменить'),),
              const SizedBox(width: 8),
              ElevatedButton.icon(onPressed: onArchive, icon: const Icon(Icons.archive), label: const Text('Архивировать'),),
              const SizedBox(width: 8),
              ElevatedButton.icon(onPressed: onResetPassword, icon: const Icon(Icons.password), label: const Text('Сброс пароля'),),
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'all', label: Text('Все')),
              ButtonSegment(value: 'admin', label: Text('Админ-ры')),
              ButtonSegment(value: 'manager', label: Text('Менеджеры')),
              ButtonSegment(value: 'trainer', label: Text('Тренеры')),
              ButtonSegment(value: 'instructor', label: Text('Инстр-ры')),
              ButtonSegment(value: 'client', label: Text('Клиенты')),
            ],
            selected: {selectedFilter},
            onSelectionChanged: (newSelection) =>
                onFilterChanged(newSelection.first),
          ),
        ),
        ],
      ),
    );
  }
}