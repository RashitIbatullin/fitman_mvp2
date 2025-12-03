import 'dart:async';
import 'dart:io';
import 'package:postgres/postgres.dart';
import 'package:dotenv/dotenv.dart';
import '../models/user_back.dart';
import '../models/role.dart';

class Database {
  static final Database _instance = Database._internal();
  factory Database() => _instance;
  Database._internal();

  Connection? _connection;
  bool _isConnecting = false;
  Completer<void>? _connectionCompleter;

  Future<Connection> get connection async {
    if (_connection != null) {
      return _connection!;
    }

    if (_isConnecting && _connectionCompleter != null) {
      await _connectionCompleter!.future;
      return _connection!;
    }

    await connect();
    return _connection!;
  }

        Future<void> connect() async {
          if (_connection != null) return;

          _isConnecting = true;
          _connectionCompleter = Completer<void>();

            try {

              // Загружаем переменные окружения
              final env = DotEnv()..load();

              // Создаем Endpoint для подключения
              final endpoint = Endpoint(
                host: env['DB_HOST'] ?? 'localhost',
                port: int.tryParse(env['DB_PORT'] ?? '5432') ?? 5432,
                database: env['DB_NAME'] ?? 'fitman_mvp2',
                username: env['DB_USER'] ?? 'postgres',
                password: env['DB_PASS'] ?? 'postgres',

              );

              print('🔄 Connecting to PostgreSQL database...');
            // Открываем соединение через статический метод
            _connection = await Connection.open(endpoint, settings: ConnectionSettings(sslMode: SslMode.disable));
            print('✅ Connected to PostgreSQL database');

            _connectionCompleter!.complete();
                                        } catch (e) {
                                          print('❌ Database connection error: $e');
                                          _connectionCompleter!.completeError(e);
                                          rethrow;
                                        } finally {
                                          _isConnecting = false;
                                        }
        }
    Future<void> disconnect() async {
    await _connection?.close();
    _connection = null;
    _connectionCompleter = null;
  }

  // === USER METHODS ===

  // Получить все роли
  Future<List<Role>> getAllRoles() async {
    try {
      final conn = await connection;
      final results = await conn.execute('''
        SELECT id, name, title, icon FROM roles
      ''');
      return results.map((row) => Role.fromMap(row.toColumnMap())).toList();
    } catch (e) {
      print('❌ getAllRoles error: $e');
      rethrow;
    }
  }

  // Получить роль по имени
  Future<Role?> getRoleByName(String roleName) async {
    try {
      final conn = await connection;
      final results = await conn.execute(
        Sql.named('SELECT id, name, title, icon FROM roles WHERE name = @roleName'),
        parameters: {'roleName': roleName},
      );
      if (results.isEmpty) return null;
      return Role.fromMap(results.first.toColumnMap());
    } catch (e) {
      print('❌ getRoleByName error: $e');
      rethrow;
    }
  }

  // Получить роли для пользователя
  Future<List<Role>> getRolesForUser(int userId, [Session? context]) async {
    try {
      final conn = context ?? await connection;
      final results = await conn.execute(
        Sql.named('''
          SELECT r.id, r.name, r.title, r.icon
          FROM roles r
          INNER JOIN user_roles ur ON r.id = ur.role_id
          WHERE ur.user_id = @userId
        '''),
        parameters: {'userId': userId},
      );
      return results.map((row) => Role.fromMap(row.toColumnMap())).toList();
    } catch (e) {
      print('❌ getRolesForUser error: $e');
      rethrow;
    }
  }

  // Получить всех пользователей
  Future<List<User>> getAllUsers() async {
    try {
      final conn = await connection;
      final results = await conn.execute('''
        SELECT id, email, password_hash, first_name, last_name, middle_name, phone, gender, date_of_birth, photo_url, created_at, updated_at
        FROM users
        ORDER BY last_name, first_name
      ''');

      final users = <User>[];
      for (final row in results) {
        final userMap = row.toColumnMap();
        final user = User.fromMap(userMap);
        final roles = await getRolesForUser(user.id);
        users.add(user.copyWith(roles: roles));
      }
      return users;
    } catch (e) {
      print('❌ getAllUsers error: $e');
      rethrow;
    }
  }

  // Получить пользователя по email
  Future<User?> getUserByEmail(String email) async {
    try {
      final conn = await connection;

      final sql = '''
        SELECT id, email, password_hash, first_name, last_name, middle_name, phone, gender, date_of_birth, photo_url, created_at, updated_at
        FROM users
        WHERE email = @email
        LIMIT 1
      ''';

      final results = await conn.execute(
        Sql.named(sql),
        parameters: {
          'email': email,
        },
      );

      if (results.isEmpty) return null;

      final userMap = results.first.toColumnMap();
      final user = User.fromMap(userMap);
      final roles = await getRolesForUser(user.id);
      return user.copyWith(roles: roles);
    } catch (e) {
      print('❌ getUserByEmail error: $e');
      rethrow;
    }
  }

