// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytic_groups_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$analyticGroupsHash() => r'7f8a56153a35948bf2a920c7b9376dbdc718a033';

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

abstract class _$AnalyticGroups
    extends BuildlessAsyncNotifier<List<AnalyticGroup>> {
  late final String searchQuery;
  late final bool? isArchived;

  FutureOr<List<AnalyticGroup>> build({
    String searchQuery = '',
    bool? isArchived,
  });
}

/// See also [AnalyticGroups].
@ProviderFor(AnalyticGroups)
const analyticGroupsProvider = AnalyticGroupsFamily();

/// See also [AnalyticGroups].
class AnalyticGroupsFamily extends Family<AsyncValue<List<AnalyticGroup>>> {
  /// See also [AnalyticGroups].
  const AnalyticGroupsFamily();

  /// See also [AnalyticGroups].
  AnalyticGroupsProvider call({String searchQuery = '', bool? isArchived}) {
    return AnalyticGroupsProvider(
      searchQuery: searchQuery,
      isArchived: isArchived,
    );
  }

  @override
  AnalyticGroupsProvider getProviderOverride(
    covariant AnalyticGroupsProvider provider,
  ) {
    return call(
      searchQuery: provider.searchQuery,
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
  String? get name => r'analyticGroupsProvider';
}

/// See also [AnalyticGroups].
class AnalyticGroupsProvider
    extends AsyncNotifierProviderImpl<AnalyticGroups, List<AnalyticGroup>> {
  /// See also [AnalyticGroups].
  AnalyticGroupsProvider({String searchQuery = '', bool? isArchived})
    : this._internal(
        () => AnalyticGroups()
          ..searchQuery = searchQuery
          ..isArchived = isArchived,
        from: analyticGroupsProvider,
        name: r'analyticGroupsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$analyticGroupsHash,
        dependencies: AnalyticGroupsFamily._dependencies,
        allTransitiveDependencies:
            AnalyticGroupsFamily._allTransitiveDependencies,
        searchQuery: searchQuery,
        isArchived: isArchived,
      );

  AnalyticGroupsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.searchQuery,
    required this.isArchived,
  }) : super.internal();

  final String searchQuery;
  final bool? isArchived;

  @override
  FutureOr<List<AnalyticGroup>> runNotifierBuild(
    covariant AnalyticGroups notifier,
  ) {
    return notifier.build(searchQuery: searchQuery, isArchived: isArchived);
  }

  @override
  Override overrideWith(AnalyticGroups Function() create) {
    return ProviderOverride(
      origin: this,
      override: AnalyticGroupsProvider._internal(
        () => create()
          ..searchQuery = searchQuery
          ..isArchived = isArchived,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        searchQuery: searchQuery,
        isArchived: isArchived,
      ),
    );
  }

  @override
  AsyncNotifierProviderElement<AnalyticGroups, List<AnalyticGroup>>
  createElement() {
    return _AnalyticGroupsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AnalyticGroupsProvider &&
        other.searchQuery == searchQuery &&
        other.isArchived == isArchived;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, searchQuery.hashCode);
    hash = _SystemHash.combine(hash, isArchived.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AnalyticGroupsRef on AsyncNotifierProviderRef<List<AnalyticGroup>> {
  /// The parameter `searchQuery` of this provider.
  String get searchQuery;

  /// The parameter `isArchived` of this provider.
  bool? get isArchived;
}

class _AnalyticGroupsProviderElement
    extends AsyncNotifierProviderElement<AnalyticGroups, List<AnalyticGroup>>
    with AnalyticGroupsRef {
  _AnalyticGroupsProviderElement(super.provider);

  @override
  String get searchQuery => (origin as AnalyticGroupsProvider).searchQuery;
  @override
  bool? get isArchived => (origin as AnalyticGroupsProvider).isArchived;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
