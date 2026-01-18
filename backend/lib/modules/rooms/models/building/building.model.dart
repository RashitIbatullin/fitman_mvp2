class Building {
  const Building({
    this.id,
    required this.name,
    required this.address,
    this.note,
    this.createdAt,
    this.updatedAt,
    this.archivedAt,
  });

  final String? id;
  final String name;
  final String address;
  final String? note;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? archivedAt;

  factory Building.fromMap(Map<String, dynamic> map) {
    return Building(
      id: map['id']?.toString(),
      name: map['name'] as String,
      address: map['address'] as String,
      note: map['note'] as String?,
      createdAt: map['created_at'] is DateTime
          ? map['created_at'] as DateTime
          : (map['created_at'] == null
              ? null
              : DateTime.parse(map['created_at'] as String)),
      updatedAt: map['updated_at'] is DateTime
          ? map['updated_at'] as DateTime
          : (map['updated_at'] == null
              ? null
              : DateTime.parse(map['updated_at'] as String)),
      archivedAt: map['archived_at'] is DateTime
          ? map['archived_at'] as DateTime
          : (map['archived_at'] == null
              ? null
              : DateTime.parse(map['archived_at'] as String)),
    );
  }

  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
      id: json['id'] as String?,
      name: json['name'] as String,
      address: json['address'] as String,
      note: json['note'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      archivedAt: json['archived_at'] == null
          ? null
          : DateTime.parse(json['archived_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'note': note,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'archived_at': archivedAt?.toIso8601String(),
    };
  }
}