  // Получить пользователя по телефону
  Future<User?> getUserByPhone(String phone) async {
    try {
      final conn = await connection;

      final sql = '''
        SELECT id, email, password_hash, first_name, last_name, middle_name, phone, gender, date_of_birth, photo_url, created_at, updated_at
        FROM users
        WHERE phone = @phone
        LIMIT 1
      ''';

      final results = await conn.execute(
        Sql.named(sql),
        parameters: {
          'phone': phone,
        },
      );

      if (results.isEmpty) return null;

      final userMap = results.first.toColumnMap();
      final user = User.fromMap(userMap);
      final roles = await getRolesForUser(user.id);
      return user.copyWith(roles: roles);
    } catch (e) {
      print('❌ getUserByPhone error: $e');
      rethrow;
    }
  }

  // Получить пользователя по ID
  Future<User?> getUserById(int id) async {
    try {
      final conn = await connection;

      final sql = '''
        SELECT id, email, password_hash, first_name, last_name, middle_name, phone, gender, date_of_birth, photo_url, created_at, updated_at
        FROM users
        WHERE id = @id
        LIMIT 1
      ''';

      final results = await conn.execute(
        Sql.named(sql),
        parameters: {
          'id': id,
        },
      );

      if (results.isEmpty) return null;

      final userMap = results.first.toColumnMap();
      final user = User.fromMap(userMap);
      final roles = await getRolesForUser(user.id);
      return user.copyWith(roles: roles);
    } catch (e) {
      print('❌ getUserById error: $e');
      rethrow;
    }
  }

  // Создать пользователя
  Future<User> createUser(User user, List<String> roleNames, [int? creatorId]) async {
    final conn = await connection;
    return await conn.runTx((ctx) async {
      // 1. Вставить пользователя в таблицу users и получить его ID
      final userResult = await ctx.execute(
        Sql.named('''
          INSERT INTO users (login, email, password_hash, first_name, last_name, phone, gender, date_of_birth, created_at, updated_at)
          VALUES (@login, @email, @password_hash, @first_name, @last_name, @phone, @gender, @date_of_birth, @created_at, @updated_at)
          RETURNING id
        '''),
        parameters: {
          'login': user.email, // Используем email как логин по умолчанию
          'email': user.email,
          'password_hash': user.passwordHash,
          'first_name': user.firstName,
          'last_name': user.lastName,
          'phone': user.phone,
          'gender': user.gender == 'мужской' ? 0 : 1,
          'date_of_birth': user.dateOfBirth,
          'created_at': user.createdAt,
          'updated_at': user.updatedAt,
        },
      );

      final newUserId = userResult.first[0] as int;
      final finalCreatorId = creatorId ?? newUserId;

      // 2. Обновить created_by и updated_by
      await ctx.execute(
        Sql.named('''
          UPDATE users 
          SET created_by = @creatorId, updated_by = @creatorId 
          WHERE id = @userId
        '''),
        parameters: {
          'creatorId': finalCreatorId,
          'userId': newUserId,
        },
      );


      // 3. Связать пользователя с ролями
      for (final roleName in roleNames) {
        final roleResult = await ctx.execute(
          Sql.named('SELECT id FROM roles WHERE name = @roleName'),
          parameters: {'roleName': roleName},
        );

        if (roleResult.isEmpty) {
          throw Exception('Role not found: $roleName');
        }
        final roleId = roleResult.first[0] as int;

        await ctx.execute(
          Sql.named('INSERT INTO user_roles (user_id, role_id, created_by, updated_by) VALUES (@userId, @roleId, @creatorId, @creatorId)'),
          parameters: {
            'userId': newUserId,
            'roleId': roleId,
            'creatorId': finalCreatorId,
          },
        );
      }

      // 4. Вернуть созданного пользователя со всей информацией
      final createdUserResult = await ctx.execute(
        Sql.named('SELECT * FROM users WHERE id = @id'),
        parameters: {'id': newUserId},
      );
      final userMap = createdUserResult.first.toColumnMap();
      final roles = await getRolesForUser(newUserId, ctx);
      final newUser = User.fromMap(userMap).copyWith(roles: roles);
      return newUser;
    });
  }

  // Обновить роли пользователя
  Future<void> updateUserRoles(int userId, List<int> newRoleIds) async {
    final conn = await connection;
    await conn.runTx((ctx) async {
      // Удаляем все текущие роли пользователя
      await ctx.execute(
        Sql.named('DELETE FROM user_roles WHERE user_id = @userId'),
        parameters: {'userId': userId},
      );

      // Добавляем новые роли
      for (final roleId in newRoleIds) {
        await ctx.execute(
          Sql.named('INSERT INTO user_roles (user_id, role_id) VALUES (@userId, @roleId)'),
          parameters: {'userId': userId, 'roleId': roleId},
        );
      }
    });
  }

