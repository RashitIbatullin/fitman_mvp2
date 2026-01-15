import 'package:freezed_annotation/freezed_annotation.dart';

part 'building.model.freezed.dart';
part 'building.model.g.dart';

@freezed
class Building with _$Building {
  const factory Building({
    required String id,
    required String name,
    required String address,
    String? note,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'archived_at') DateTime? archivedAt,
  }) = _Building;

  factory Building.fromJson(Map<String, dynamic> json) => _$BuildingFromJson(json);
}
