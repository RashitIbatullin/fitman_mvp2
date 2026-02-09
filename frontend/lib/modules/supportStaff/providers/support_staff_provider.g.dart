// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_staff_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allSupportStaffHash() => r'4ffdb9a6781a66a2910d61ba528914555b562a96';

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

/// See also [allSupportStaff].
@ProviderFor(allSupportStaff)
const allSupportStaffProvider = AllSupportStaffFamily();

/// See also [allSupportStaff].
class AllSupportStaffFamily extends Family<AsyncValue<List<SupportStaff>>> {
  /// See also [allSupportStaff].
  const AllSupportStaffFamily();

  /// See also [allSupportStaff].
  AllSupportStaffProvider call({bool includeArchived = false}) {
    return AllSupportStaffProvider(includeArchived: includeArchived);
  }

  @override
  AllSupportStaffProvider getProviderOverride(
    covariant AllSupportStaffProvider provider,
  ) {
    return call(includeArchived: provider.includeArchived);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'allSupportStaffProvider';
}

/// See also [allSupportStaff].
class AllSupportStaffProvider
    extends AutoDisposeFutureProvider<List<SupportStaff>> {
  /// See also [allSupportStaff].
  AllSupportStaffProvider({bool includeArchived = false})
    : this._internal(
        (ref) => allSupportStaff(
          ref as AllSupportStaffRef,
          includeArchived: includeArchived,
        ),
        from: allSupportStaffProvider,
        name: r'allSupportStaffProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$allSupportStaffHash,
        dependencies: AllSupportStaffFamily._dependencies,
        allTransitiveDependencies:
            AllSupportStaffFamily._allTransitiveDependencies,
        includeArchived: includeArchived,
      );

  AllSupportStaffProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.includeArchived,
  }) : super.internal();

  final bool includeArchived;

  @override
  Override overrideWith(
    FutureOr<List<SupportStaff>> Function(AllSupportStaffRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AllSupportStaffProvider._internal(
        (ref) => create(ref as AllSupportStaffRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        includeArchived: includeArchived,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<SupportStaff>> createElement() {
    return _AllSupportStaffProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AllSupportStaffProvider &&
        other.includeArchived == includeArchived;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, includeArchived.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AllSupportStaffRef on AutoDisposeFutureProviderRef<List<SupportStaff>> {
  /// The parameter `includeArchived` of this provider.
  bool get includeArchived;
}

class _AllSupportStaffProviderElement
    extends AutoDisposeFutureProviderElement<List<SupportStaff>>
    with AllSupportStaffRef {
  _AllSupportStaffProviderElement(super.provider);

  @override
  bool get includeArchived =>
      (origin as AllSupportStaffProvider).includeArchived;
}

String _$supportStaffByIdHash() => r'646626ad9f894a39d4491f67776fea04fad1ed90';

/// See also [supportStaffById].
@ProviderFor(supportStaffById)
const supportStaffByIdProvider = SupportStaffByIdFamily();

/// See also [supportStaffById].
class SupportStaffByIdFamily extends Family<AsyncValue<SupportStaff>> {
  /// See also [supportStaffById].
  const SupportStaffByIdFamily();

  /// See also [supportStaffById].
  SupportStaffByIdProvider call(String id) {
    return SupportStaffByIdProvider(id);
  }

  @override
  SupportStaffByIdProvider getProviderOverride(
    covariant SupportStaffByIdProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'supportStaffByIdProvider';
}

/// See also [supportStaffById].
class SupportStaffByIdProvider extends AutoDisposeFutureProvider<SupportStaff> {
  /// See also [supportStaffById].
  SupportStaffByIdProvider(String id)
    : this._internal(
        (ref) => supportStaffById(ref as SupportStaffByIdRef, id),
        from: supportStaffByIdProvider,
        name: r'supportStaffByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$supportStaffByIdHash,
        dependencies: SupportStaffByIdFamily._dependencies,
        allTransitiveDependencies:
            SupportStaffByIdFamily._allTransitiveDependencies,
        id: id,
      );

  SupportStaffByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<SupportStaff> Function(SupportStaffByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SupportStaffByIdProvider._internal(
        (ref) => create(ref as SupportStaffByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<SupportStaff> createElement() {
    return _SupportStaffByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SupportStaffByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SupportStaffByIdRef on AutoDisposeFutureProviderRef<SupportStaff> {
  /// The parameter `id` of this provider.
  String get id;
}

class _SupportStaffByIdProviderElement
    extends AutoDisposeFutureProviderElement<SupportStaff>
    with SupportStaffByIdRef {
  _SupportStaffByIdProviderElement(super.provider);

  @override
  String get id => (origin as SupportStaffByIdProvider).id;
}

String _$supportStaffNotifierHash() =>
    r'96bdc6ca1c4d1dffb678a3d123961540bb96796e';

/// See also [SupportStaffNotifier].
@ProviderFor(SupportStaffNotifier)
final supportStaffNotifierProvider =
    AutoDisposeAsyncNotifierProvider<SupportStaffNotifier, void>.internal(
      SupportStaffNotifier.new,
      name: r'supportStaffNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$supportStaffNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SupportStaffNotifier = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
