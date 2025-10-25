import 'role.dart';

class User {
  final int id;
  final String email;
  final String passwordHash;
  final String firstName;
  final String lastName;
  final List<Role> roles; // Changed from single role string to list of Role objects
  final String? phone;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.passwordHash,
    required this.firstName,
    required this.lastName,
    required this.roles, // Updated constructor
    this.phone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] is int ? map['id'] : int.parse(map['id'].toString()),
      email: map['email'].toString(),
      passwordHash: map['password_hash'].toString(),
      firstName: map['first_name'].toString(),
      lastName: map['last_name'].toString(),
      roles: [], // Roles will be fetched separately and populated
      phone: map['phone']?.toString(),
      createdAt: map['created_at'] is DateTime
          ? map['created_at']
          : DateTime.parse(map['created_at'].toString()),
      updatedAt: map['updated_at'] is DateTime
          ? map['updated_at']
          : DateTime.parse(map['updated_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'roles': roles.map((r) => r.toJson()).toList(), // Serialize roles
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toSafeJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'roles': roles.map((r) => r.toJson()).toList(), // Serialize roles
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? firstName,
    String? lastName,
    String? phone,
    List<Role>? roles, // Added roles to copyWith
  }) {
    return User(
      id: id,
      email: email,
      passwordHash: passwordHash,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      roles: roles ?? this.roles, // Updated roles in copyWith
      phone: phone ?? this.phone,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

class CreateUserRequest {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final List<String> roles; // Changed from single role string to list of role names
  final String? phone;

  CreateUserRequest({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.roles, // Updated constructor
    this.phone,
  });

  factory CreateUserRequest.fromJson(Map<String, dynamic> json) {
    return CreateUserRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      roles: List<String>.from(json['roles'] as List), // Deserialize roles
      phone: json['phone'] as String?,
    );
  }
}