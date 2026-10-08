// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 알림 권한 요청, FCM 토큰 등록, 수신 메시지 표시·딥링크를 담당한다.
///
/// `MyApp`에서 watch하여 앱 생명주기 동안 살아 있게 한다.

@ProviderFor(NotificationController)
final notificationControllerProvider = NotificationControllerProvider._();

/// 알림 권한 요청, FCM 토큰 등록, 수신 메시지 표시·딥링크를 담당한다.
///
/// `MyApp`에서 watch하여 앱 생명주기 동안 살아 있게 한다.
final class NotificationControllerProvider
    extends $AsyncNotifierProvider<NotificationController, void> {
  /// 알림 권한 요청, FCM 토큰 등록, 수신 메시지 표시·딥링크를 담당한다.
  ///
  /// `MyApp`에서 watch하여 앱 생명주기 동안 살아 있게 한다.
  NotificationControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationControllerHash();

  @$internal
  @override
  NotificationController create() => NotificationController();
}

String _$notificationControllerHash() =>
    r'19b6c50b2d8867567fbe589e7b46eab750f8ec77';

/// 알림 권한 요청, FCM 토큰 등록, 수신 메시지 표시·딥링크를 담당한다.
///
/// `MyApp`에서 watch하여 앱 생명주기 동안 살아 있게 한다.

abstract class _$NotificationController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
