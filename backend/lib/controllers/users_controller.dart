import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:bcrypt/bcrypt.dart';
import '../config/database.dart';
import '../models/user_back.dart';

class UsersController {
  // ... (other methods remain the same)

  // Создать нового пользователя (только для админа)
  static Future<Response> createUser(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final roles = List<String>.from(data['roles'] as List<dynamic>);

      // --- НАЧАЛО ВАЛИДАЦИИ РОЛЕЙ ---
      if (roles.contains('client') && roles.length > 1) {
        return Response(400, body: jsonEncode({'error': 'Пользователь с ролью "Клиент" не может иметь другие роли.'}));
      }
      if (roles.any((r) => r != 'client') && roles.contains('client')) {
         return Response(400, body: jsonEncode({'error': 'Роль "Клиент" не может быть совмещена с другими ролями.'}));
      }
      // --- КОНЕЦ ВАЛИДАЦИИ РОЛЕЙ ---

      final email = data['email'] as String;
      final password = data['password'] as String;
      final firstName = data['firstName'] as String;
      final lastName = data['lastName'] as String;
      final phone = data['phone'] as String?;

      final existingUser = await Database().getUserByEmail(email);
      if (existingUser != null) {
        return Response(400, body: jsonEncode({'error': 'Пользователь с таким email уже существует'}));
      }

      final passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());

