// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'room.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Room _$RoomFromJson(Map<String, dynamic> json) {
  return _Room.fromJson(json);
}

/// @nodoc
mixin _$Room {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get roomNumber => throw _privateConstructorUsedError;
  @RoomTypeConverter()
  RoomType get type => throw _privateConstructorUsedError;
  String? get floor => throw _privateConstructorUsedError;
  String? get buildingId => throw _privateConstructorUsedError;
  String? get buildingName => throw _privateConstructorUsedError;
  int get maxCapacity => throw _privateConstructorUsedError;
  double? get area => throw _privateConstructorUsedError;
  @TimeOfDayConverter()
  TimeOfDay? get openTime => throw _privateConstructorUsedError;
  @TimeOfDayConverter()
  TimeOfDay? get closeTime => throw _privateConstructorUsedError;
  List<int> get workingDays => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  bool get isUnderMaintenance => throw _privateConstructorUsedError;
  String? get maintenanceNote => throw _privateConstructorUsedError;
  DateTime? get maintenanceUntil => throw _privateConstructorUsedError;
  List<String> get equipmentIds => throw _privateConstructorUsedError;
  List<String> get photoUrls => throw _privateConstructorUsedError;
  String? get floorPlanUrl => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  DateTime? get archivedAt => throw _privateConstructorUsedError;

  /// Serializes this Room to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RoomCopyWith<Room> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoomCopyWith<$Res> {
  factory $RoomCopyWith(Room value, $Res Function(Room) then) =
      _$RoomCopyWithImpl<$Res, Room>;
  @useResult
  $Res call({
    String id,
    String name,
    String? description,
    String? roomNumber,
    @RoomTypeConverter() RoomType type,
    String? floor,
    String? buildingId,
    String? buildingName,
    int maxCapacity,
    double? area,
    @TimeOfDayConverter() TimeOfDay? openTime,
    @TimeOfDayConverter() TimeOfDay? closeTime,
    List<int> workingDays,
    bool isActive,
    bool isUnderMaintenance,
    String? maintenanceNote,
    DateTime? maintenanceUntil,
    List<String> equipmentIds,
    List<String> photoUrls,
    String? floorPlanUrl,
    String? note,
    DateTime? archivedAt,
  });
}

