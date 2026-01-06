// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_members_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$groupMembersHash() => r'd6f242ca8cf847fc306b4810a44035de544a3a2b';

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

abstract class _$GroupMembers extends BuildlessAsyncNotifier<List<int>> {
  late final int groupId;

  FutureOr<List<int>> build(int groupId);
}

/// See also [GroupMembers].
@ProviderFor(GroupMembers)
const groupMembersProvider = GroupMembersFamily();

/// See also [GroupMembers].
class GroupMembersFamily extends Family<AsyncValue<List<int>>> {
  /// See also [GroupMembers].
  const GroupMembersFamily();

  /// See also [GroupMembers].
  GroupMembersProvider call(int groupId) {
    return GroupMembersProvider(groupId);
  }

  @override
  GroupMembersProvider getProviderOverride(
    covariant GroupMembersProvider provider,
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
  String? get name => r'groupMembersProvider';
}

/// See also [GroupMembers].
class GroupMembersProvider
    extends AsyncNotifierProviderImpl<GroupMembers, List<int>> {
  /// See also [GroupMembers].
  GroupMembersProvider(int groupId)
    : this._internal(
        () => GroupMembers()..groupId = groupId,
        from: groupMembersProvider,
        name: r'groupMembersProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$groupMembersHash,
        dependencies: GroupMembersFamily._dependencies,
        allTransitiveDependencies:
            GroupMembersFamily._allTransitiveDependencies,
        groupId: groupId,
      );

  GroupMembersProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.groupId,
  }) : super.internal();

  final int groupId;

  @override
  FutureOr<List<int>> runNotifierBuild(covariant GroupMembers notifier) {
    return notifier.build(groupId);
  }

  @override
  Override overrideWith(GroupMembers Function() create) {
    return ProviderOverride(
      origin: this,
      override: GroupMembersProvider._internal(
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
  AsyncNotifierProviderElement<GroupMembers, List<int>> createElement() {
    return _GroupMembersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupMembersProvider && other.groupId == groupId;
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
mixin GroupMembersRef on AsyncNotifierProviderRef<List<int>> {
  /// The parameter `groupId` of this provider.
  int get groupId;
}

class _GroupMembersProviderElement
    extends AsyncNotifierProviderElement<GroupMembers, List<int>>
    with GroupMembersRef {
  _GroupMembersProviderElement(super.provider);

  @override
  int get groupId => (origin as GroupMembersProvider).groupId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
