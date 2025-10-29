import 'package:fitman_app/screens/admin_dashboard.dart';
import 'package:fitman_app/screens/client_dashboard.dart';
import 'package:fitman_app/screens/instructor_dashboard.dart';
import 'package:fitman_app/screens/login_screen.dart';
import 'package:fitman_app/screens/manager_dashboard.dart';
import 'package:fitman_app/screens/role_selection_screen.dart';
import 'package:fitman_app/screens/trainer_dashboard.dart';
import 'package:fitman_app/screens/unknown_role_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../models/role.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStateAsync = ref.watch(authProvider);
    print('[AuthWrapper] Building with authState: ${authStateAsync.value?.user?.email}, selectedRole: ${authStateAsync.value?.selectedRole?.name}');

    return authStateAsync.when(
      data: (authState) {
        final user = authState.user;
        final selectedRole = authState.selectedRole;

        if (user == null) {
          return const LoginScreen();
        }

        // Если у пользователя несколько ролей, но ни одна не выбрана -> экран выбора
        if (user.roles.length > 1 && selectedRole == null) {
          return RoleSelectionScreen(user: user);
        }
        
        // Если роль выбрана (или она всего одна), показываем соответствующий дашборд
        return _getDashboard(selectedRole);
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        body: Center(
          child: Text('Ошибка аутентификации: $err'),
        ),
      ),
    );
  }

  Widget _getDashboard(Role? role) {
    if (role == null) {
      // Такое может случиться на мгновение или если у пользователя нет ролей
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    switch (role.name) {
      case 'admin':
        return const AdminDashboard();
      case 'manager':
        return const ManagerDashboard();
      case 'trainer':
        return const TrainerDashboard();
      case 'instructor':
        return const InstructorDashboard();
      case 'client':
        return const ClientDashboard();
      default:
        return const UnknownRoleScreen();
    }
  }
}