/// @nodoc
class _$RoomCopyWithImpl<$Res, $Val extends Room>
    implements $RoomCopyWith<$Res> {
  _$RoomCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? roomNumber = freezed,
    Object? type = null,
    Object? floor = freezed,
    Object? buildingId = freezed,
    Object? buildingName = freezed,
    Object? maxCapacity = null,
    Object? area = freezed,
    Object? openTime = freezed,
    Object? closeTime = freezed,
    Object? workingDays = null,
    Object? isActive = null,
    Object? isUnderMaintenance = null,
    Object? maintenanceNote = freezed,
    Object? maintenanceUntil = freezed,
    Object? equipmentIds = null,
    Object? photoUrls = null,
    Object? floorPlanUrl = freezed,
    Object? note = freezed,
    Object? archivedAt = freezed,
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
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            roomNumber: freezed == roomNumber
                ? _value.roomNumber
                : roomNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as RoomType,
            floor: freezed == floor
                ? _value.floor
                : floor // ignore: cast_nullable_to_non_nullable
                      as String?,
            buildingId: freezed == buildingId
                ? _value.buildingId
                : buildingId // ignore: cast_nullable_to_non_nullable
                      as String?,
            buildingName: freezed == buildingName
                ? _value.buildingName
                : buildingName // ignore: cast_nullable_to_non_nullable
                      as String?,
            maxCapacity: null == maxCapacity
                ? _value.maxCapacity
                : maxCapacity // ignore: cast_nullable_to_non_nullable
                      as int,
            area: freezed == area
                ? _value.area
                : area // ignore: cast_nullable_to_non_nullable
                      as double?,
            openTime: freezed == openTime
                ? _value.openTime
                : openTime // ignore: cast_nullable_to_non_nullable
                      as TimeOfDay?,
            closeTime: freezed == closeTime
                ? _value.closeTime
                : closeTime // ignore: cast_nullable_to_non_nullable
                      as TimeOfDay?,
            workingDays: null == workingDays
                ? _value.workingDays
                : workingDays // ignore: cast_nullable_to_non_nullable
                      as List<int>,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            isUnderMaintenance: null == isUnderMaintenance
                ? _value.isUnderMaintenance
                : isUnderMaintenance // ignore: cast_nullable_to_non_nullable
                      as bool,
            maintenanceNote: freezed == maintenanceNote
                ? _value.maintenanceNote
                : maintenanceNote // ignore: cast_nullable_to_non_nullable
                      as String?,
            maintenanceUntil: freezed == maintenanceUntil
                ? _value.maintenanceUntil
                : maintenanceUntil // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            equipmentIds: null == equipmentIds
                ? _value.equipmentIds
                : equipmentIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            photoUrls: null == photoUrls
                ? _value.photoUrls
                : photoUrls // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            floorPlanUrl: freezed == floorPlanUrl
                ? _value.floorPlanUrl
                : floorPlanUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            note: freezed == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String?,
            archivedAt: freezed == archivedAt
                ? _value.archivedAt
                : archivedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RoomImplCopyWith<$Res> implements $RoomCopyWith<$Res> {
  factory _$$RoomImplCopyWith(
    _$RoomImpl value,
    $Res Function(_$RoomImpl) then,
  ) = __$$RoomImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String? description,
    String? roomNumber,
    @RoomTypeConverter() RoomType type,
    String? floor,
    String? buildingId,
    String? buildingName,
    int maxCapacity,
    double? area,
    @TimeOfDayConverter() TimeOfDay? openTime,
    @TimeOfDayConverter() TimeOfDay? closeTime,
    List<int> workingDays,
    bool isActive,
    bool isUnderMaintenance,
    String? maintenanceNote,
    DateTime? maintenanceUntil,
    List<String> equipmentIds,
    List<String> photoUrls,
    String? floorPlanUrl,
    String? note,
    DateTime? archivedAt,
  });
}

