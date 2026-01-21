import 'package:freezed_annotation/freezed_annotation.dart';

part 'building.model.freezed.dart';
part 'building.model.g.dart';

class NullableDateTimeConverter implements JsonConverter<DateTime?, String?> {
  const NullableDateTimeConverter();

  @override
  DateTime? fromJson(String? json) => json == null ? null : DateTime.parse(json);

  @override
  String? toJson(DateTime? object) => object?.toIso8601String();
}

@freezed
class Building with _$Building {
  const factory Building({
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'address') required String address,
    @JsonKey(name: 'note') String? note,
    @NullableDateTimeConverter() @JsonKey(name: 'created_at') DateTime? createdAt,
    @NullableDateTimeConverter() @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'created_by') String? createdBy,
    @JsonKey(name: 'updated_by') String? updatedBy,
    @NullableDateTimeConverter() @JsonKey(name: 'archived_at') DateTime? archivedAt,
    @JsonKey(name: 'archived_by') String? archivedBy,
    @JsonKey(name: 'archived_by_name') String? archivedByName,
  }) = _Building;

  factory Building.fromJson(Map<String, dynamic> json) => _$BuildingFromJson(json);
}
