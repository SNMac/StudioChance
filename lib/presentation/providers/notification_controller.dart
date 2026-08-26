import 'dart:async';
import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/constants/notification_constants.dart';
import 'package:studio_chance/data/models/push_message_mapper.dart';
import 'package:studio_chance/domain/entities/push_message.dart';
import 'package:studio_chance/domain/use_cases/notification_use_case_provider.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';
import 'package:studio_chance/presentation/providers/home_store_filter_controller.dart';
import 'package:studio_chance/router/app_router.dart';
import 'package:studio_chance/router/router_path.dart';

part 'notification_controller.g.dart';

/// 푸시 메시지가 "가입 신청"이면 이동 대상 점포 ID를, 아니면 null을 반환한다.
String? joinRequestStoreIdOf(PushMessage message) {
  if (message.type != joinRequestNotificationType) return null;

  final storeId = message.data['storeId'];
  if (storeId == null || storeId.isEmpty) return null;

  return storeId;
}

/// 알림 권한 요청, FCM 토큰 등록, 수신 메시지 표시·딥링크를 담당한다.
///
/// `MyApp`에서 watch하여 앱 생명주기 동안 살아 있게 한다.
@Riverpod(keepAlive: true)
class NotificationController extends _$NotificationController {
  final _logger = Logger();

  StreamSubscription<String>? _tokenSubscription;
  StreamSubscription<PushMessage>? _foregroundSubscription;
  StreamSubscription<PushMessage>? _openedAppSubscription;

  /// 인증이 끝나기 전에 도착한 메시지 (종료 상태에서 알림 탭한 경우)
  PushMessage? _pendingMessage;

  @override
  Future<void> build() async {
    await _cancelSubscriptions();
    ref.onDispose(_cancelSubscriptions);

    final user = await ref.watch(currentUserProvider.future);
    if (user == null) return;

    final useCase = ref.read(notificationUseCaseProvider);

    // 인증이 늦게 끝나는 경우를 대비해 보류된 메시지를 소비한다.
    ref.listen(appAuthControllerProvider, (_, next) {
      if (next.value != AppStatus.authenticated) return;

      final pending = _pendingMessage;
      if (pending == null) return;
      _pendingMessage = null;
      _handleMessage(pending);
    });

    await useCase.initLocalNotifications(onTap: _handlePayload);

    final permissionResult = await useCase.requestPermission();
    permissionResult.fold(
      (error) => _logger.w('알림 권한 요청 실패 (무시)', error: error),
      (granted) => _logger.i('알림 권한 허용 여부: $granted'),
    );

    final registerResult = await useCase.registerFcmToken(uid: user.id);
    registerResult.fold(
      (error) => _logger.w('FCM 토큰 등록 실패 (무시)', error: error),
      (_) {},
    );

    _tokenSubscription = useCase.onTokenRefresh.listen((token) {
      useCase.registerFcmToken(uid: user.id, token: token);
    });

    _foregroundSubscription = useCase.foregroundMessages.listen((message) {
      useCase.showLocalNotification(message);
    });

    _openedAppSubscription = useCase.openedAppMessages.listen(_handleMessage);

    final initialMessage = await useCase.getInitialMessage();
    if (initialMessage != null) _handleMessage(initialMessage);
  }

  /// 로컬 알림 payload(JSON 문자열)를 메시지로 되돌려 처리한다.
  ///
  /// `showLocalNotification`이 저장한 payload는 `PushMessage.data`를
  /// `jsonEncode`한 것이므로, 복원도 동일한 변환기(`pushMessageFromData`)를
  /// 사용해 중복 구현을 피한다.
  void _handlePayload(String? payload) {
    if (payload == null || payload.isEmpty) return;

    try {
      final decoded = jsonDecode(payload) as Map<String, dynamic>;
      _handleMessage(pushMessageFromData(decoded));
    } catch (e) {
      _logger.w('알림 payload 파싱 실패', error: e);
    }
  }

  void _handleMessage(PushMessage message) {
    final storeId = joinRequestStoreIdOf(message);
    if (storeId == null) return;

    final status = ref.read(appAuthControllerProvider).value;
    if (status != AppStatus.authenticated) {
      // 스플래시·온보딩 중이면 홈으로 보낼 수 없으므로 보류한다.
      _pendingMessage = message;
      return;
    }

    // TODO: 승인 대기 멤버 관리 화면이 생기면 홈 대신 그 화면으로 이동할 것 (#19)
    ref
        .read(homeStoreFilterControllerProvider.notifier)
        .ensureSelected(storeId);
    ref.read(goRouterProvider).go(SCRoute.home.path);
  }

  Future<void> _cancelSubscriptions() async {
    await _tokenSubscription?.cancel();
    await _foregroundSubscription?.cancel();
    await _openedAppSubscription?.cancel();
    _tokenSubscription = null;
    _foregroundSubscription = null;
    _openedAppSubscription = null;
  }
}