  // Обновить пользователя
  Future<User?> updateUser(
      int id, {
        String? email,
        String? firstName,
        String? lastName,
        String? middleName,
        String? phone,
        String? gender,
        DateTime? dateOfBirth,
        int? updatedBy,
      }) async {
    try {
      final conn = await connection;

      final setParts = <String>[];
      final parameters = <String, dynamic>{'id': id};

      if (email != null) {
        setParts.add('email = @email');
        parameters['email'] = email;
      }
      if (firstName != null) {
        setParts.add('first_name = @firstName');
        parameters['firstName'] = firstName;
      }
      if (lastName != null) {
        setParts.add('last_name = @lastName');
        parameters['lastName'] = lastName;
      }
      if (middleName != null) {
        setParts.add('middle_name = @middleName');
        parameters['middleName'] = middleName;
      }
      if (phone != null) {
        setParts.add('phone = @phone');
        parameters['phone'] = phone;
      }
      if (gender != null) {
        // В базе gender хранится как SMALLINT, 0 для мужского, 1 для женского
        setParts.add('gender = @gender');
        parameters['gender'] = gender == 'мужской' ? 0 : 1;
      }
      if (dateOfBirth != null) {
        setParts.add('date_of_birth = @dateOfBirth');
        parameters['dateOfBirth'] = dateOfBirth;
      }

      if (setParts.isEmpty) {
        return getUserById(id);
      }

      setParts.add('updated_at = @updatedAt');
      parameters['updatedAt'] = DateTime.now();
      if (updatedBy != null) {
        setParts.add('updated_by = @updatedBy');
        parameters['updatedBy'] = updatedBy;
      }

      final sql = '''
        UPDATE users 
        SET ${setParts.join(', ')}
        WHERE id = @id
      ''';

      await conn.execute(
        Sql.named(sql),
        parameters: parameters,
      );

      return await getUserById(id);
    } catch (e) {
      print('❌ updateUser error: $e');
      rethrow;
    }
  }

  // Удалить пользователя
  Future<bool> deleteUser(int id) async {
    try {
      final conn = await connection;

      final sql = '''
        UPDATE users
        SET archived_at = NOW()
        WHERE id = @id
      ''';

      final results = await conn.execute(
        Sql.named(sql),
        parameters: {
          'id': id,
        },
      );

      return results.affectedRows > 0;
    } catch (e) {
      print('❌ deleteUser error: $e');
      rethrow;
    }
  }

  // Получить клиентов для менеджера
  Future<List<User>> getClientsForManager(int managerId) async {
    try {
      final conn = await connection;
      final results = await conn.execute(
        Sql.named('''
          SELECT 
            u.id, u.email, u.password_hash, u.first_name, u.last_name, r.name as role, u.phone, u.created_at, u.updated_at
          FROM users u
          LEFT JOIN user_roles ur ON u.id = ur.user_id
          LEFT JOIN roles r ON ur.role_id = r.id
          INNER JOIN manager_clients mc ON u.id = mc.client_id
          WHERE mc.manager_id = @managerId
          ORDER BY u.last_name, u.first_name
        '''),
        parameters: {'managerId': managerId},
      );
      return results.map((row) => User.fromMap(row.toColumnMap())).toList();
    } catch (e) {
      print('❌ getClientsForManager error: $e');
      rethrow;
    }
  }

  // Назначить клиентов менеджеру
  Future<void> assignClientsToManager(int managerId, List<int> clientIds) async {
    final conn = await connection;
    await conn.execute('BEGIN');
    try {
      // Удаляем старые назначения
      await conn.execute(
        Sql.named('DELETE FROM manager_clients WHERE manager_id = @managerId'),
        parameters: {'managerId': managerId},
      );

      // Добавляем новые назначения
      if (clientIds.isNotEmpty) {
        for (final clientId in clientIds) {
          await conn.execute(
            Sql.named('INSERT INTO manager_clients (manager_id, client_id) VALUES (@managerId, @clientId)'),
            parameters: {'managerId': managerId, 'clientId': clientId},
          );
        }
      }
      await conn.execute('COMMIT');
    } catch (e) {
      await conn.execute('ROLLBACK');
      print('❌ assignClientsToManager error: $e');
      rethrow;
    }
  }

  // Получить ID назначенных клиентов для менеджера
  Future<List<int>> getAssignedClientIds(int managerId) async {
    try {
      final conn = await connection;
      final results = await conn.execute(
        Sql.named('SELECT client_id FROM manager_clients WHERE manager_id = @managerId'),
        parameters: {'managerId': managerId},
      );
      return results.map((row) => row[0] as int).toList();
    } catch (e) {
      print('❌ getAssignedClientIds error: $e');
      rethrow;
    }
  }

  // Получить инструкторов для менеджера
  Future<List<User>> getInstructorsForManager(int managerId) async {
    try {
      final conn = await connection;
      final results = await conn.execute(
        Sql.named('''
          SELECT 
            u.id, u.email, u.password_hash, u.first_name, u.last_name, r.name as role, u.phone, u.created_at, u.updated_at
          FROM users u
          INNER JOIN user_roles ur ON u.id = ur.user_id
          INNER JOIN roles r ON ur.role_id = r.id
          INNER JOIN manager_instructors mi ON u.id = mi.instructor_id
          WHERE mi.manager_id = @managerId AND r.name = 'instructor'
          ORDER BY u.last_name, u.first_name
        '''),
        parameters: {'managerId': managerId},
      );
      return results.map((row) => User.fromMap(row.toColumnMap())).toList();
    } catch (e) {
      print('❌ getInstructorsForManager error: $e');
      rethrow;
    }
  }

