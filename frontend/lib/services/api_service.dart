import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../modules/roles/models/role.dart';
import '../models/schedule_item.dart';
import '../modules/users/models/user.dart';
import '../models/work_schedule.dart';
import '../models/client_schedule_preference.dart'; // Import ClientSchedulePreference
import '../modules/chat/models/chat_models.dart'; // Corrected import path
import '../models/whtr_profiles.dart';
import '../models/goal_training.dart';
import '../models/level_training.dart';
import '../modules/groups/models/training_group.model.dart';
import '../modules/groups/models/analytic_group.model.dart';
import '../modules/groups/models/group_schedule.model.dart';
import '../modules/groups/models/training_group_type.model.dart';
import 'package:fitman_app/modules/infrastructure/models/room/room.model.dart';
import 'package:fitman_app/modules/infrastructure/models/equipment/equipment_item.model.dart'; // New import
import 'package:fitman_app/modules/infrastructure/models/equipment/equipment_type.model.dart'; // New import
import 'package:fitman_app/modules/infrastructure/models/building/building.model.dart';

class ApiService {
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://localhost:8080';
  static String? _token;

  static String? get currentToken => _token;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  static Future<void> saveToken(String token) async {
    _token = token;
    print('Inside saveToken: _token set to $_token');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (currentToken != null) {
      headers['Authorization'] = 'Bearer $currentToken';
    }
    return headers;
  }

  // --- Infrastructure API Methods ---

  static Future<List<Room>> getAllRooms({String? buildingId, int? roomType, bool? isActive, bool? isArchived}) async {
    try {
      final queryParameters = <String, String>{};
      if (buildingId != null) {
        queryParameters['buildingId'] = buildingId;
      }
      if (roomType != null) {
        queryParameters['roomType'] = roomType.toString();
      }
      if (isActive != null) {
        queryParameters['isActive'] = isActive.toString();
      }
      if (isArchived != null) {
        queryParameters['isArchived'] = isArchived.toString();
      }

      final uri = Uri.parse('$baseUrl/api/rooms')
          .replace(queryParameters: queryParameters.isNotEmpty ? queryParameters : null);

      final response = await http.get(
        uri,
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((json) => Room.fromJson(json)).toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to load rooms');
      }
    } catch (e) {
      print('Get all rooms error: $e');
      rethrow;
    }
  }

