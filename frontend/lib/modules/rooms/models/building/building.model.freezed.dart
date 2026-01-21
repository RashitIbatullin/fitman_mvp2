// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'building.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Building _$BuildingFromJson(Map<String, dynamic> json) {
  return _Building.fromJson(json);
}

/// @nodoc
mixin _$Building {
  @JsonKey(name: 'id')
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'name')
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'address')
  String get address => throw _privateConstructorUsedError;
  @JsonKey(name: 'note')
  String? get note => throw _privateConstructorUsedError;
  @NullableDateTimeConverter()
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @NullableDateTimeConverter()
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_by')
  String? get createdBy => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_by')
  String? get updatedBy => throw _privateConstructorUsedError;
  @NullableDateTimeConverter()
  @JsonKey(name: 'archived_at')
  DateTime? get archivedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'archived_by')
  String? get archivedBy => throw _privateConstructorUsedError;
  @JsonKey(name: 'archived_by_name')
  String? get archivedByName => throw _privateConstructorUsedError;

  /// Serializes this Building to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Building
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BuildingCopyWith<Building> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BuildingCopyWith<$Res> {
  factory $BuildingCopyWith(Building value, $Res Function(Building) then) =
      _$BuildingCopyWithImpl<$Res, Building>;
  @useResult
  $Res call({
    @JsonKey(name: 'id') String id,
    @JsonKey(name: 'name') String name,
    @JsonKey(name: 'address') String address,
    @JsonKey(name: 'note') String? note,
    @NullableDateTimeConverter()
    @JsonKey(name: 'created_at')
    DateTime? createdAt,
    @NullableDateTimeConverter()
    @JsonKey(name: 'updated_at')
    DateTime? updatedAt,
    @JsonKey(name: 'created_by') String? createdBy,
    @JsonKey(name: 'updated_by') String? updatedBy,
    @NullableDateTimeConverter()
    @JsonKey(name: 'archived_at')
    DateTime? archivedAt,
    @JsonKey(name: 'archived_by') String? archivedBy,
    @JsonKey(name: 'archived_by_name') String? archivedByName,
  });
}

/// @nodoc
class _$BuildingCopyWithImpl<$Res, $Val extends Building>
    implements $BuildingCopyWith<$Res> {
  _$BuildingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Building
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? address = null,
    Object? note = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? createdBy = freezed,
    Object? updatedBy = freezed,
    Object? archivedAt = freezed,
    Object? archivedBy = freezed,
    Object? archivedByName = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            address: null == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String,
            note: freezed == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdBy: freezed == createdBy
                ? _value.createdBy
                : createdBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            updatedBy: freezed == updatedBy
                ? _value.updatedBy
                : updatedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            archivedAt: freezed == archivedAt
                ? _value.archivedAt
                : archivedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            archivedBy: freezed == archivedBy
                ? _value.archivedBy
                : archivedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            archivedByName: freezed == archivedByName
                ? _value.archivedByName
                : archivedByName // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BuildingImplCopyWith<$Res>
    implements $BuildingCopyWith<$Res> {
  factory _$$BuildingImplCopyWith(
    _$BuildingImpl value,
    $Res Function(_$BuildingImpl) then,
  ) = __$$BuildingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') String id,
    @JsonKey(name: 'name') String name,
    @JsonKey(name: 'address') String address,
    @JsonKey(name: 'note') String? note,
    @NullableDateTimeConverter()
    @JsonKey(name: 'created_at')
    DateTime? createdAt,
    @NullableDateTimeConverter()
    @JsonKey(name: 'updated_at')
    DateTime? updatedAt,
    @JsonKey(name: 'created_by') String? createdBy,
    @JsonKey(name: 'updated_by') String? updatedBy,
    @NullableDateTimeConverter()
    @JsonKey(name: 'archived_at')
    DateTime? archivedAt,
    @JsonKey(name: 'archived_by') String? archivedBy,
    @JsonKey(name: 'archived_by_name') String? archivedByName,
  });
}

