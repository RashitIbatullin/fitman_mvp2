

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/auth_provider.dart';
import 'screens/admin_dashboard.dart';
import 'screens/client_dashboard.dart';
import 'screens/instructor_dashboard.dart';
import 'screens/login_screen.dart';
import 'screens/manager_dashboard.dart';
import 'screens/trainer_dashboard.dart';
import 'screens/unknown_role_screen.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация форматирования дат
  await initializeDateFormatting('ru', null);

  // Очищаем сохраненную аутентификацию при каждом запуске (для разработки)
//  WidgetsFlutterBinding.ensureInitialized();
//  final prefs = await SharedPreferences.getInstance();
//  await prefs.clear();

  // Инициализация API service
  await ApiService.init();
  print('ApiService._token after init: ${ApiService.currentToken}'); // Debug print

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget  {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { // Добавляем WidgetRef ref
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Fitman MVP2',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: authState.when(
        data: (user) {
          if (user == null) {
            return const LoginScreen();
          }
          // Автоматическая навигация по ролям
          if (user.roles.any((role) => role.name == 'admin')) {
            return const AdminDashboard();
          } else if (user.roles.any((role) => role.name == 'manager')) {
            return const ManagerDashboard();
          } else if (user.roles.any((role) => role.name == 'trainer')) {
            return const TrainerDashboard();
          } else if (user.roles.any((role) => role.name == 'instructor')) {
            return const InstructorDashboard();
          } else if (user.roles.any((role) => role.name == 'client')) {
            return const ClientDashboard();
          } else {
            return const UnknownRoleScreen();
          }
        },
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => const LoginScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    await Future.delayed(const Duration(seconds: 2)); // Имитация загрузки

    if (mounted) {
      if (token != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ClientDashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.fitness_center,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              'Фитнес-менеджер',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}