  // Получить тренеров для менеджера
  Future<List<User>> getTrainersForManager(int managerId) async {
    try {
      final conn = await connection;
      final results = await conn.execute(
        Sql.named('''
          SELECT 
            u.id, u.email, u.password_hash, u.first_name, u.last_name, r.name as role, u.phone, u.created_at, u.updated_at
          FROM users u
          INNER JOIN user_roles ur ON u.id = ur.user_id
          INNER JOIN roles r ON ur.role_id = r.id
          INNER JOIN manager_trainers mt ON u.id = mt.trainer_id
          WHERE mt.manager_id = @managerId AND r.name = 'trainer'
          ORDER BY u.last_name, u.first_name
        '''),
        parameters: {'managerId': managerId},
      );
      return results.map((row) => User.fromMap(row.toColumnMap())).toList();
    } catch (e) {
      print('❌ getTrainersForManager error: $e');
      rethrow;
    }
  }

  // Назначить инструкторов менеджеру
  Future<void> assignInstructorsToManager(int managerId, List<int> instructorIds) async {
    final conn = await connection;
    await conn.execute('BEGIN');
    try {
      // Удаляем старые назначения
      await conn.execute(
        Sql.named('DELETE FROM manager_instructors WHERE manager_id = @managerId'),
        parameters: {'managerId': managerId},
      );

      // Добавляем новые назначения
      if (instructorIds.isNotEmpty) {
        for (final instructorId in instructorIds) {
          await conn.execute(
            Sql.named('INSERT INTO manager_instructors (manager_id, instructor_id) VALUES (@managerId, @instructorId)'),
            parameters: {'managerId': managerId, 'instructorId': instructorId},
          );
        }
      }
      await conn.execute('COMMIT');
    } catch (e) {
      await conn.execute('ROLLBACK');
      print('❌ assignInstructorsToManager error: $e');
      rethrow;
    }
  }

  // Получить ID назначенных инструкторов для менеджера
  Future<List<int>> getAssignedInstructorIds(int managerId) async {
    try {
      final conn = await connection;
      final results = await conn.execute(
        Sql.named('SELECT instructor_id FROM manager_instructors WHERE manager_id = @managerId'),
        parameters: {'managerId': managerId},
      );
      return results.map((row) => row[0] as int).toList();
    } catch (e) {
      print('❌ getAssignedInstructorIds error: $e');
      rethrow;
    }
  }

  // Назначить тренеров менеджеру
  Future<void> assignTrainersToManager(int managerId, List<int> trainerIds) async {
    final conn = await connection;
    await conn.execute('BEGIN');
    try {
      // Удаляем старые назначения
      await conn.execute(
        Sql.named('DELETE FROM manager_trainers WHERE manager_id = @managerId'),
        parameters: {'managerId': managerId},
      );

      // Добавляем новые назначения
      if (trainerIds.isNotEmpty) {
        for (final trainerId in trainerIds) {
          await conn.execute(
            Sql.named('INSERT INTO manager_trainers (manager_id, trainer_id) VALUES (@managerId, @trainerId)'),
            parameters: {'managerId': managerId, 'trainerId': trainerId},
          );
        }
      }
      await conn.execute('COMMIT');
    } catch (e) {
      await conn.execute('ROLLBACK');
      print('❌ assignTrainersToManager error: $e');
      rethrow;
    }
  }

  // Получить ID назначенных тренеров для менеджера
  Future<List<int>> getAssignedTrainerIds(int managerId) async {
    try {
      final conn = await connection;
      final results = await conn.execute(
        Sql.named('SELECT trainer_id FROM manager_trainers WHERE manager_id = @managerId'),
        parameters: {'managerId': managerId},
      );
      return results.map((row) => row[0] as int).toList();
    } catch (e) {
      print('❌ getAssignedTrainerIds error: $e');
      rethrow;
    }
  }

  // Получить клиентов для инструктора
  Future<List<User>> getClientsForInstructor(int instructorId) async {
    try {
      final conn = await connection;
      final results = await conn.execute(
        Sql.named('''
          SELECT 
            u.id, u.email, u.password_hash, u.first_name, u.last_name, r.name as role, u.phone, u.created_at, u.updated_at
          FROM users u
          LEFT JOIN user_roles ur ON u.id = ur.user_id
          LEFT JOIN roles r ON ur.role_id = r.id
          INNER JOIN instructor_clients ic ON u.id = ic.client_id
          WHERE ic.instructor_id = @instructorId
          ORDER BY u.last_name, u.first_name
        '''),
        parameters: {'instructorId': instructorId},
      );
      return results.map((row) => User.fromMap(row.toColumnMap())).toList();
    } catch (e) {
      print('❌ getClientsForInstructor error: $e');
      rethrow;
    }
  }

  // Получить тренеров для инструктора
  Future<List<User>> getTrainersForInstructor(int instructorId) async {
    try {
      final conn = await connection;
      final results = await conn.execute(
        Sql.named('''
          SELECT DISTINCT ON (t.id)
            t.id, t.email, t.password_hash, t.first_name, t.last_name, r.name as role, t.phone, t.created_at, t.updated_at
          FROM users t 
          LEFT JOIN user_roles ur ON t.id = ur.user_id
          LEFT JOIN roles r ON ur.role_id = r.id
          INNER JOIN lessons l ON t.id = l.trainer_id 
          WHERE l.instructor_id = @instructorId
        '''),
        parameters: {'instructorId': instructorId},
      );
      return results.map((row) => User.fromMap(row.toColumnMap())).toList();
    } catch (e) {
      print('❌ getTrainersForInstructor error: $e');
      rethrow;
    }
  }

