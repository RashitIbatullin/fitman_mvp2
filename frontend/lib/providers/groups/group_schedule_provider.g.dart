// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_schedule_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$groupScheduleHash() => r'e884ab0ead87d2014eb9e417d9a9da65f686d792';

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

abstract class _$GroupSchedule
    extends BuildlessAsyncNotifier<List<GroupScheduleSlot>> {
  late final String groupId;

  FutureOr<List<GroupScheduleSlot>> build(String groupId);
}

/// See also [GroupSchedule].
@ProviderFor(GroupSchedule)
const groupScheduleProvider = GroupScheduleFamily();

/// See also [GroupSchedule].
class GroupScheduleFamily extends Family<AsyncValue<List<GroupScheduleSlot>>> {
  /// See also [GroupSchedule].
  const GroupScheduleFamily();

  /// See also [GroupSchedule].
  GroupScheduleProvider call(String groupId) {
    return GroupScheduleProvider(groupId);
  }

  @override
  GroupScheduleProvider getProviderOverride(
    covariant GroupScheduleProvider provider,
  ) {
    return call(provider.groupId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'groupScheduleProvider';
}

/// See also [GroupSchedule].
class GroupScheduleProvider
    extends AsyncNotifierProviderImpl<GroupSchedule, List<GroupScheduleSlot>> {
  /// See also [GroupSchedule].
  GroupScheduleProvider(String groupId)
    : this._internal(
        () => GroupSchedule()..groupId = groupId,
        from: groupScheduleProvider,
        name: r'groupScheduleProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$groupScheduleHash,
        dependencies: GroupScheduleFamily._dependencies,
        allTransitiveDependencies:
            GroupScheduleFamily._allTransitiveDependencies,
        groupId: groupId,
      );

  GroupScheduleProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.groupId,
  }) : super.internal();

  final String groupId;

  @override
  FutureOr<List<GroupScheduleSlot>> runNotifierBuild(
    covariant GroupSchedule notifier,
  ) {
    return notifier.build(groupId);
  }

  @override
  Override overrideWith(GroupSchedule Function() create) {
    return ProviderOverride(
      origin: this,
      override: GroupScheduleProvider._internal(
        () => create()..groupId = groupId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        groupId: groupId,
      ),
    );
  }

  @override
  AsyncNotifierProviderElement<GroupSchedule, List<GroupScheduleSlot>>
  createElement() {
    return _GroupScheduleProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupScheduleProvider && other.groupId == groupId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GroupScheduleRef on AsyncNotifierProviderRef<List<GroupScheduleSlot>> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _GroupScheduleProviderElement
    extends AsyncNotifierProviderElement<GroupSchedule, List<GroupScheduleSlot>>
    with GroupScheduleRef {
  _GroupScheduleProviderElement(super.provider);

  @override
  String get groupId => (origin as GroupScheduleProvider).groupId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
