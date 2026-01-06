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
String _$trainingGroupsHash() => r'65bfaac4cf971dce1a1c72cbd3a4bb723f651915';

/// See also [TrainingGroups].
@ProviderFor(TrainingGroups)
final trainingGroupsProvider =
    AsyncNotifierProvider<TrainingGroups, List<TrainingGroup>>.internal(
      TrainingGroups.new,
      name: r'trainingGroupsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$trainingGroupsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TrainingGroups = AsyncNotifier<List<TrainingGroup>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
