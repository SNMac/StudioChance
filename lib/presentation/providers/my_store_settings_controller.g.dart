// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_store_settings_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 점포 상세 '내 설정'의 점포 별명·점포 색상·점포 메모 저장을 UseCase에 위임한다.
///
/// 모두 멤버마다 따로 두는 값이라 역할과 관계없이 본인이 바꾼다 (CONTEXT.md "점포 색상").

@ProviderFor(MyStoreSettingsController)
final myStoreSettingsControllerProvider = MyStoreSettingsControllerProvider._();

/// 점포 상세 '내 설정'의 점포 별명·점포 색상·점포 메모 저장을 UseCase에 위임한다.
///
/// 모두 멤버마다 따로 두는 값이라 역할과 관계없이 본인이 바꾼다 (CONTEXT.md "점포 색상").
final class MyStoreSettingsControllerProvider
    extends $AsyncNotifierProvider<MyStoreSettingsController, void> {
  /// 점포 상세 '내 설정'의 점포 별명·점포 색상·점포 메모 저장을 UseCase에 위임한다.
  ///
  /// 모두 멤버마다 따로 두는 값이라 역할과 관계없이 본인이 바꾼다 (CONTEXT.md "점포 색상").
  MyStoreSettingsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myStoreSettingsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myStoreSettingsControllerHash();

  @$internal
  @override
  MyStoreSettingsController create() => MyStoreSettingsController();
}

String _$myStoreSettingsControllerHash() =>
    r'867d3c1b655c872470a51608aa3f83f97f725044';

/// 점포 상세 '내 설정'의 점포 별명·점포 색상·점포 메모 저장을 UseCase에 위임한다.
///
/// 모두 멤버마다 따로 두는 값이라 역할과 관계없이 본인이 바꾼다 (CONTEXT.md "점포 색상").

abstract class _$MyStoreSettingsController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
