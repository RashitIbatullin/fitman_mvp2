import 'package:json_annotation/json_annotation.dart';

part 'competency.g.dart';

@JsonSerializable()
class Competency {
  Competency({
    required this.id,
    required this.staffId,
    required this.name,
    required this.level,
    this.certificateUrl,
    this.verifiedAt,
    this.verifiedBy,
  });

  factory Competency.fromJson(Map<String, dynamic> json) =>
      _$CompetencyFromJson(json);

  @JsonKey(name: 'id')
  final int id;
  @JsonKey(name: 'staff_id')
  final int staffId;
  @JsonKey(name: 'name')
  final String name;
  @JsonKey(name: 'level')
  final int level;
  @JsonKey(name: 'certificate_url')
  final String? certificateUrl;
    @JsonKey(name: 'verified_at', fromJson: _dateTimeFromDb, toJson: _dateTimeToDb)
    final DateTime? verifiedAt;
    
    @JsonKey(name: 'verified_by')
    final int? verifiedBy;
  
    Map<String, dynamic> toJson() => _$CompetencyToJson(this);
  
    // Custom static methods for DateTime conversion
    static DateTime? _dateTimeFromDb(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString());
    }
  
    static dynamic _dateTimeToDb(DateTime? value) {
      return value?.toIso8601String();
    }
}