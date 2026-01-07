// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_groups_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$trainingGroupTypesHash() =>
    r'de323388739fb8043cd0e1696b8efdfb9815b83c';

/// See also [trainingGroupTypes].
@ProviderFor(trainingGroupTypes)
final trainingGroupTypesProvider =
    FutureProvider<List<TrainingGroupType>>.internal(
      trainingGroupTypes,
      name: r'trainingGroupTypesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$trainingGroupTypesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TrainingGroupTypesRef = FutureProviderRef<List<TrainingGroupType>>;
String _$trainingGroupsHash() => r'f862e8ebbb815714d2339b45a263477ba826421e';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$TrainingGroups
    extends BuildlessAsyncNotifier<List<TrainingGroup>> {
  late final String searchQuery;
  late final int? groupTypeId;
  late final bool? isActive;
  late final bool? isArchived;

  FutureOr<List<TrainingGroup>> build({
    String searchQuery = '',
    int? groupTypeId,
    bool? isActive,
    bool? isArchived,
  });
}

/// See also [TrainingGroups].
@ProviderFor(TrainingGroups)
const trainingGroupsProvider = TrainingGroupsFamily();

/// See also [TrainingGroups].
class TrainingGroupsFamily extends Family<AsyncValue<List<TrainingGroup>>> {
  /// See also [TrainingGroups].
  const TrainingGroupsFamily();

  /// See also [TrainingGroups].
  TrainingGroupsProvider call({
    String searchQuery = '',
    int? groupTypeId,
    bool? isActive,
    bool? isArchived,
  }) {
    return TrainingGroupsProvider(
      searchQuery: searchQuery,
      groupTypeId: groupTypeId,
      isActive: isActive,
      isArchived: isArchived,
    );
  }

  @override
  TrainingGroupsProvider getProviderOverride(
    covariant TrainingGroupsProvider provider,
  ) {
    return call(
      searchQuery: provider.searchQuery,
      groupTypeId: provider.groupTypeId,
      isActive: provider.isActive,
      isArchived: provider.isArchived,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'trainingGroupsProvider';
}

/// See also [TrainingGroups].
class TrainingGroupsProvider
    extends AsyncNotifierProviderImpl<TrainingGroups, List<TrainingGroup>> {
  /// See also [TrainingGroups].
  TrainingGroupsProvider({
    String searchQuery = '',
    int? groupTypeId,
    bool? isActive,
    bool? isArchived,
  }) : this._internal(
         () => TrainingGroups()
           ..searchQuery = searchQuery
           ..groupTypeId = groupTypeId
           ..isActive = isActive
           ..isArchived = isArchived,
         from: trainingGroupsProvider,
         name: r'trainingGroupsProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$trainingGroupsHash,
         dependencies: TrainingGroupsFamily._dependencies,
         allTransitiveDependencies:
             TrainingGroupsFamily._allTransitiveDependencies,
         searchQuery: searchQuery,
         groupTypeId: groupTypeId,
         isActive: isActive,
         isArchived: isArchived,
       );

  TrainingGroupsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.searchQuery,
    required this.groupTypeId,
    required this.isActive,
    required this.isArchived,
  }) : super.internal();

  final String searchQuery;
  final int? groupTypeId;
  final bool? isActive;
  final bool? isArchived;

  @override
  FutureOr<List<TrainingGroup>> runNotifierBuild(
    covariant TrainingGroups notifier,
  ) {
    return notifier.build(
      searchQuery: searchQuery,
      groupTypeId: groupTypeId,
      isActive: isActive,
      isArchived: isArchived,
    );
  }

  @override
  Override overrideWith(TrainingGroups Function() create) {
    return ProviderOverride(
      origin: this,
      override: TrainingGroupsProvider._internal(
        () => create()
          ..searchQuery = searchQuery
          ..groupTypeId = groupTypeId
          ..isActive = isActive
          ..isArchived = isArchived,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        searchQuery: searchQuery,
        groupTypeId: groupTypeId,
        isActive: isActive,
        isArchived: isArchived,
      ),
    );
  }

  @override
  AsyncNotifierProviderElement<TrainingGroups, List<TrainingGroup>>
  createElement() {
    return _TrainingGroupsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TrainingGroupsProvider &&
        other.searchQuery == searchQuery &&
        other.groupTypeId == groupTypeId &&
        other.isActive == isActive &&
        other.isArchived == isArchived;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, searchQuery.hashCode);
    hash = _SystemHash.combine(hash, groupTypeId.hashCode);
    hash = _SystemHash.combine(hash, isActive.hashCode);
    hash = _SystemHash.combine(hash, isArchived.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TrainingGroupsRef on AsyncNotifierProviderRef<List<TrainingGroup>> {
  /// The parameter `searchQuery` of this provider.
  String get searchQuery;

  /// The parameter `groupTypeId` of this provider.
  int? get groupTypeId;

  /// The parameter `isActive` of this provider.
  bool? get isActive;

  /// The parameter `isArchived` of this provider.
  bool? get isArchived;
}

class _TrainingGroupsProviderElement
    extends AsyncNotifierProviderElement<TrainingGroups, List<TrainingGroup>>
    with TrainingGroupsRef {
  _TrainingGroupsProviderElement(super.provider);

  @override
  String get searchQuery => (origin as TrainingGroupsProvider).searchQuery;
  @override
  int? get groupTypeId => (origin as TrainingGroupsProvider).groupTypeId;
  @override
  bool? get isActive => (origin as TrainingGroupsProvider).isActive;
  @override
  bool? get isArchived => (origin as TrainingGroupsProvider).isArchived;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
