import 'role.dart';

class User {
  final int id;
  final String email;
  final String passwordHash;
  final String firstName;
  final String lastName;
  final String? middleName;
  final String? photoUrl;
  final List<Role> roles;
  final String? phone;
  final String? gender;
  final DateTime? dateOfBirth;
  final bool sendNotification;
  final int hourNotification;
  final bool trackCalories;
  final double coeffActivity;
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
    this.photoUrl,
    required this.roles,
    this.phone,
    this.gender,
    this.dateOfBirth,
    this.sendNotification = true,
    this.hourNotification = 1,
    this.trackCalories = true,
    this.coeffActivity = 1.2,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      passwordHash: json['passwordHash'] ?? '',
      firstName: json['firstName'],
      lastName: json['lastName'],
      middleName: json['middleName'],
      photoUrl: json['photo_url'],
      roles:
          (json['roles'] as List<dynamic>?)
              ?.map((roleMap) => Role.fromJson(roleMap as Map<String, dynamic>))
              .toList() ??
          [],
      phone: json['phone'],
      gender: json['gender'],
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.parse(json['dateOfBirth']) : null,
      sendNotification: json['sendNotification'] ?? true,
      hourNotification: json['hourNotification'] ?? 1,
      trackCalories: json['trackCalories'] ?? true,
      coeffActivity: json['coeffActivity']?.toDouble() ?? 1.2,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'middleName': middleName,
      'photo_url': photoUrl,
      'phone': phone,
      'gender': gender,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'sendNotification': sendNotification,
      'hourNotification': hourNotification,
      'trackCalories': trackCalories,
      'coeffActivity': coeffActivity,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get fullName {
    if (middleName != null && middleName!.isNotEmpty) {
      return '$lastName $firstName $middleName';
    }
    return '$lastName $firstName';
  }

  String get shortName {
    final middleInitial = middleName != null && middleName!.isNotEmpty
        ? ' ${middleName![0]}.'
        : '';
    return '$lastName ${firstName[0]}.$middleInitial';
  }

  User copyWith({
    int? id,
    String? email,
    String? passwordHash,
    String? firstName,
    String? lastName,
    String? middleName,
    String? photoUrl,
    List<Role>? roles,
    String? phone,
    String? gender,
    DateTime? dateOfBirth,
    bool? sendNotification,
    int? hourNotification,
    bool? trackCalories,
    double? coeffActivity,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      middleName: middleName ?? this.middleName,
      photoUrl: photoUrl ?? this.photoUrl,
      roles: roles ?? this.roles,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      sendNotification: sendNotification ?? this.sendNotification,
      hourNotification: hourNotification ?? this.hourNotification,
      trackCalories: trackCalories ?? this.trackCalories,
      coeffActivity: coeffActivity ?? this.coeffActivity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class AuthResponse {
  final String token;
  final User user;

  AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

class CreateUserRequest {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? middleName;
  final List<String> roles;
  final String? phone;
  final String? gender;
  final DateTime? dateOfBirth;
  final bool sendNotification;
  final int hourNotification;
  final bool trackCalories;
  final double coeffActivity;

  CreateUserRequest({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.middleName,
    required this.roles,
    this.phone,
    this.gender,
    this.dateOfBirth,
    this.sendNotification = true,
    this.hourNotification = 1,
    this.trackCalories = true,
    this.coeffActivity = 1.2,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'middleName': middleName,
      'roles': roles,
      'phone': phone,
      'gender': gender,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'sendNotification': sendNotification,
      'hourNotification': hourNotification,
      'trackCalories': trackCalories,
      'coeffActivity': coeffActivity,
    };
  }
}

class UpdateUserRequest {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String? middleName;
  final String? phone;
  final String? gender;
  final DateTime? dateOfBirth;

  UpdateUserRequest({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.middleName,
    this.phone,
    this.gender,
    this.dateOfBirth,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'middleName': middleName,
      'phone': phone,
      'gender': gender,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
    };
  }
}