      final newUser = User(
        id: 0,
        email: email,
        passwordHash: passwordHash,
        firstName: firstName,
        lastName: lastName,
        roles: [], // Будет заполнено в методе БД
        phone: phone,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final createdUser = await Database().createUser(newUser, roles);

      return Response(201, body: jsonEncode({
        'message': 'Пользователь успешно создан',
        'user': createdUser.toSafeJson()
      }));
    } catch (e) {
      print('Create user error: $e');
      return Response(500, body: jsonEncode({'error': 'Внутренняя ошибка сервера: $e'}));
    }
  }

  // Обновить роли пользователя (только для админа)
  static Future<Response> updateUserRoles(Request request, String id) async {
    try {
      final userId = int.tryParse(id);
      if (userId == null) {
        return Response(400, body: jsonEncode({'error': 'Неверный ID пользователя'}));
      }

      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final newRoleNames = List<String>.from(data['roles'] as List<dynamic>);

      final user = await Database().getUserById(userId);
      if (user == null) {
        return Response(404, body: jsonEncode({'error': 'Пользователь не найден'}));
      }

      // --- НАЧАЛО ВАЛИДАЦИИ РОЛЕЙ ---
      if (newRoleNames.contains('client') && newRoleNames.length > 1) {
        return Response(400, body: jsonEncode({'error': 'Пользователь с ролью "Клиент" не может иметь другие роли.'}));
      }
      final hasClientRole = user.roles.any((r) => r.name == 'client');
      if (hasClientRole && newRoleNames.any((name) => name != 'client')) {
        return Response(400, body: jsonEncode({'error': 'Роль "Клиент" не может быть совмещена с другими ролями.'}));
      }
      if (newRoleNames.contains('client') && user.roles.any((r) => r.name != 'client')) {
        return Response(400, body: jsonEncode({'error': 'Нельзя добавить роль "Клиент" к существующим ролям сотрудников.'}));
      }

      // Нельзя удалить основную (единственную) роль
      if (user.roles.length == 1 && !newRoleNames.contains(user.roles.first.name)) {
        return Response(400, body: jsonEncode({'error': 'Нельзя удалить основную (единственную) роль пользователя.'}));
      }
      if (newRoleNames.isEmpty) {
        return Response(400, body: jsonEncode({'error': 'У пользователя должна быть хотя бы одна роль.'}));
      }
      // --- КОНЕЦ ВАЛИДАЦИИ РОЛЕЙ ---

      // Преобразуем имена ролей в ID
      final allRoles = await Database().getAllRoles();
      final newRoleIds = newRoleNames.map((name) {
        return allRoles.firstWhere((role) => role.name == name).id;
      }).toList();

      await Database().updateUserRoles(userId, newRoleIds);

      final updatedUser = await Database().getUserById(userId);

      return Response.ok(jsonEncode({
        'message': 'Роли пользователя успешно обновлены',
        'user': updatedUser?.toSafeJson()
      }));
    } catch (e) {
      print('Update user roles error: $e');
      return Response(500, body: jsonEncode({'error': 'Внутренняя ошибка сервера: $e'}));
    }
  }

  // ... (other methods can be added here, keeping the rest of the class structure)

  // The following are the existing methods from the original file to be preserved.
  static Future<Response> getUsers(Request request) async {
    try {
      final users = await Database().getAllUsers();
      final usersJson = users.map((user) => user.toSafeJson()).toList();
      return Response.ok(jsonEncode({'users': usersJson}));
    } catch (e) {
      print('Get users error: $e');
      return Response(500, body: jsonEncode({'error': 'Internal server error'}));
    }
  }

  static Future<Response> getUserById(Request request, String id) async {
    try {
      final userId = int.tryParse(id);
      if (userId == null) {
        return Response(400, body: jsonEncode({'error': 'Invalid user ID'}));
      }
      final user = await Database().getUserById(userId);
      if (user == null) {
        return Response(404, body: jsonEncode({'error': 'User not found'}));
      }
      return Response.ok(jsonEncode({'user': user.toSafeJson()}));
    } catch (e) {
      print('Get user by ID error: $e');
      return Response(500, body: jsonEncode({'error': 'Internal server error'}));
    }
  }

  static Future<Response> updateUser(Request request, String id) async {
    try {
      final userId = int.tryParse(id);
      if (userId == null) {
        return Response(400, body: jsonEncode({'error': 'Invalid user ID'}));
      }
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final updatedUser = await Database().updateUser(
        userId,
        firstName: data['firstName'] as String?,
        lastName: data['lastName'] as String?,
        phone: data['phone'] as String?,
      );
      if (updatedUser == null) {
        return Response(404, body: jsonEncode({'error': 'User not found'}));
      }
      return Response.ok(jsonEncode({'user': updatedUser.toSafeJson()}));
    } catch (e) {
      print('Update user error: $e');
      return Response(500, body: jsonEncode({'error': 'Internal server error'}));
    }
  }

  static Future<Response> deleteUser(Request request, String id) async {
    try {
      final userId = int.tryParse(id);
      if (userId == null) {
        return Response(400, body: jsonEncode({'error': 'Invalid user ID'}));
      }
      final success = await Database().deleteUser(userId);
      if (!success) {
        return Response(404, body: jsonEncode({'error': 'User not found'}));
      }
      return Response(200, body: jsonEncode({'message': 'User deleted successfully'}));
    } catch (e) {
      print('Delete user error: $e');
      return Response(500, body: jsonEncode({'error': 'Internal server error'}));
    }
  }

  static Future<Response> getProfile(Request request) async {
    try {
      final user = request.context['user'] as Map<String, dynamic>?;
      if (user == null) {
        return Response(401, body: jsonEncode({'error': 'Not authenticated'}));
      }
      final userId = user['userId'] as int;
      final userData = await Database().getUserById(userId);
      if (userData == null) {
        return Response(404, body: jsonEncode({'error': 'User not found'}));
      }
      return Response.ok(jsonEncode({'user': userData.toSafeJson()}));
    } catch (e) {
      print('Get profile error: $e');
      return Response(500, body: jsonEncode({'error': 'Internal server error'}));
    }
  }

  // --- МЕТОДЫ, ВОССТАНОВЛЕННЫЕ ПОСЛЕ СЛУЧАЙНОГО УДАЛЕНИЯ ---

  // Получить роли пользователя по ID
  static Future<Response> getUserRoles(Request request, String id) async {
    try {
      final userId = int.tryParse(id);
      if (userId == null) {
        return Response(400, body: jsonEncode({'error': 'Invalid user ID'}));
      }

      final user = await Database().getUserById(userId);
      if (user == null) {
        return Response(404, body: jsonEncode({'error': 'User not found'}));
      }

      return Response.ok(jsonEncode({'roles': user.roles.map((r) => r.toJson()).toList()}));
    } catch (e) {
      print('Get user roles error: $e');
      return Response(500, body: jsonEncode({'error': 'Internal server error'}));
    }
  }

  // Получить тренера для клиента
  static Future<Response> getTrainerForClient(Request request) async {
    try {
      final user = request.context['user'] as Map<String, dynamic>?;
      if (user == null) {
        return Response(401, body: jsonEncode({'error': 'Not authenticated'}));
      }

      final clientId = user['userId'] as int;
      final trainer = await Database().getTrainerForClient(clientId);

      if (trainer == null) {
        return Response(404, body: jsonEncode({'error': 'Trainer not found for this client'}));
      }

      return Response.ok(jsonEncode({'trainer': trainer.toSafeJson()}));
    } catch (e) {
      print('Get trainer for client error: $e');
      return Response(500, body: jsonEncode({'error': 'Internal server error'}));
    }
  }

  // Получить инструктора для клиента
  static Future<Response> getInstructorForClient(Request request) async {
    try {
      final user = request.context['user'] as Map<String, dynamic>?;
      if (user == null) {
        return Response(401, body: jsonEncode({'error': 'Not authenticated'}));
      }

      final clientId = user['userId'] as int;
      final instructor = await Database().getInstructorForClient(clientId);

      if (instructor == null) {
        return Response(404, body: jsonEncode({'error': 'Instructor not found for this client'}));
      }

      return Response.ok(jsonEncode({'instructor': instructor.toSafeJson()}));
    } catch (e) {
      print('Get instructor for client error: $e');
      return Response(500, body: jsonEncode({'error': 'Internal server error'}));
    }
  }

  // Получить менеджера для клиента
  static Future<Response> getManagerForClient(Request request) async {
    try {
      final user = request.context['user'] as Map<String, dynamic>?;
      if (user == null) {
        return Response(401, body: jsonEncode({'error': 'Not authenticated'}));
      }

      final clientId = user['userId'] as int;
      final manager = await Database().getManagerForClient(clientId);

      if (manager == null) {
        return Response(404, body: jsonEncode({'error': 'Manager not found for this client'}));
      }

      return Response.ok(jsonEncode({'manager': manager.toSafeJson()}));
    } catch (e) {
      print('Get manager for client error: $e');
      return Response(500, body: jsonEncode({'error': 'Internal server error'}));
    }
  }

  static Future<Response> getRoles(Request request) async {
    try {
      final roles = await Database().getAllRoles();
      final rolesJson = roles.map((role) => role.toJson()).toList();
      return Response.ok(jsonEncode({'roles': rolesJson}));
    } catch (e) {
      print('Get roles error: $e');
      return Response(500, body: jsonEncode({'error': 'Internal server error'}));
    }
  }

  static Future<Response> resetPassword(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final email = data['email'] as String?;
      final newPassword = data['newPassword'] as String?;

      if (email == null || newPassword == null) {
        return Response(400, body: jsonEncode({'error': 'Email and newPassword are required'}));
      }

      final user = await Database().getUserByEmail(email);
      if (user == null) {
        return Response(404, body: jsonEncode({'error': 'User not found'}));
      }

      final passwordHash = BCrypt.hashpw(newPassword, BCrypt.gensalt());

      await Database().updateUserPassword(user.id, passwordHash);

      return Response.ok(jsonEncode({'message': 'Password reset successfully'}));
    } catch (e) {
      print('Reset password error: $e');
      return Response(500, body: jsonEncode({'error': 'Internal server error'}));
    }
  }
}