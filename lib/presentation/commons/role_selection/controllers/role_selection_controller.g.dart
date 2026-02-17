// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role_selection_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RoleSelectionController)
final roleSelectionControllerProvider = RoleSelectionControllerProvider._();

final class RoleSelectionControllerProvider
    extends $NotifierProvider<RoleSelectionController, UserRole> {
  RoleSelectionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'roleSelectionControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$roleSelectionControllerHash();

  @$internal
  @override
  RoleSelectionController create() => RoleSelectionController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserRole value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserRole>(value),
    );
  }
}

String _$roleSelectionControllerHash() =>
    r'cbaf16fe3f15ceef7a28aa62cc3a7689a5c0f82d';

abstract class _$RoleSelectionController extends $Notifier<UserRole> {
  UserRole build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<UserRole, UserRole>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UserRole, UserRole>,
              UserRole,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