/// @nodoc
class __$$RoomImplCopyWithImpl<$Res>
    extends _$RoomCopyWithImpl<$Res, _$RoomImpl>
    implements _$$RoomImplCopyWith<$Res> {
  __$$RoomImplCopyWithImpl(_$RoomImpl _value, $Res Function(_$RoomImpl) _then)
    : super(_value, _then);

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? roomNumber = freezed,
    Object? type = null,
    Object? floor = freezed,
    Object? buildingId = freezed,
    Object? buildingName = freezed,
    Object? maxCapacity = null,
    Object? area = freezed,
    Object? openTime = freezed,
    Object? closeTime = freezed,
    Object? workingDays = null,
    Object? isActive = null,
    Object? isUnderMaintenance = null,
    Object? maintenanceNote = freezed,
    Object? maintenanceUntil = freezed,
    Object? equipmentIds = null,
    Object? photoUrls = null,
    Object? floorPlanUrl = freezed,
    Object? note = freezed,
    Object? archivedAt = freezed,
  }) {
    return _then(
      _$RoomImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        roomNumber: freezed == roomNumber
            ? _value.roomNumber
            : roomNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as RoomType,
        floor: freezed == floor
            ? _value.floor
            : floor // ignore: cast_nullable_to_non_nullable
                  as String?,
        buildingId: freezed == buildingId
            ? _value.buildingId
            : buildingId // ignore: cast_nullable_to_non_nullable
                  as String?,
        buildingName: freezed == buildingName
            ? _value.buildingName
            : buildingName // ignore: cast_nullable_to_non_nullable
                  as String?,
        maxCapacity: null == maxCapacity
            ? _value.maxCapacity
            : maxCapacity // ignore: cast_nullable_to_non_nullable
                  as int,
        area: freezed == area
            ? _value.area
            : area // ignore: cast_nullable_to_non_nullable
                  as double?,
        openTime: freezed == openTime
            ? _value.openTime
            : openTime // ignore: cast_nullable_to_non_nullable
                  as TimeOfDay?,
        closeTime: freezed == closeTime
            ? _value.closeTime
            : closeTime // ignore: cast_nullable_to_non_nullable
                  as TimeOfDay?,
        workingDays: null == workingDays
            ? _value._workingDays
            : workingDays // ignore: cast_nullable_to_non_nullable
                  as List<int>,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        isUnderMaintenance: null == isUnderMaintenance
            ? _value.isUnderMaintenance
            : isUnderMaintenance // ignore: cast_nullable_to_non_nullable
                  as bool,
        maintenanceNote: freezed == maintenanceNote
            ? _value.maintenanceNote
            : maintenanceNote // ignore: cast_nullable_to_non_nullable
                  as String?,
        maintenanceUntil: freezed == maintenanceUntil
            ? _value.maintenanceUntil
            : maintenanceUntil // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        equipmentIds: null == equipmentIds
            ? _value._equipmentIds
            : equipmentIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        photoUrls: null == photoUrls
            ? _value._photoUrls
            : photoUrls // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        floorPlanUrl: freezed == floorPlanUrl
            ? _value.floorPlanUrl
            : floorPlanUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        note: freezed == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String?,
        archivedAt: freezed == archivedAt
            ? _value.archivedAt
            : archivedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$RoomImpl implements _Room {
  const _$RoomImpl({
    required this.id,
    required this.name,
    this.description,
    this.roomNumber,
    @RoomTypeConverter() required this.type,
    this.floor,
    this.buildingId,
    this.buildingName,
    this.maxCapacity = 30,
    this.area,
    @TimeOfDayConverter() this.openTime,
    @TimeOfDayConverter() this.closeTime,
    final List<int> workingDays = const [],
    this.isActive = true,
    this.isUnderMaintenance = false,
    this.maintenanceNote,
    this.maintenanceUntil,
    final List<String> equipmentIds = const [],
    final List<String> photoUrls = const [],
    this.floorPlanUrl,
    this.note,
    this.archivedAt,
  }) : _workingDays = workingDays,
       _equipmentIds = equipmentIds,
       _photoUrls = photoUrls;

  factory _$RoomImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoomImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  @override
  final String? roomNumber;
  @override
  @RoomTypeConverter()
  final RoomType type;
  @override
  final String? floor;
  @override
  final String? buildingId;
  @override
  final String? buildingName;
  @override
  @JsonKey()
  final int maxCapacity;
  @override
  final double? area;
  @override
  @TimeOfDayConverter()
  final TimeOfDay? openTime;
  @override
  @TimeOfDayConverter()
  final TimeOfDay? closeTime;
  final List<int> _workingDays;
  @override
  @JsonKey()
  List<int> get workingDays {
    if (_workingDays is EqualUnmodifiableListView) return _workingDays;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_workingDays);
  }

  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final bool isUnderMaintenance;
  @override
  final String? maintenanceNote;
  @override
  final DateTime? maintenanceUntil;
  final List<String> _equipmentIds;
  @override
  @JsonKey()
  List<String> get equipmentIds {
    if (_equipmentIds is EqualUnmodifiableListView) return _equipmentIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_equipmentIds);
  }

  final List<String> _photoUrls;
  @override
  @JsonKey()
  List<String> get photoUrls {
    if (_photoUrls is EqualUnmodifiableListView) return _photoUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_photoUrls);
  }

  @override
  final String? floorPlanUrl;
  @override
  final String? note;
  @override
  final DateTime? archivedAt;

  @override
  String toString() {
    return 'Room(id: $id, name: $name, description: $description, roomNumber: $roomNumber, type: $type, floor: $floor, buildingId: $buildingId, buildingName: $buildingName, maxCapacity: $maxCapacity, area: $area, openTime: $openTime, closeTime: $closeTime, workingDays: $workingDays, isActive: $isActive, isUnderMaintenance: $isUnderMaintenance, maintenanceNote: $maintenanceNote, maintenanceUntil: $maintenanceUntil, equipmentIds: $equipmentIds, photoUrls: $photoUrls, floorPlanUrl: $floorPlanUrl, note: $note, archivedAt: $archivedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoomImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.roomNumber, roomNumber) ||
                other.roomNumber == roomNumber) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.floor, floor) || other.floor == floor) &&
            (identical(other.buildingId, buildingId) ||
                other.buildingId == buildingId) &&
            (identical(other.buildingName, buildingName) ||
                other.buildingName == buildingName) &&
            (identical(other.maxCapacity, maxCapacity) ||
                other.maxCapacity == maxCapacity) &&
            (identical(other.area, area) || other.area == area) &&
            (identical(other.openTime, openTime) ||
                other.openTime == openTime) &&
            (identical(other.closeTime, closeTime) ||
                other.closeTime == closeTime) &&
            const DeepCollectionEquality().equals(
              other._workingDays,
              _workingDays,
            ) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isUnderMaintenance, isUnderMaintenance) ||
                other.isUnderMaintenance == isUnderMaintenance) &&
            (identical(other.maintenanceNote, maintenanceNote) ||
                other.maintenanceNote == maintenanceNote) &&
            (identical(other.maintenanceUntil, maintenanceUntil) ||
                other.maintenanceUntil == maintenanceUntil) &&
            const DeepCollectionEquality().equals(
              other._equipmentIds,
              _equipmentIds,
            ) &&
            const DeepCollectionEquality().equals(
              other._photoUrls,
              _photoUrls,
            ) &&
            (identical(other.floorPlanUrl, floorPlanUrl) ||
                other.floorPlanUrl == floorPlanUrl) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.archivedAt, archivedAt) ||
                other.archivedAt == archivedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    name,
    description,
    roomNumber,
    type,
    floor,
    buildingId,
    buildingName,
    maxCapacity,
    area,
    openTime,
    closeTime,
    const DeepCollectionEquality().hash(_workingDays),
    isActive,
    isUnderMaintenance,
    maintenanceNote,
    maintenanceUntil,
    const DeepCollectionEquality().hash(_equipmentIds),
    const DeepCollectionEquality().hash(_photoUrls),
    floorPlanUrl,
    note,
    archivedAt,
  ]);

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RoomImplCopyWith<_$RoomImpl> get copyWith =>
      __$$RoomImplCopyWithImpl<_$RoomImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RoomImplToJson(this);
  }
}