  // Получить менеджера для инструктора
  Future<User?> getManagerForInstructor(int instructorId) async {
    try {
      final conn = await connection;
      final results = await conn.execute(
        Sql.named('''
          SELECT
            u.id, u.email, u.password_hash, u.first_name, u.last_name, r.name as role, u.phone, u.created_at, u.updated_at
          FROM users u 
          LEFT JOIN user_roles ur ON u.id = ur.user_id
          LEFT JOIN roles r ON ur.role_id = r.id
          INNER JOIN manager_instructors mi ON u.id = mi.manager_id 
          WHERE mi.instructor_id = @instructorId
          LIMIT 1
        '''),
        parameters: {'instructorId': instructorId},
      );
      if (results.isEmpty) return null;
      return User.fromMap(results.first.toColumnMap());
    } catch (e) {
      print('❌ getManagerForInstructor error: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getScheduleForUser(int userId, String role) async {
    try {
      final conn = await connection;
      String userColumn;
      switch (role) {
        case 'instructor':
          userColumn = 'l.instructor_id';
          break;
        case 'trainer':
          userColumn = 'l.trainer_id';
          break;
        case 'client':
          userColumn = 'l.client_id';
          break;
        default:
          return [];
      }

      final results = await conn.execute(
        Sql.named('''
          SELECT 
            l.id,
            tpt.name as training_plan_name,
            l.start_plan_at as start_time,
            l.finish_plan_at as end_time,
            l.complete as status,
            (SELECT u.first_name || \' \' || u.last_name FROM users u WHERE u.id = l.trainer_id) as trainer_name
          FROM lessons l
          LEFT JOIN client_training_plans ctp ON l.client_training_plan_id = ctp.id
          LEFT JOIN training_plan_templates tpt ON ctp.training_plan_template_id = tpt.id
          WHERE $userColumn = @userId
          ORDER BY l.start_plan_at ASC
        '''),
        parameters: {'userId': userId},
      );

      return results.map((row) {
        final rowMap = row.toColumnMap();
        return {
          'id': rowMap['id'],
          'training_plan_name': rowMap['training_plan_name'] ?? 'Без названия',
          'start_time': (rowMap['start_time'] as DateTime).toIso8601String(),
          'end_time': (rowMap['end_time'] as DateTime).toIso8601String(),
          'status': _statusToString(rowMap['status']),
          'trainer_name': rowMap['trainer_name'] ?? 'Не назначен',
        };
      }).toList();
    } catch (e) {
      print('❌ getScheduleForUser error: $e');
      rethrow;
    }
  }

  String _statusToString(dynamic status) {
    if (status is! int) return 'unknown';
    switch (status) {
      case 0:
        return 'scheduled';
      case 1:
        return 'completed';
      case 2:
        return 'canceled';
      default:
        return 'unknown';
    }
  }

  // Получить тренера для клиента
  Future<User?> getTrainerForClient(int clientId) async {
    // TODO: Implement actual database query
    print('Fetching trainer for client $clientId');
    // Placeholder implementation
    return User(
      id: 2,
      email: 'trainer@example.com',
      passwordHash: '',
      firstName: 'Иван',
      lastName: 'Петров',
      roles: [], // Added roles
      phone: '+7 999 123-45-67',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Получить инструктора для клиента
  Future<User?> getInstructorForClient(int clientId) async {
    // TODO: Implement actual database query
    print('Fetching instructor for client $clientId');
    // Placeholder implementation
    return User(
      id: 3,
      email: 'instructor@example.com',
      passwordHash: '',
      firstName: 'Анна',
      lastName: 'Сидорова',
      roles: [], // Added roles
      phone: '+7 999 765-43-21',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Получить менеджера для клиента
  Future<User?> getManagerForClient(int clientId) async {
    // TODO: Implement actual database query
    print('Fetching manager for client $clientId');
    // Placeholder implementation
    return User(
      id: 4,
      email: 'manager@example.com',
      passwordHash: '',
      firstName: 'Елена',
      lastName: 'Иванова',
      roles: [], // Added roles
      phone: '+7 999 111-22-33',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Обновить пароль пользователя
  Future<void> updateUserPassword(int userId, String newPasswordHash) async {
    try {
      final conn = await connection;
      await conn.execute(
        Sql.named('''
          UPDATE users
          SET password_hash = @passwordHash, updated_at = @updatedAt
          WHERE id = @userId
        '''),
        parameters: {
          'passwordHash': newPasswordHash,
          'updatedAt': DateTime.now(),
          'userId': userId,
        },
      );
    } catch (e) {
      print('❌ updateUserPassword error: $e');
      rethrow;
    }
  }

  // Обновить URL фото пользователя
  Future<void> updateUserPhotoUrl(int userId, String photoUrl, int updaterId) async {
    try {
      final conn = await connection;
      await conn.execute(
        Sql.named('''
          UPDATE users
          SET photo_url = @photoUrl, updated_at = NOW(), updated_by = @updaterId
          WHERE id = @userId
        '''),
        parameters: {
          'photoUrl': photoUrl,
          'updaterId': updaterId,
          'userId': userId,
        },
      );
    } catch (e) {
      print('❌ updateUserPhotoUrl error: $e');
      rethrow;
    }
  }

  // Получить данные антропометрии для клиента
  Future<Map<String, dynamic>> getAnthropometryData(int clientId) async {
    try {
      final conn = await connection;
      final fixedResult = await conn.execute(
        Sql.named('SELECT * FROM anthropometry_fix WHERE user_id = @clientId'),
        parameters: {'clientId': clientId},
      );
      final startResult = await conn.execute(
        Sql.named('SELECT *, profile_photo, profile_photo_date_time FROM anthropometry_start WHERE user_id = @clientId'),
        parameters: {'clientId': clientId},
      );
      final finishResult = await conn.execute(
        Sql.named('SELECT *, profile_photo, profile_photo_date_time FROM anthropometry_finish WHERE user_id = @clientId'),
        parameters: {'clientId': clientId},
      );

      final fixedData = fixedResult.isNotEmpty ? _convertDateTimeToString(fixedResult.first.toColumnMap()) : {};
      final startData = startResult.isNotEmpty ? _convertDateTimeToString(startResult.first.toColumnMap()) : {};
      final finishData = finishResult.isNotEmpty ? _convertDateTimeToString(finishResult.first.toColumnMap()) : {};

      print('[getAnthropometryData] startData: $startData');
      print('[getAnthropometryData] finishData: $finishData');

      return {
        'fixed': fixedData,
        'start': startData,
        'finish': finishData,
      };
    } catch (e) {
      print('❌ getAnthropometryData error: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _convertDateTimeToString(Map<String, dynamic> map) {
    final newMap = <String, dynamic>{};
    map.forEach((key, value) {
      if (value is DateTime) {
        newMap[key] = value.toIso8601String();
      } else {
        newMap[key] = value;
      }
    });
    return newMap;
  }

  Future<void> updateAnthropometryPhoto(int clientId, String photoUrl, String type, DateTime? photoDateTime, int creatorId) async {
    try {
      final conn = await connection;
      String tableName;
      String photoColumn;
      String photoDateTimeColumn;

      switch (type) {
        case 'start_front':
          tableName = 'anthropometry_start';
          photoColumn = 'photo';
          photoDateTimeColumn = 'photo_date_time';
          break;
        case 'finish_front':
          tableName = 'anthropometry_finish';
          photoColumn = 'photo';
          photoDateTimeColumn = 'photo_date_time';
          break;
        case 'start_profile':
          tableName = 'anthropometry_start';
          photoColumn = 'profile_photo';
          photoDateTimeColumn = 'profile_photo_date_time';
          break;
        case 'finish_profile':
          tableName = 'anthropometry_finish';
          photoColumn = 'profile_photo';
          photoDateTimeColumn = 'profile_photo_date_time';
          break;
        default:
          throw ArgumentError('Invalid photo type: $type');
      }

      await conn.execute(
        Sql.named('''
          INSERT INTO $tableName (user_id, $photoColumn, $photoDateTimeColumn, created_by, updated_by)
          VALUES (@clientId, @photoUrl, @photoDateTime, @creatorId, @creatorId)
          ON CONFLICT (user_id) DO UPDATE
          SET $photoColumn = @photoUrl, $photoDateTimeColumn = @photoDateTime, updated_at = NOW(), updated_by = @creatorId
        '''),
        parameters: {
          'photoUrl': photoUrl,
          'clientId': clientId,
          'photoDateTime': photoDateTime ?? DateTime.now(),
          'creatorId': creatorId,
        },
      );
    } catch (e) {
      print('❌ updateAnthropometryPhoto error: $e');
      rethrow;
    }
  }

  Future<void> updateAnthropometryFixed(
    int clientId,
    int? height,
    int? wristCirc,
    int? ankleCirc,
    int creatorId,
  ) async {
    try {
      final conn = await connection;
      await conn.execute(
        Sql.named('''
          INSERT INTO anthropometry_fix (user_id, height, wrist_circ, ankle_circ, created_by, updated_by)
          VALUES (@clientId, @height, @wristCirc, @ankleCirc, @creatorId, @creatorId)
          ON CONFLICT (user_id) DO UPDATE
          SET 
            height = @height,
            wrist_circ = @wristCirc,
            ankle_circ = @ankleCirc,
            updated_at = NOW(),
            updated_by = @creatorId
        '''),
        parameters: {
          'clientId': clientId,
          'height': height,
          'wristCirc': wristCirc,
          'ankleCirc': ankleCirc,
          'creatorId': creatorId,
        },
      );
    } catch (e) {
      print('❌ updateAnthropometryFixed error: $e');
      rethrow;
    }
  }

  Future<void> updateAnthropometryMeasurements(
    int clientId,
    String type, // 'start' or 'finish'
    double? weight,
    int? shouldersCirc,
    int? breastCirc,
    int? waistCirc,
    int? hipsCirc,
    int creatorId,
  ) async {
    try {
      final conn = await connection;
      final tableName = type == 'start' ? 'anthropometry_start' : 'anthropometry_finish';
      final now = DateTime.now();
      await conn.execute(
        Sql.named('''
          INSERT INTO $tableName (user_id, weight, shoulders_circ, breast_circ, waist_circ, hips_circ, date_time, created_by, updated_by)
          VALUES (@clientId, @weight, @shouldersCirc, @breastCirc, @waistCirc, @hipsCirc, @now, @creatorId, @creatorId)
          ON CONFLICT (user_id) DO UPDATE
          SET 
            weight = @weight,
            shoulders_circ = @shouldersCirc,
            breast_circ = @breastCirc,
            waist_circ = @waistCirc,
            hips_circ = @hipsCirc,
            date_time = @now,
            updated_at = NOW(),
            updated_by = @creatorId
        '''),
        parameters: {
          'clientId': clientId,
          'weight': weight,
          'shouldersCirc': shouldersCirc,
          'breastCirc': breastCirc,
          'waistCirc': waistCirc,
          'hipsCirc': hipsCirc,
          'now': now,
          'creatorId': creatorId,
        },
      );
    } catch (e) {
      print('❌ updateAnthropometryMeasurements error: $e');
      rethrow;
    }
  }

  // Получить данные отслеживания калорий для клиента
  Future<List<Map<String, dynamic>>> getCalorieTrackingData(int clientId) async {
    // TODO: Implement actual database query
    print('Fetching calorie tracking data for client $clientId');
    // Placeholder implementation
    return [
      {
        'date': '2025-10-27T18:00:00',
        'training': 'Тренировка 1',
        'consumed': 2200,
        'burned': 2500,
        'balance': -300,
      },
      {
        'date': '2025-10-29T18:00:00',
        'training': 'Тренировка 2',
        'consumed': 2400,
        'burned': 2100,
        'balance': 300,
      },
    ];
  }

  // Получить данные прогресса для клиента
  Future<Map<String, dynamic>> getProgressData(int clientId) async {
    // TODO: Implement actual database query
    print('Fetching progress data for client $clientId');
    // Placeholder implementation
    return {
      'weight': [
        {'date': '2025-10-01', 'value': 85},
        {'date': '2025-10-08', 'value': 84},
        {'date': '2025-10-15', 'value': 82},
        {'date': '2025-10-22', 'value': 83},
        {'date': '2025-10-29', 'value': 81},
      ],
      'calories': [
        {'date': '2025-10-01', 'value': 2200},
        {'date': '2025-10-08', 'value': 2100},
        {'date': '2025-10-15', 'value': 2000},
        {'date': '2025-10-22', 'value': 2300},
        {'date': '2025-10-29', 'value': 2050},
      ],
      'balance': [
        {'date': '2025-10-01', 'value': -300},
        {'date': '2025-10-08', 'value': 100},
        {'date': '2025-10-15', 'value': -500},
        {'date': '2025-10-22', 'value': 200},
        {'date': '2025-10-29', 'value': -150},
      ],
      'kpi': {
        'avgWeight': 82.2,
        'weightChange': -2.8,
        'avgCalories': 2130,
      },
      'recommendations': 'Ваш прогресс замедлился. Попробуйте добавить больше кардио-упражнений и следите за потреблением углеводов.',
    };
  }

  // Инициализация базы данных (создание таблиц если не существуют)
  Future<void> initializeDatabase() async {
    try {
      final conn = await connection;

      // Создаем таблицу roles, если не существует
      await conn.execute('''
        CREATE TABLE IF NOT EXISTS roles (
            id BIGSERIAL PRIMARY KEY,
            name VARCHAR(255) UNIQUE NOT NULL,
            title VARCHAR(255) NOT NULL,
            icon VARCHAR(255),
            company_id BIGINT DEFAULT -1,
            created_at TIMESTAMPTZ DEFAULT NOW(),
            updated_at TIMESTAMPTZ DEFAULT NOW(),
            created_by BIGINT,
            updated_by BIGINT,
            archived_at TIMESTAMPTZ,
            archived_by BIGINT
        );
      ''');

      // Создаем таблицу users, если не существует
      await conn.execute('''
        CREATE TABLE IF NOT EXISTS users (
            id BIGSERIAL PRIMARY KEY,
            login VARCHAR(255) UNIQUE NOT NULL,
            password_hash VARCHAR(255) NOT NULL,
            email VARCHAR(255) UNIQUE,
            phone VARCHAR(255) UNIQUE,
            last_name VARCHAR(255),
            first_name VARCHAR(255),
            middle_name VARCHAR(255),
            gender SMALLINT,
            date_of_birth DATE,
            photo_url VARCHAR(255),
            company_id BIGINT DEFAULT -1,
            created_at TIMESTAMPTZ DEFAULT NOW(),
            updated_at TIMESTAMPTZ DEFAULT NOW(),
            created_by BIGINT,
            updated_by BIGINT,
            archived_at TIMESTAMPTZ,
            archived_by BIGINT
        );
      ''');

      // Создаем таблицу user_roles, если не существует
      await conn.execute('''
        CREATE TABLE IF NOT EXISTS user_roles (
            user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
            role_id BIGINT NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
            assigned_at TIMESTAMPTZ DEFAULT NOW(),
            company_id BIGINT DEFAULT -1,
            created_at TIMESTAMPTZ DEFAULT NOW(),
            updated_at TIMESTAMPTZ DEFAULT NOW(),
            created_by BIGINT,
            updated_by BIGINT,
            archived_at TIMESTAMPTZ,
            archived_by BIGINT,
            PRIMARY KEY (user_id, role_id)
        );
      ''');

      // Добавляем начальные роли, если их нет
      await conn.execute('''
        INSERT INTO roles (name, title)
        VALUES 
            ('client', 'Клиент'),
            ('instructor', 'Инструктор'),
            ('trainer', 'Тренер'),
            ('manager', 'Менеджер'),
            ('admin', 'Администратор')
        ON CONFLICT (name) DO NOTHING;
      ''');

      // Остальные таблицы (с исправленными типами FK)
      await conn.execute('''
        CREATE TABLE IF NOT EXISTS manager_profiles (
          user_id BIGINT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
          specialization VARCHAR(255),
          work_experience INTEGER,
          is_duty BOOLEAN DEFAULT false
        )
      ''');

      await conn.execute('''
        CREATE TABLE IF NOT EXISTS manager_clients (
          manager_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
          client_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
          PRIMARY KEY (manager_id, client_id)
        )
      ''');

      await conn.execute('''
        CREATE TABLE IF NOT EXISTS manager_instructors (
          manager_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
          instructor_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
          PRIMARY KEY (manager_id, instructor_id)
        )
      ''');

      await conn.execute('''
        CREATE TABLE IF NOT EXISTS manager_trainers (
          manager_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
          trainer_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
          PRIMARY KEY (manager_id, trainer_id)
        )
      ''');

      await conn.execute('''
        CREATE TABLE IF NOT EXISTS instructor_clients (
          instructor_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
          client_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
          PRIMARY KEY (instructor_id, client_id)
        )
      ''');

      await conn.execute('''
        CREATE TABLE IF NOT EXISTS exercises_templates (
          id SERIAL PRIMARY KEY,
          name VARCHAR(100) NOT NULL,
          repeat_qty INTEGER,
          duration_exec REAL,
          duration_rest REAL,
          calories_out REAL,
          is_group BOOLEAN DEFAULT false,
          type_exercis_id INTEGER, -- Связь с каталогом типов упражнений
          note VARCHAR(255),
          created_at TIMESTAMP DEFAULT NOW(),
          updated_at TIMESTAMP DEFAULT NOW()
        )
      ''');

      await conn.execute('''
        CREATE TABLE IF NOT EXISTS lessons (
          id SERIAL PRIMARY KEY,
          schedule_id BIGINT,
          client_training_plan_id BIGINT,
          set_exercises_id BIGINT,
          client_id BIGINT REFERENCES users(id),
          instructor_id BIGINT REFERENCES users(id),
          trainer_id BIGINT REFERENCES users(id),
          start_plan_at TIMESTAMP,
          start_fact_at TIMESTAMP,
          finish_plan_at TIMESTAMP,
          finish_fact_at TIMESTAMP,
          complete INTEGER,
          note VARCHAR(100)
        )
      ''');

      await conn.execute('''
        CREATE TABLE IF NOT EXISTS goals_training (
          id SERIAL PRIMARY KEY,
          name VARCHAR(20) NOT NULL
        )
      ''');

      await conn.execute('''
        CREATE TABLE IF NOT EXISTS training_plan_templates (
          id SERIAL PRIMARY KEY,
          name VARCHAR(100) NOT NULL,
          goal_training_id BIGINT REFERENCES goals_training(id)
        )
      ''');

      await conn.execute('''
        CREATE TABLE IF NOT EXISTS client_training_plans (
          id SERIAL PRIMARY KEY,
          client_id BIGINT REFERENCES users(id),
          training_plan_template_id BIGINT REFERENCES training_plan_templates(id),
          assigned_by BIGINT REFERENCES users(id),
          assigned_at TIMESTAMP,
          is_active BOOLEAN,
          goal VARCHAR,
          notes TEXT
        )
      ''');

      await conn.execute('''
        CREATE TABLE IF NOT EXISTS work_schedules (
            id BIGSERIAL PRIMARY KEY,
            day_of_week INT NOT NULL UNIQUE,
            start_time TIME NOT NULL,
            end_time TIME NOT NULL,
            is_day_off BOOLEAN DEFAULT false,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            created_by BIGINT,
            updated_by BIGINT,
            archived_at TIMESTAMP WITH TIME ZONE,
            archived_by BIGINT,
            company_id BIGINT DEFAULT -1
        )
      ''');

      await conn.execute('''
        CREATE TABLE IF NOT EXISTS anthropometry_fix (
            user_id BIGINT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
            date_time TIMESTAMPTZ DEFAULT NOW(),
            height INT,
            wrist_circ INT,
            ankle_circ INT
        );
      ''');

      await conn.execute('''
        CREATE TABLE IF NOT EXISTS anthropometry_start (
            user_id BIGINT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
            date_time TIMESTAMPTZ DEFAULT NOW(),
            photo VARCHAR(255),
            weight REAL,
            shoulders_circ INT,
            breast_circ INT,
            waist_circ INT,
            hips_circ INT,
            bmr INT
        );
      ''');

      await conn.execute('''
        CREATE TABLE IF NOT EXISTS anthropometry_finish (
            user_id BIGINT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
            date_time TIMESTAMPTZ DEFAULT NOW(),
            photo VARCHAR(255),
            weight REAL,
            shoulders_circ INT,
            breast_circ INT,
            waist_circ INT,
            hips_circ INT,
            bmr INT
        );
      ''');

      //print('✅ Database tables initialized');
    } catch (e) {
      print('❌ Database initialization error: $e');
      rethrow;
    }
  }
}