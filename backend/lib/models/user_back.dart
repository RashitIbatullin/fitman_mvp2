import 'role.dart';

class User {
  final int id;
  final String email;
  final String passwordHash;
  final String firstName;
  final String lastName;
  final String? middleName;
  final String? photoUrl; // <-- ДОБАВЛЕНО
  final List<Role> roles;
  final String? phone;
  final String? gender;
  final DateTime? dateOfBirth;
  final DateTime createdAt;
  final DateTime updatedAt;

  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  User({
    required this.id,
    required this.email,
    required this.passwordHash,
    required this.firstName,
    required this.lastName,
    this.middleName,
    this.photoUrl, // <-- ДОБАВЛЕНО
    required this.roles,
    this.phone,
    this.gender,
    this.dateOfBirth,
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
      middleName: map['middle_name']?.toString(),
      photoUrl: map['photo_url']?.toString(), // <-- ДОБАВЛЕНО
      roles: [], // Roles will be fetched separately and populated
      phone: map['phone']?.toString(),
      gender: map['gender'] != null ? (map['gender'] == 0 ? 'мужской' : 'женский') : null,
      dateOfBirth: map['date_of_birth'] is DateTime
          ? map['date_of_birth']
          : (map['date_of_birth'] != null ? DateTime.parse(map['date_of_birth'].toString()) : null),
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
      'middleName': middleName,
      'photo_url': photoUrl, // <-- ДОБАВЛЕНО
      'roles': roles.map((r) => r.toJson()).toList(),
      'phone': phone,
      'gender': gender,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
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
      'middleName': middleName,
      'photo_url': photoUrl, // <-- ДОБАВЛЕНО
      'roles': roles.map((r) => r.toJson()).toList(),
      'phone': phone,
      'gender': gender,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? firstName,
    String? lastName,
    String? middleName,
    String? photoUrl, // <-- ДОБАВЛЕНО
    String? phone,
    String? gender,
    DateTime? dateOfBirth,
    List<Role>? roles,
  }) {
    return User(
      id: id,
      email: email,
      passwordHash: passwordHash,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      middleName: middleName ?? this.middleName,
      photoUrl: photoUrl ?? this.photoUrl, // <-- ДОБАВЛЕЛЕНО
      roles: roles ?? this.roles,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
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
  final List<String> roles;
  final String? phone;
  final DateTime? dateOfBirth;

  CreateUserRequest({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.roles,
    this.phone,
    this.dateOfBirth,
  });

  factory CreateUserRequest.fromJson(Map<String, dynamic> json) {
    return CreateUserRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      roles: List<String>.from(json['roles'] as List),
      phone: json['phone'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
    );
  }
}