  static Future<Room> getRoomById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/rooms/$id'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Room.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to load room $id');
      }
    } catch (e) {
      print('Get room by ID error: $e');
      rethrow;
    }
  }

  static Future<List<EquipmentItem>> getAllEquipmentItems({String? roomId}) async {
    try {
      final queryParameters = <String, String>{};
      if (roomId != null) {
        queryParameters['roomId'] = roomId;
      }

      final uri = Uri.parse('$baseUrl/api/equipment/items')
          .replace(queryParameters: queryParameters.isNotEmpty ? queryParameters : null);

      final response = await http.get(
        uri,
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((json) => EquipmentItem.fromJson(json)).toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to load equipment items');
      }
    } catch (e) {
      print('Get all equipment items error: $e');
      rethrow;
    }
  }

  static Future<List<EquipmentType>> getAllEquipmentTypes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/equipment/types'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((json) => EquipmentType.fromJson(json)).toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to load equipment types');
      }
    } catch (e) {
      print('Get all equipment types error: $e');
      rethrow;
    }
  }

  static Future<EquipmentType> getEquipmentTypeById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/equipment/types/$id'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return EquipmentType.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to load equipment type $id');
      }
    } catch (e) {
      print('Get equipment type by ID error: $e');
      rethrow;
    }
  }

  static Future<EquipmentType> createEquipmentType(EquipmentType equipmentType) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/equipment/types'),
        headers: _headers,
        body: jsonEncode(equipmentType.toJson()),
      );
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return EquipmentType.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to create equipment type');
      }
    } catch (e) {
      print('Create equipment type error: $e');
      rethrow;
    }
  }

  static Future<EquipmentType> updateEquipmentType(String id, EquipmentType equipmentType) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/equipment/types/$id'),
        headers: _headers,
        body: jsonEncode(equipmentType.toJson()),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return EquipmentType.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to update equipment type');
      }
    } catch (e) {
      print('Update equipment type error: $e');
      rethrow;
    }
  }

  static Future<void> deleteEquipmentType(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/equipment/types/$id'),
        headers: _headers,
      );
      if (response.statusCode != 204) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to delete equipment type');
      }
    } catch (e) {
      print('Delete equipment type error: $e');
      rethrow;
    }
  }

  static Future<Room> createRoom(Room room) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/rooms'),
        headers: _headers,
        body: jsonEncode(room.toJson()),
      );
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Room.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to create room');
      }
    } catch (e) {
      print('Create room error: $e');
      rethrow;
    }
  }

  static Future<Room> updateRoom(String id, Room room) async {
    try {
      final uri = Uri.parse('$baseUrl/api/rooms/$id');
      final headers = _headers;
      final body = jsonEncode(room.toJson());

      print('--- Update Room Request ---');
      print('URI: $uri');
      print('Headers: $headers');
      print('Body: $body');

      final response = await http.put(
        uri,
        headers: headers,
        body: body,
      );

      print('--- Update Room Response ---');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Room.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to update room');
      }
    } catch (e) {
      print('--- Update Room Error ---');
      print('Exception: $e');
      rethrow;
    }
  }

  static Future<void> deleteRoom(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/rooms/$id'),
        headers: _headers,
      );
      if (response.statusCode != 204) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to delete room');
      }
    } catch (e) {
      print('Delete room error: $e');
      rethrow;
    }
  }
  

  // --- End Infrastructure API Methods ---

  // --- Building API Methods ---
  static Future<List<Building>> getAllBuildings({bool? isArchived}) async {
    try {
      final queryParameters = <String, String>{};
      if (isArchived != null) {
        queryParameters['isArchived'] = isArchived.toString();
      }

      final uri = Uri.parse('$baseUrl/api/buildings')
          .replace(queryParameters: queryParameters.isNotEmpty ? queryParameters : null);

      final response = await http.get(
        uri,
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((json) => Building.fromJson(json)).toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to load buildings');
      }
    } catch (e) {
      print('Get all buildings error: $e');
      rethrow;
    }
  }

  static Future<Building> createBuilding(Building building) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/buildings'),
        headers: _headers,
        body: jsonEncode(building.toJson()),
      );
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Building.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to create building');
      }
    } catch (e) {
      print('Create building error: $e');
      rethrow;
    }
  }

  static Future<Building> updateBuilding(String id, Building building) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/buildings/$id'),
        headers: _headers,
        body: jsonEncode(building.toJson()),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Building.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to update building');
      }
    } catch (e) {
      print('Update building error: $e');
      rethrow;
    }
  }

  static Future<void> deleteBuilding(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/buildings/$id'),
        headers: _headers,
      );
      if (response.statusCode != 204) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to delete building');
      }
    } catch (e) {
      print('Delete building error: $e');
      rethrow;
    }
  }
  // --- End Building API Methods ---

  // Аутентификация
  static Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: _headers,
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token']?.toString() ?? '';
        final userData = data['user'] ?? {};

        if (token.isEmpty) {
          throw Exception('No token received from server');
        }

        final user = User.fromJson(userData);

        return AuthResponse(token: token, user: user);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ??
              errorData['error'] ??
              'Login failed with status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  static Future<AuthResponse> register(
    String email,
    String password,
    String firstName,
    String lastName,
    List<String> roles,
    String? phone,
    String? gender,
    DateTime? dateOfBirth,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'roles': roles,
          'phone': phone,
          'gender': gender,
          'dateOfBirth': dateOfBirth?.toIso8601String(),
        }),
      );

      print('=== REGISTER RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token']?.toString() ?? '';
        final userData = data['user'] ?? {};

        if (token.isEmpty) {
          throw Exception('No token received from server');
        }

        final user = User.fromJson(userData);

        return AuthResponse(token: token, user: user);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ??
              errorData['error'] ??
              'Registration failed with status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Register error: $e');
      rethrow;
    }
  }

  static Future<User> checkTokenAndGetUser() async {
    // Ensure the token is loaded before making the call
    if (_token == null) await init();
    if (_token == null) throw Exception('No token available');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/check'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // The /api/auth/check endpoint returns a map with an 'user' key
        final user = User.fromJson(data['user']);
        return user;
      } else {
        // This will be caught by AuthNotifier to trigger logout
        throw Exception('Token validation failed with status ${response.statusCode}');
      }
    } catch (e) {
      // Rethrow to be caught by AuthNotifier
      print('Check token error: $e');
      rethrow;
    }
  }

  // Создание пользователя (для админа)
  static Future<User> createUser(
    CreateUserRequest request,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/users'),
        headers: _headers,
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final userData = data['user'] as Map<String, dynamic>;
        return User.fromJson(userData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['error'] ??
              'Failed to create user with status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Create user error: $e');
      rethrow;
    }
  }

  // Обновление пользователя (для админа)
  static Future<User> updateUser(UpdateUserRequest request) async {
    try {
      final requestBody = request.toJson();
      final response = await http.put(
        Uri.parse('$baseUrl/api/users/${request.id}'),
        headers: _headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userData = data['user'] as Map<String, dynamic>;
        return User.fromJson(userData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['error'] ??
              'Failed to update user with status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Update user error: $e');
      rethrow;
    }
  }

  // Получение списка пользователей (для админа)
  static Future<List<User>> getUsers({String? role, int? offset, int? limit, bool? isArchived}) async {
    try {
      final queryParameters = <String, String>{};
      if (role != null) {
        queryParameters['role'] = role;
      }
      if (isArchived != null) {
        queryParameters['isArchived'] = isArchived.toString();
      }
      if (offset != null) {
        queryParameters['offset'] = offset.toString();
      }
      if (limit != null) {
        queryParameters['limit'] = limit.toString();
      }

      final uri = Uri.parse('$baseUrl/api/users').replace(queryParameters: queryParameters.isNotEmpty ? queryParameters : null);

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final users = data['users'] as List;
        return users.map((userData) => User.fromJson(userData)).toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
          error['error'] ?? 'Failed to load users with status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Get users error: $e');
      rethrow;
    }
  }

  static Future<User> getUserById(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/$userId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data['user']);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to load user');
      }
    } catch (e) {
      print('Get User by ID error: $e');
      rethrow;
    }
  }

  // Получение всех ролей
  static Future<List<Role>> getAllRoles() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/roles'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final roles = data['roles'] as List;
        return roles.map((roleData) => Role.fromJson(roleData)).toList();
      } else {
        throw Exception(
          'Failed to load roles with status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Get all roles error: $e');
      rethrow;
    }
  }

  // Получение ролей пользователя по ID
  static Future<List<Role>> getUserRoles(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/$userId/roles'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final roles = data['roles'] as List;
        return roles.map((roleData) => Role.fromJson(roleData)).toList();
      } else {
        throw Exception(
          'Failed to load user roles with status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Get user roles error: $e');
      rethrow;
    }
  }

  // Обновление ролей пользователя
  static Future<void> updateUserRoles(
    int userId,
    List<String> roleNames,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/users/$userId/roles'),
        headers: _headers,
        body: jsonEncode({'roles': roleNames}),
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['error'] ??
              'Failed to update user roles with status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Update user roles error: $e');
      rethrow;
    }
  }

  // Архивация пользователя
  static Future<void> archiveUser(int userId, {String? reason}) async { // Added reason parameter
    try {
      final requestBody = <String, dynamic>{'archivedAt': DateTime.now().toIso8601String()};
      if (reason != null && reason.isNotEmpty) {
        requestBody['archivedReason'] = reason;
      }

      final response = await http.put(
        Uri.parse('$baseUrl/api/users/$userId'), // Use the existing update user endpoint
        headers: _headers,
        body: jsonEncode(requestBody), // Set archivedAt and optionally archivedReason for archival
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['error'] ??
              'Failed to archive user with status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Archive user error: $e');
      rethrow;
    }
  }

  // Получение списка клиентов для менеджера
  static Future<List<User>> getAssignedClients(int managerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/managers/$managerId/clients'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['error'] ??
              'Failed to load assigned clients with status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Get assigned clients error: $e');
      rethrow;
    }
  }

  // Получение списка инструкторов для менеджера
  static Future<List<User>> getAssignedInstructors(int managerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/managers/$managerId/instructors'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['error'] ??
              'Failed to load assigned instructors with status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Get assigned instructors error: $e');
      rethrow;
    }
  }

  // Получение списка тренеров для менеджера
  static Future<List<User>> getAssignedTrainers(int managerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/managers/$managerId/trainers'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['error'] ??
              'Failed to load assigned trainers with status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Get assigned trainers error: $e');
      rethrow;
    }
  }

  // Получение списка клиентов для инструктора
  static Future<List<User>> getAssignedClientsForInstructor(
    int instructorId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/instructors/$instructorId/clients'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['error'] ??
              'Failed to load assigned clients for instructor with status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Get assigned clients for instructor error: $e');
      rethrow;
    }
  }

  // Получение списка тренеров для инструктора
  static Future<List<User>> getAssignedTrainersForInstructor(
    int instructorId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/instructors/$instructorId/trainers'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['error'] ??
              'Failed to load assigned trainers for instructor with status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Get assigned trainers for instructor error: $e');
      rethrow;
    }
  }

  // Получение менеджера для инструктора
  static Future<User> getAssignedManagerForInstructor(int instructorId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/instructors/$instructorId/manager'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['error'] ??
              'Failed to load assigned manager for instructor with status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Get assigned manager for instructor error: $e');
      rethrow;
    }
  }

  // Получение ID клиентов, назначенных менеджеру
  static Future<List<int>> getAssignedClientIds(int managerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/managers/$managerId/clients/ids'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<int>().toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['error'] ?? 'Failed to load assigned client IDs',
        );
      }
    } catch (e) {
      print('Get assigned client IDs error: $e');
      rethrow;
    }
  }

  // Назначение клиентов менеджеру
  static Future<void> assignClientsToManager(
    int managerId,
    List<int> clientIds,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/managers/$managerId/clients'),
        headers: _headers,
        body: jsonEncode({'client_ids': clientIds}),
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to assign clients');
      }
    } catch (e) {
      print('Assign clients error: $e');
      rethrow;
    }
  }

  // Получение ID инструкторов, назначенных менеджеру
  static Future<List<int>> getAssignedInstructorIds(int managerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/managers/$managerId/instructors/ids'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<int>().toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['error'] ?? 'Failed to load assigned instructor IDs',
        );
      }
    } catch (e) {
      print('Get assigned instructor IDs error: $e');
      rethrow;
    }
  }

  // Назначение инструкторов менеджеру
  static Future<void> assignInstructorsToManager(
    int managerId,
    List<int> instructorIds,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/managers/$managerId/instructors'),
        headers: _headers,
        body: jsonEncode({'instructor_ids': instructorIds}),
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to assign instructors');
      }
    } catch (e) {
      print('Assign instructors error: $e');
      rethrow;
    }
  }

  // Получение ID тренеров, назначенных менеджеру
  static Future<List<int>> getAssignedTrainerIds(int managerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/managers/$managerId/trainers/ids'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<int>().toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['error'] ??
              'Failed to load assigned trainer IDs with status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Get assigned trainers error: $e');
      rethrow;
    }
  }

  // Назначение тренеров менеджеру
  static Future<void> assignTrainersToManager(
    int managerId,
    List<int> trainerIds,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/managers/$managerId/trainers'),
        headers: _headers,
        body: jsonEncode({'trainer_ids': trainerIds}),
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to assign trainers');
      }
    } catch (e) {
      print('Assign trainers error: $e');
      rethrow;
    }
  }


  // Получение планов тренировок
  static Future<List<dynamic>> getTrainingPlans() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/training/plans'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['plans'] as List;
    } else {
      throw Exception(
        'Failed to load training plans with status ${response.statusCode}',
      );
    }
  }

  // Получение расписания
  static Future<List<ScheduleItem>> getSchedule() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/schedule'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final scheduleList = data['schedule'] as List;
      return scheduleList.map((item) => ScheduleItem.fromJson(item)).toList();
    } else {
      throw Exception(
        'Failed to load schedule with status ${response.statusCode}',
      );
    }
  }

  // --- Chat API Methods ---

  static Future<List<Chat>> getChats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/chats'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((chatJson) => Chat.fromJson(chatJson)).toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to load chats');
      }
    } catch (e) {
      print('Get Chats error: $e');
      rethrow;
    }
  }

  static Future<List<Message>> getMessages(int chatId, {int limit = 50, int offset = 0}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/chats/$chatId/messages?limit=$limit&offset=$offset'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((msgJson) => Message.fromJson(msgJson)).toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to load messages for chat $chatId');
      }
    } catch (e) {
      print('Get Messages error: $e');
      rethrow;
    }
  }

  static Future<int> createOrGetPrivateChat(int peerId) async {
     try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/chats/private'),
        headers: _headers,
        body: jsonEncode({'peerId': peerId}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['chat_id'] as int;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to create or get private chat');
      }
    } catch (e) {
      print('Create or Get Private Chat error: $e');
      rethrow;
    }
  }






















  static Future<List<TrainingGroupType>> getAllTrainingGroupTypes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/training_group_types'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((json) => TrainingGroupType.fromJson(json)).toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to load training group types');
      }
    } catch (e) {
      print('Get all training group types error: $e');
      rethrow;
    }
  }

  // --- Group API Methods ---

  // Training Groups
  static Future<List<TrainingGroup>> getAllTrainingGroups({
    String? searchQuery,
    int? groupTypeId,
    bool? isActive,
    bool? isArchived,
    int? trainerId,
    int? instructorId,
    int? managerId,
  }) async {
    try {
      final queryParameters = <String, String>{};
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParameters['q'] = searchQuery;
      }
      if (groupTypeId != null) {
        queryParameters['groupTypeId'] = groupTypeId.toString();
      }
      if (isActive != null) {
        queryParameters['isActive'] = isActive.toString();
      }
      if (isArchived != null) {
        queryParameters['isArchived'] = isArchived.toString();
      }
      if (trainerId != null) {
        queryParameters['trainerId'] = trainerId.toString();
      }
      if (instructorId != null) {
        queryParameters['instructorId'] = instructorId.toString();
      }
      if (managerId != null) {
        queryParameters['managerId'] = managerId.toString();
      }

      final uri = Uri.parse('$baseUrl/api/training_groups')
          .replace(queryParameters: queryParameters.isNotEmpty ? queryParameters : null);

      final response = await http.get(
        uri,
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        final List<TrainingGroup> groups = [];
        for (final json in data) {
          try {
            groups.add(TrainingGroup.fromJson(json));
          } catch (e) {
            print('--- ERROR PARSING TRAINING GROUP ---');
            print('Problematic JSON: $json');
            print('Error: $e');
            print('------------------------------------');
            rethrow;
          }
        }
        return groups;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to load training groups');
      }
    } catch (e) {
      print('Get all training groups error: $e');
      rethrow;
    }
  }

  static Future<TrainingGroup> getTrainingGroupById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/training_groups/$id'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return TrainingGroup.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to load training group $id');
      }
    } catch (e) {
      print('Get training group by ID error: $e');
      rethrow;
    }
  }

  static Future<TrainingGroup> createTrainingGroup(TrainingGroup group) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/training_groups'),
        headers: _headers,
        body: jsonEncode(group.toJson()),
      );
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return TrainingGroup.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to create training group');
      }
    } catch (e) {
      print('Create training group error: $e');
      rethrow;
    }
  }

  static Future<TrainingGroup> updateTrainingGroup(TrainingGroup group) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/training_groups/${group.id}'),
        headers: _headers,
        body: jsonEncode(group.toJson()),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return TrainingGroup.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to update training group');
      }
    } catch (e) {
      print('Update training group error: $e');
      rethrow;
    }
  }

  static Future<void> deleteTrainingGroup(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/training_groups/$id'),
        headers: _headers,
      );
      if (response.statusCode != 204) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to delete training group $id');
      }
    } catch (e) {
      print('Delete training group error: $e');
      rethrow;
    }
  }

  // Analytic Groups
  static Future<List<AnalyticGroup>> getAllAnalyticGroups({
    bool? isActive,
    bool? isArchived,
  }) async {
    try {
      final queryParameters = <String, String>{};
      if (isActive != null) {
        queryParameters['isActive'] = isActive.toString();
      }
      if (isArchived != null) {
        queryParameters['isArchived'] = isArchived.toString();
      }

      final uri = Uri.parse('$baseUrl/api/analytic_groups')
          .replace(queryParameters: queryParameters.isNotEmpty ? queryParameters : null);

      final response = await http.get(
        uri,
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((json) => AnalyticGroup.fromJson(json)).toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to load analytic groups');
      }
    } catch (e) {
      print('Get all analytic groups error: $e');
      rethrow;
    }
  }

  static Future<AnalyticGroup> getAnalyticGroupById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/analytic_groups/$id'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AnalyticGroup.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to load analytic group $id');
      }
    } catch (e) {
      print('Get analytic group by ID error: $e');
      rethrow;
    }
  }

  static Future<AnalyticGroup> createAnalyticGroup(AnalyticGroup group) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/analytic_groups'),
        headers: _headers,
        body: jsonEncode(group.toJson()),
      );
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return AnalyticGroup.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to create analytic group');
      }
    } catch (e) {
      print('Create analytic group error: $e');
      rethrow;
    }
  }

  static Future<AnalyticGroup> updateAnalyticGroup(AnalyticGroup group) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/analytic_groups/${group.id}'),
        headers: _headers,
        body: jsonEncode(group.toJson()),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AnalyticGroup.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to update analytic group');
      }
    } catch (e) {
      print('Update analytic group error: $e');
      rethrow;
    }
  }

  static Future<void> deleteAnalyticGroup(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/analytic_groups/$id'),
        headers: _headers,
      );
      if (response.statusCode != 204) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to delete analytic group $id');
      }
    } catch (e) {
      print('Delete analytic group error: $e');
      rethrow;
    }
  }

  // Group Schedule Slots
  static Future<List<GroupSchedule>> getGroupSchedules(int groupId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/group_schedules/$groupId'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((json) => GroupSchedule.fromJson(json)).toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to load group schedule slots for group $groupId');
      }
    } catch (e) {
      print('Get group schedule slots error: $e');
      rethrow;
    }
  }

  static Future<GroupSchedule> createGroupSchedule(int groupId, GroupSchedule slot) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/group_schedules/$groupId'),
        headers: _headers,
        body: jsonEncode(slot.toJson()),
      );
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return GroupSchedule.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to create group schedule slot');
      }
    } catch (e) {
      print('Create group schedule slot error: $e');
      rethrow;
    }
  }

  static Future<GroupSchedule> updateGroupSchedule(GroupSchedule slot) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/group_schedules/${slot.id}'),
        headers: _headers,
        body: jsonEncode(slot.toJson()),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return GroupSchedule.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to update group schedule slot');
      }
    } catch (e) {
      print('Update group schedule slot error: $e');
      rethrow;
    }
  }

  static Future<void> deleteGroupSchedule(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/group_schedules/$id'),
        headers: _headers,
      );
      if (response.statusCode != 204) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to delete group schedule slot $id');
      }
    } catch (e) {
      print('Delete group schedule slot error: $e');
      rethrow;
    }
  }

  // Training Group Members
  static Future<List<int>> getTrainingGroupMembers(int groupId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/training_groups/$groupId/members'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.cast<int>().toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to load group members for group $groupId');
      }
    } catch (e) {
      print('Get training group members error: $e');
      rethrow;
    }
  }

  static Future<void> addTrainingGroupMember(int groupId, int userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/training_groups/$groupId/members'),
        headers: _headers,
        body: jsonEncode({'userId': userId}),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to add member to group $groupId');
      }
    } catch (e) {
      print('Add training group member error: $e');
      rethrow;
    }
  }

  static Future<void> removeTrainingGroupMember(int groupId, int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/training_groups/$groupId/members/$userId'),
        headers: _headers,
      );
      if (response.statusCode != 204) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to remove member from group $groupId');
      }
    } catch (e) {
      print('Remove training group member error: $e');
      rethrow;
    }
  }

  // --- End Group API Methods ---

  // Group Schedule Slots
  static Future<List<GroupSchedule>> getGroupScheduleSlots(int groupId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/group_schedules/$groupId'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((json) => GroupSchedule.fromJson(json)).toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to load group schedule slots for group $groupId');
      }
    } catch (e) {
      print('Get group schedule slots error: $e');
      rethrow;
    }
  }

  static Future<GroupSchedule> createGroupScheduleSlot(int groupId, GroupSchedule slot) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/group_schedules/$groupId'),
        headers: _headers,
        body: jsonEncode(slot.toJson()),
      );
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return GroupSchedule.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to create group schedule slot');
      }
    } catch (e) {
      print('Create group schedule slot error: $e');
      rethrow;
    }
  }

  static Future<GroupSchedule> updateGroupScheduleSlot(GroupSchedule slot) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/group_schedules/${slot.id}'),
        headers: _headers,
        body: jsonEncode(slot.toJson()),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return GroupSchedule.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to update group schedule slot');
      }
    } catch (e) {
      print('Update group schedule slot error: $e');
      rethrow;
    }
  }

  static Future<void> deleteGroupScheduleSlot(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/group_schedules/$id'),
        headers: _headers,
      );
      if (response.statusCode != 204) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to delete group schedule slot $id');
      }
    } catch (e) {
      print('Delete group schedule slot error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getClientDashboardData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/dashboard/client'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['error'] ??
              'Failed to load dashboard data with status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Get client dashboard data error: $e');
      rethrow;
    }
  }

  // Получение тренера для клиента
  static Future<User> getTrainerForClient() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/client/trainer'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data['trainer']);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['error'] ??
              'Failed to load trainer data with status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Get trainer for client error: $e');
      rethrow;
    }
  }

  // Получение инструктора для клиента
  static Future<User> getInstructorForClient() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/client/instructor'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data['instructor']);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['error'] ??
              'Failed to load instructor data with status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Get instructor for client error: $e');
      rethrow;
    }
  }

  // Получение менеджера для клиента
  static Future<User> getManagerForClient() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/client/manager'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data['manager']);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['error'] ??
              'Failed to load manager data with status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Get manager for client error: $e');
      rethrow;
    }
  }

  // Получение данных антропометрии для клиента
  static Future<Map<String, dynamic>> getOwnAnthropometryData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/client/anthropometry'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['error'] ??
              'Failed to load anthropometry data with status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Get anthropometry data error: $e');
      rethrow;
    }
  }

  // Получение строки профиля соматотипа
  static Future<String> getSomatotypeProfile({int? clientId, bool isAdmin = false}) async {
    try {
      // If an admin is making the request for a specific client, use the admin route.
      // Otherwise, use the client route (which authenticates via token).
      final url = isAdmin && clientId != null
          ? '$baseUrl/api/admin/clients/$clientId/anthropometry/somatotype'
          : '$baseUrl/api/client/anthropometry/somatotype';

      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['profile_string'] ?? 'Не удалось рассчитать соматотип.';
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['error'] ?? 'Failed to load somatotype profile with status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Get somatotype profile error: $e');
      rethrow;
    }
  }

  static Future<WhtrProfiles> getWhtrProfiles({int? clientId, bool isAdmin = false}) async {
    try {
      final url = isAdmin && clientId != null
          ? '$baseUrl/api/admin/clients/$clientId/anthropometry/whtr-profiles'
          : '$baseUrl/api/client/anthropometry/whtr-profiles';

      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return WhtrProfiles.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['error'] ?? 'Failed to load WHtR profiles with status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Get WHtR profiles error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getAnthropometryDataForClient(int clientId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/clients/$clientId/anthropometry'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['error'] ??
              'Failed to load anthropometry data with status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Get anthropometry data error: $e');
      rethrow;
    }
  }

  static Future<void> updateAnthropometryFixed({
    int? clientId,
    required int height,
    required int wristCirc,
    required int ankleCirc,
  }) async {
    try {
      final url = clientId != null
          ? '$baseUrl/api/admin/clients/$clientId/anthropometry/fixed'
          : '$baseUrl/api/client/anthropometry/fixed';
      final body = {
        'height': height,
        'wristCirc': wristCirc,
        'ankleCirc': ankleCirc,
      };
      if (clientId != null) {
        body['clientId'] = clientId;
      }

      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['error'] ?? 'Failed to update fixed anthropometry with status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Update fixed anthropometry error: $e');
      rethrow;
    }
  }

  static Future<void> updateAnthropometryMeasurements({
    int? clientId,
    required String type,
    required double weight,
    required int shouldersCirc,
    required int breastCirc,
    required int waistCirc,
    required int hipsCirc,
  }) async {
    try {
      final url = clientId != null
          ? '$baseUrl/api/admin/clients/$clientId/anthropometry/measurements'
          : '$baseUrl/api/client/anthropometry/measurements';
      final body = {
        'type': type,
        'weight': weight,
        'shouldersCirc': shouldersCirc,
        'breastCirc': breastCirc,
        'waistCirc': waistCirc,
        'hipsCirc': hipsCirc,
      };
      if (clientId != null) {
        body['clientId'] = clientId;
      }

      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['error'] ?? 'Failed to update measurements anthropometry with status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Update measurements anthropometry error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> uploadAnthropometryPhoto(
    List<int> photoBytes,
    String fileName,
    String type,
    {int? clientId, DateTime? photoDateTime}
  ) async {
    try {
      final url = clientId != null
          ? '$baseUrl/api/admin/clients/$clientId/anthropometry/photo'
          : '$baseUrl/api/client/anthropometry/photo';
      
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll({
        'Authorization': 'Bearer $currentToken',
      });
      request.fields['type'] = type;
      if (clientId != null) {
        request.fields['clientId'] = clientId.toString();
      }
      if (photoDateTime != null) {
        request.fields['photoDateTime'] = photoDateTime.toIso8601String();
      }
      request.files.add(http.MultipartFile.fromBytes(
        'photo',
        photoBytes,
        filename: fileName,
      ));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        return jsonDecode(responseBody) as Map<String, dynamic>;
      } else {
        final responseBody = await response.stream.bytesToString();
        final errorData = jsonDecode(responseBody);
        throw Exception(
          errorData['error'] ?? 'Failed to upload photo with status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Upload anthropometry photo error: $e');
      rethrow;
    }
  }

  // Загрузка аватара пользователя
  static Future<Map<String, dynamic>> uploadAvatar(
    List<int> photoBytes,
    String fileName,
    int userId,
  ) async {
    try {
      final url = '$baseUrl/api/users/$userId/avatar';
      
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll({
        'Authorization': 'Bearer $currentToken',
      });

      request.files.add(http.MultipartFile.fromBytes(
        'photo',
        photoBytes,
        filename: fileName,
      ));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        return jsonDecode(responseBody) as Map<String, dynamic>;
      } else {
        final responseBody = await response.stream.bytesToString();
        final errorData = jsonDecode(responseBody);
        throw Exception(
          errorData['error'] ?? 'Failed to upload avatar with status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Upload avatar error: $e');
      rethrow;
    }
  }

  // Получение данных отслеживания калорий для клиента
  static Future<List<dynamic>> getCalorieTrackingData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/client/calorie-tracking'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['error'] ??
              'Failed to load calorie tracking data with status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Get calorie tracking data error: $e');
      rethrow;
    }
  }

  // Получение данных прогресса для клиента
  static Future<Map<String, dynamic>> getProgressData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/client/progress'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['error'] ??
              'Failed to load progress data with status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Get progress data error: $e');
      rethrow;
    }
  }

  // Получение расписания работы центра
  static Future<List<WorkSchedule>> getWorkSchedules() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/work-schedules'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => WorkSchedule.fromJson(json)).toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['error'] ??
              'Failed to load work schedules with status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Get work schedules error: $e');
      rethrow;
    }
  }

  // Обновление расписания работы центра
  static Future<void> updateWorkSchedule(WorkSchedule schedule) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/work-schedules'),
        headers: _headers,
        body: jsonEncode(schedule.toJson()),
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['error'] ??
              'Failed to update work schedule with status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Update work schedule error: $e');
      rethrow;
    }
  }

  // Сохранение предпочтений клиента
  static Future<void> saveClientPreferences(
    List<ClientSchedulePreference> preferences,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/client/preferences'),
        headers: _headers,
        body: jsonEncode(preferences.map((p) => p.toJson()).toList()),
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['error'] ??
              'Failed to save client preferences with status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Save client preferences error: $e');
      rethrow;
    }
  }

  // Получение предпочтений клиента
  static Future<List<ClientSchedulePreference>> getClientPreferences() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/client/preferences'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => ClientSchedulePreference.fromJson(json))
            .toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['error'] ??
              'Failed to load client preferences with status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Get client preferences error: $e');
      rethrow;
    }
  }

  // Сброс пароля пользователя (для админа)
  static Future<void> resetUserPassword(
    String email,
    String newPassword,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/users/reset-password'),
        headers: _headers,
        body: jsonEncode({'email': email, 'newPassword': newPassword}),
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['error'] ??
              'Failed to reset password with status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Reset password error: $e');
      rethrow;
    }
  }

  // Получить каталог "Цели тренировок"
  static Future<List<GoalTraining>> getGoalsTraining() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/catalogs/goals-training'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((item) => GoalTraining.fromJson(item)).toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to load training goals');
      }
    } catch (e) {
      print('Get Goals Training error: $e');
      rethrow;
    }
  }

  // Получить каталог "Уровни подготовки"
  static Future<List<LevelTraining>> getLevelsTraining() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/catalogs/levels-training'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((item) => LevelTraining.fromJson(item)).toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to load training levels');
      }
    } catch (e) {
      print('Get Levels Training error: $e');
      rethrow;
    }
  }

  // Обновить профиль клиента (цель, уровень)
  static Future<User> updateClientProfile(
      Map<String, dynamic> clientProfileData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/client/profile'),
        headers: _headers,
        body: jsonEncode({
          'client_profile': clientProfileData,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data['user']);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to update client profile');
      }
    } catch (e) {
      print('Update Client Profile error: $e');
      rethrow;
    }
  }

  // Получить рекомендацию для клиента
  static Future<Map<String, String?>> getRecommendation(int clientId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/recommendations/$clientId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        // Ensure that the values are nullable strings
        return data.map((key, value) => MapEntry(key, value?.toString()));
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['error'] ?? 'Failed to load recommendation with status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Get recommendation error: $e');
      rethrow;
    }
  }

  // Загрузка вложений для чата
  static Future<Map<String, dynamic>> uploadChatAttachment(
    List<int> fileBytes,
    String fileName,
    String? mimeType,
  ) async {
    try {
      final url = '$baseUrl/api/uploads/chat';
      
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll({
        'Authorization': 'Bearer $currentToken',
      });
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName,
        contentType: mimeType != null ? MediaType.parse(mimeType) : null,
      ));

      final response = await request.send();

      if (response.statusCode == 201) {
        final responseBody = await response.stream.bytesToString();
        return jsonDecode(responseBody) as Map<String, dynamic>;
      } else {
        final responseBody = await response.stream.bytesToString();
        final errorData = jsonDecode(responseBody);
        throw Exception(
          errorData['error'] ?? 'Failed to upload chat attachment with status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Upload chat attachment error: $e');
      rethrow;
    }
  }

  // Создание группового чата
  static Future<int> createGroupChat(List<int> userIds, {String? name}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/chat'),
        headers: _headers,
        body: jsonEncode({
          'userIds': userIds,
          if (name != null) 'name': name,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['chat_id'] as int;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to create group chat');
      }
    } catch (e) {
      print('Create group chat error: $e');
      rethrow;
    }
  }
}
