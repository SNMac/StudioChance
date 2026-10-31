// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_deletion_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 계정 삭제를 UseCase에 위임한다. (CLAUDE.md "Presentation → Domain 접근 규칙")
///
/// 재인증 창과 Apple revoke는 `AuthUseCase.delete()` 안에서 한다 (ADR-0005).
/// 성공하면 인증 상태가 바뀌어 라우터가 로그인 화면으로 보낸다.
/// 마이페이지는 [findStoresBlockingDeletion]으로 막는 점포를 먼저 확인하고 계정 삭제 화면을 연다.
/// 그 사이 멤버가 늘었으면 [delete]가 `StoreAdminHandoverRequiredException`으로
/// 실패하며, 이때는 재인증 창이 뜨기 전에 막힌다.

@ProviderFor(AccountDeletionController)
final accountDeletionControllerProvider = AccountDeletionControllerProvider._();

/// 계정 삭제를 UseCase에 위임한다. (CLAUDE.md "Presentation → Domain 접근 규칙")
///
/// 재인증 창과 Apple revoke는 `AuthUseCase.delete()` 안에서 한다 (ADR-0005).
/// 성공하면 인증 상태가 바뀌어 라우터가 로그인 화면으로 보낸다.
/// 마이페이지는 [findStoresBlockingDeletion]으로 막는 점포를 먼저 확인하고 계정 삭제 화면을 연다.
/// 그 사이 멤버가 늘었으면 [delete]가 `StoreAdminHandoverRequiredException`으로
/// 실패하며, 이때는 재인증 창이 뜨기 전에 막힌다.
final class AccountDeletionControllerProvider
    extends $AsyncNotifierProvider<AccountDeletionController, void> {
  /// 계정 삭제를 UseCase에 위임한다. (CLAUDE.md "Presentation → Domain 접근 규칙")
  ///
  /// 재인증 창과 Apple revoke는 `AuthUseCase.delete()` 안에서 한다 (ADR-0005).
  /// 성공하면 인증 상태가 바뀌어 라우터가 로그인 화면으로 보낸다.
  /// 마이페이지는 [findStoresBlockingDeletion]으로 막는 점포를 먼저 확인하고 계정 삭제 화면을 연다.
  /// 그 사이 멤버가 늘었으면 [delete]가 `StoreAdminHandoverRequiredException`으로
  /// 실패하며, 이때는 재인증 창이 뜨기 전에 막힌다.
  AccountDeletionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountDeletionControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountDeletionControllerHash();

  @$internal
  @override
  AccountDeletionController create() => AccountDeletionController();
}

String _$accountDeletionControllerHash() =>
    r'b9a320d6372597c7011799eace8b89f4bde69c4d';

/// 계정 삭제를 UseCase에 위임한다. (CLAUDE.md "Presentation → Domain 접근 규칙")
///
/// 재인증 창과 Apple revoke는 `AuthUseCase.delete()` 안에서 한다 (ADR-0005).
/// 성공하면 인증 상태가 바뀌어 라우터가 로그인 화면으로 보낸다.
/// 마이페이지는 [findStoresBlockingDeletion]으로 막는 점포를 먼저 확인하고 계정 삭제 화면을 연다.
/// 그 사이 멤버가 늘었으면 [delete]가 `StoreAdminHandoverRequiredException`으로
/// 실패하며, 이때는 재인증 창이 뜨기 전에 막힌다.

abstract class _$AccountDeletionController extends $AsyncNotifier<void> {
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