abstract class _Room implements Room {
  const factory _Room({
    required final String id,
    required final String name,
    final String? description,
    final String? roomNumber,
    @RoomTypeConverter() required final RoomType type,
    final String? floor,
    final String? buildingId,
    final String? buildingName,
    final int maxCapacity,
    final double? area,
    @TimeOfDayConverter() final TimeOfDay? openTime,
    @TimeOfDayConverter() final TimeOfDay? closeTime,
    final List<int> workingDays,
    final bool isActive,
    final bool isUnderMaintenance,
    final String? maintenanceNote,
    final DateTime? maintenanceUntil,
    final List<String> equipmentIds,
    final List<String> photoUrls,
    final String? floorPlanUrl,
    final String? note,
    final DateTime? archivedAt,
  }) = _$RoomImpl;

  factory _Room.fromJson(Map<String, dynamic> json) = _$RoomImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  String? get roomNumber;
  @override
  @RoomTypeConverter()
  RoomType get type;
  @override
  String? get floor;
  @override
  String? get buildingId;
  @override
  String? get buildingName;
  @override
  int get maxCapacity;
  @override
  double? get area;
  @override
  @TimeOfDayConverter()
  TimeOfDay? get openTime;
  @override
  @TimeOfDayConverter()
  TimeOfDay? get closeTime;
  @override
  List<int> get workingDays;
  @override
  bool get isActive;
  @override
  bool get isUnderMaintenance;
  @override
  String? get maintenanceNote;
  @override
  DateTime? get maintenanceUntil;
  @override
  List<String> get equipmentIds;
  @override
  List<String> get photoUrls;
  @override
  String? get floorPlanUrl;
  @override
  String? get note;
  @override
  DateTime? get archivedAt;

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RoomImplCopyWith<_$RoomImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