/// @nodoc
class __$$BuildingImplCopyWithImpl<$Res>
    extends _$BuildingCopyWithImpl<$Res, _$BuildingImpl>
    implements _$$BuildingImplCopyWith<$Res> {
  __$$BuildingImplCopyWithImpl(
    _$BuildingImpl _value,
    $Res Function(_$BuildingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Building
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? address = null,
    Object? note = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? createdBy = freezed,
    Object? updatedBy = freezed,
    Object? archivedAt = freezed,
    Object? archivedBy = freezed,
    Object? archivedByName = freezed,
  }) {
    return _then(
      _$BuildingImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        address: null == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String,
        note: freezed == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdBy: freezed == createdBy
            ? _value.createdBy
            : createdBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        updatedBy: freezed == updatedBy
            ? _value.updatedBy
            : updatedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        archivedAt: freezed == archivedAt
            ? _value.archivedAt
            : archivedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        archivedBy: freezed == archivedBy
            ? _value.archivedBy
            : archivedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        archivedByName: freezed == archivedByName
            ? _value.archivedByName
            : archivedByName // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BuildingImpl implements _Building {
  const _$BuildingImpl({
    @JsonKey(name: 'id') required this.id,
    @JsonKey(name: 'name') required this.name,
    @JsonKey(name: 'address') required this.address,
    @JsonKey(name: 'note') this.note,
    @NullableDateTimeConverter() @JsonKey(name: 'created_at') this.createdAt,
    @NullableDateTimeConverter() @JsonKey(name: 'updated_at') this.updatedAt,
    @JsonKey(name: 'created_by') this.createdBy,
    @JsonKey(name: 'updated_by') this.updatedBy,
    @NullableDateTimeConverter() @JsonKey(name: 'archived_at') this.archivedAt,
    @JsonKey(name: 'archived_by') this.archivedBy,
    @JsonKey(name: 'archived_by_name') this.archivedByName,
  });

  factory _$BuildingImpl.fromJson(Map<String, dynamic> json) =>
      _$$BuildingImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final String id;
  @override
  @JsonKey(name: 'name')
  final String name;
  @override
  @JsonKey(name: 'address')
  final String address;
  @override
  @JsonKey(name: 'note')
  final String? note;
  @override
  @NullableDateTimeConverter()
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @NullableDateTimeConverter()
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @override
  @JsonKey(name: 'created_by')
  final String? createdBy;
  @override
  @JsonKey(name: 'updated_by')
  final String? updatedBy;
  @override
  @NullableDateTimeConverter()
  @JsonKey(name: 'archived_at')
  final DateTime? archivedAt;
  @override
  @JsonKey(name: 'archived_by')
  final String? archivedBy;
  @override
  @JsonKey(name: 'archived_by_name')
  final String? archivedByName;

  @override
  String toString() {
    return 'Building(id: $id, name: $name, address: $address, note: $note, createdAt: $createdAt, updatedAt: $updatedAt, createdBy: $createdBy, updatedBy: $updatedBy, archivedAt: $archivedAt, archivedBy: $archivedBy, archivedByName: $archivedByName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BuildingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.updatedBy, updatedBy) ||
                other.updatedBy == updatedBy) &&
            (identical(other.archivedAt, archivedAt) ||
                other.archivedAt == archivedAt) &&
            (identical(other.archivedBy, archivedBy) ||
                other.archivedBy == archivedBy) &&
            (identical(other.archivedByName, archivedByName) ||
                other.archivedByName == archivedByName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    address,
    note,
    createdAt,
    updatedAt,
    createdBy,
    updatedBy,
    archivedAt,
    archivedBy,
    archivedByName,
  );

  /// Create a copy of Building
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BuildingImplCopyWith<_$BuildingImpl> get copyWith =>
      __$$BuildingImplCopyWithImpl<_$BuildingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BuildingImplToJson(this);
  }
}

abstract class _Building implements Building {
  const factory _Building({
    @JsonKey(name: 'id') required final String id,
    @JsonKey(name: 'name') required final String name,
    @JsonKey(name: 'address') required final String address,
    @JsonKey(name: 'note') final String? note,
    @NullableDateTimeConverter()
    @JsonKey(name: 'created_at')
    final DateTime? createdAt,
    @NullableDateTimeConverter()
    @JsonKey(name: 'updated_at')
    final DateTime? updatedAt,
    @JsonKey(name: 'created_by') final String? createdBy,
    @JsonKey(name: 'updated_by') final String? updatedBy,
    @NullableDateTimeConverter()
    @JsonKey(name: 'archived_at')
    final DateTime? archivedAt,
    @JsonKey(name: 'archived_by') final String? archivedBy,
    @JsonKey(name: 'archived_by_name') final String? archivedByName,
  }) = _$BuildingImpl;

  factory _Building.fromJson(Map<String, dynamic> json) =
      _$BuildingImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  String get id;
  @override
  @JsonKey(name: 'name')
  String get name;
  @override
  @JsonKey(name: 'address')
  String get address;
  @override
  @JsonKey(name: 'note')
  String? get note;
  @override
  @NullableDateTimeConverter()
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @NullableDateTimeConverter()
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;
  @override
  @JsonKey(name: 'created_by')
  String? get createdBy;
  @override
  @JsonKey(name: 'updated_by')
  String? get updatedBy;
  @override
  @NullableDateTimeConverter()
  @JsonKey(name: 'archived_at')
  DateTime? get archivedAt;
  @override
  @JsonKey(name: 'archived_by')
  String? get archivedBy;
  @override
  @JsonKey(name: 'archived_by_name')
  String? get archivedByName;

  /// Create a copy of Building
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BuildingImplCopyWith<_$BuildingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
