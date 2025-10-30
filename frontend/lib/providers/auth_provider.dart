import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_front.dart';
import '../models/role.dart';
import '../services/api_service.dart';

// 1. Единый класс состояния аутентификации
@immutable
class AuthState {
  final User? user;
  final Role? selectedRole;

  const AuthState({this.user, this.selectedRole});

  AuthState copyWith({User? user, Role? selectedRole}) {
    return AuthState(
      user: user ?? this.user,
      selectedRole: selectedRole ?? this.selectedRole,
    );
  }
}

// 2. Notifier управляет единым состоянием AuthState
class AuthNotifier extends StateNotifier<AsyncValue<AuthState>> {
  AuthNotifier() : super(const AsyncValue.loading()) {
    _loadStoredUser();
  }

  Future<void> _loadStoredUser() async {
    try {
      final token = await _getStoredToken();
      if (token != null) {
        final user = await _getStoredUser();
        if (user != null) {
          Role? selectedRole;
          if (user.roles.length == 1) {
            selectedRole = user.roles.first;
          }
          // При запуске, если ролей много, selectedRole остается null, что вызовет экран выбора
          state = AsyncValue.data(
            AuthState(user: user, selectedRole: selectedRole),
          );
          return;
        }
      }
      state = AsyncValue.data(const AuthState(user: null, selectedRole: null));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> login(String email, String password) async {
    print('[AuthNotifier] Login called for $email');
    state = const AsyncValue.loading();
    try {
      final authResponse = await ApiService.login(email, password);
      await _storeAuthData(authResponse);

      Role? selectedRole;
      if (authResponse.user.roles.length == 1) {
        selectedRole = authResponse.user.roles.first;
      }

      print(
        '[AuthNotifier] Login success. User: ${authResponse.user.email}, Roles: ${authResponse.user.roles.map((r) => r.name)}, SelectedRole: ${selectedRole?.name}',
      );

      // Атомарно обновляем состояние с пользователем и выбранной ролью
      state = AsyncValue.data(
        AuthState(user: authResponse.user, selectedRole: selectedRole),
      );
    } catch (e, st) {
      print('[AuthNotifier] Login error: $e');
      state = AsyncValue.error(e, st);
    }
  }

  void logout() async {
    print('[AuthNotifier] Logout called.');
    print('[AuthNotifier] State before logout: ${state.value}');
    try {
      await ApiService.clearToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');
      state = AsyncValue.data(const AuthState(user: null, selectedRole: null));
      print('[AuthNotifier] Logout successful.');
      print('[AuthNotifier] State after logout: ${state.value}');
    } catch (e, st) {
      print('[AuthNotifier] Logout error: $e');
      state = AsyncValue.error(e, st);
    }
  }

  // Метод для установки роли, выбранной на экране RoleSelectionScreen
  void setSelectedRole(Role role) {
    state = state.whenData((value) => value.copyWith(selectedRole: role));
  }

  // Вспомогательные методы
  Future<String?> _getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<User?> _getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_data');
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<void> _storeAuthData(AuthResponse authResponse) async {
    await ApiService.saveToken(authResponse.token);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(authResponse.user.toJson()));
  }

  Future<void> register(
    String email,
    String password,
    String firstName,
    String lastName,
    List<String> roles,
    String? phone,
    String? gender,
    int? age,
  ) async {
    state = const AsyncValue.loading();
    try {
      final authResponse = await ApiService.register(
        email,
        password,
        firstName,
        lastName,
        roles,
        phone,
        gender,
        age,
      );
      await _storeAuthData(authResponse);

      Role? selectedRole;
      if (authResponse.user.roles.length == 1) {
        selectedRole = authResponse.user.roles.first;
      }

      state = AsyncValue.data(
        AuthState(user: authResponse.user, selectedRole: selectedRole),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// 3. Провайдер теперь предоставляет AsyncValue<AuthState>
final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<AuthState>>(
  (ref) => AuthNotifier(),
);
