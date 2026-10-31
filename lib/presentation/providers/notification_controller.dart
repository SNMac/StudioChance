import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/constants/notification_constants.dart';
import 'package:studio_chance/data/models/push_message_mapper.dart';
import 'package:studio_chance/domain/entities/push_message.dart';
import 'package:studio_chance/domain/use_cases/notification_use_case_provider.dart';
import 'package:studio_chance/presentation/my_page/widgets/pending_member_modal.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';
import 'package:studio_chance/presentation/providers/store_detail_provider.dart';
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

/// 멤버 구성 변화 알림 type — 받은 사람의 점포 목록·역할이 바뀐다
const _membershipChangeNotificationTypes = {
  adminDelegatedNotificationType,
  memberLeftNotificationType,
  memberRemovedNotificationType,
  joinApprovedNotificationType,
  joinRejectedNotificationType,
  storeDeletedNotificationType,
  storeRestoredNotificationType,
};

/// 푸시 메시지가 멤버 구성 변화(관리자 위임·점포 나가기·추방·가입 승인·거절·점포 삭제·복구)면
/// 해당 점포 ID를, 아니면 null을 반환한다.
String? membershipChangeStoreIdOf(PushMessage message) {
  if (!_membershipChangeNotificationTypes.contains(message.type)) return null;

  final storeId = message.data['storeId'];
  if (storeId == null || storeId.isEmpty) return null;

  return storeId;
}

/// 멤버 구성 변화 알림을 탭했을 때 열 위치.
///
/// 점포를 계속 볼 수 있는 알림(관리자 위임·멤버 나가기·가입 승인·점포 복구)은 그 점포 상세를,
/// 더는 볼 수 없는 알림(추방·거절·점포 삭제)은 마이페이지를 연다. 점포 삭제는 영구 삭제와
/// 같은 type이라 아직 볼 수 있는 삭제 예정 점포여도 마이페이지를 연다
/// 멤버 구성 변화가 아니면 null.
String? membershipChangeLocationOf(PushMessage message) {
  final storeId = membershipChangeStoreIdOf(message);
  if (storeId == null) return null;

  return switch (message.type) {
    adminDelegatedNotificationType ||
    memberLeftNotificationType ||
    joinApprovedNotificationType ||
    storeRestoredNotificationType => storeDetailLocation(storeId),
    _ => SCRoute.myPage.path,
  };
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

  /// build() 세대 번호.
  ///
  /// riverpod 3.1.0은 build()가 새 호출로 대체돼도 이전 build()의 Future 본문을
  /// 강제 중단하지 않고 끝까지 실행한다 (버려지는 것은 반환값뿐). currentUserProvider가
  /// 짧은 간격으로 두 번 emit되거나(로그아웃 직후 재로그인 등) requestPermission()이
  /// OS 권한 다이얼로그에서 수 초간 블로킹되는 사이 두 build()가 겹치면, 뒤처진(오래된)
  /// build()가 stale한 uid로 구독을 덮어쓰거나 FCM 토큰을 다른 계정에 등록할 수 있다.
  /// → 매 await 직후 세대 번호를 비교해 뒤처진 build()는 즉시 포기한다.
  /// (지워도 컴파일·평상시 테스트는 통과하므로 불필요해 보일 수 있으나 삭제 금지)
  int _buildGeneration = 0;

  @override
  Future<void> build() async {
    final generation = ++_buildGeneration;

    await _cancelSubscriptions();
    ref.onDispose(_cancelSubscriptions);

    // uid만 watch한다. 사용자 정보 전체를 watch하면 닉네임 변경·점포 생성 등으로
    // currentUserProvider가 갱신될 때마다 구독 해제·FCM 토큰 쓰기가 반복되고,
    // 다시 구독하는 사이 포그라운드 메시지를 놓칠 수 있다.
    final uid = await ref.watch(
      currentUserProvider.selectAsync((user) => user?.id),
    );
    if (generation != _buildGeneration || uid == null) return;

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
    if (generation != _buildGeneration) return;

    // iOS는 시스템이 포그라운드 배너를 표시하도록 켠다. 이 설정을 끄면
    // UNUserNotificationCenterDelegate가 presentationOptions=0을 반환해,
    // 앱이 만든 로컬 알림까지 함께 억제된다(배너 없이 알림 센터에만 쌓임).
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final presentationResult = await useCase.enableForegroundPresentation();
      if (generation != _buildGeneration) return;
      presentationResult.fold(
        (error) => _logger.w('포그라운드 알림 표시 설정 실패 (무시)', error: error),
        (_) {},
      );
    }

    final permissionResult = await useCase.requestPermission();
    if (generation != _buildGeneration) return;
    permissionResult.fold(
      (error) => _logger.w('알림 권한 요청 실패 (무시)', error: error),
      (granted) => _logger.i('알림 권한 허용 여부: $granted'),
    );

    final registerResult = await useCase.registerFcmToken(uid: uid);
    if (generation != _buildGeneration) return;
    registerResult.fold(
      (error) => _logger.w('FCM 토큰 등록 실패 (무시)', error: error),
      (_) {},
    );

    if (generation != _buildGeneration) return;
    _tokenSubscription = useCase.onTokenRefresh.listen((token) {
      useCase.registerFcmToken(uid: uid, token: token);
    });

    if (generation != _buildGeneration) return;
    _foregroundSubscription = useCase.foregroundMessages.listen((message) {
      // storeDetailProvider는 일회성 조회라, 마이페이지가 살아 있는 동안 캐시가
      // 그대로 유지된다. 다른 기기에서 들어온 신청이 대기 인원 배지와 모달에
      // 즉시 보이도록, 알림을 받은 시점에 해당 점포 조회를 무효화한다.
      final joinRequestStoreId = joinRequestStoreIdOf(message);
      if (joinRequestStoreId != null) {
        ref.invalidate(storeDetailProvider(joinRequestStoreId));
      }
      _refreshMembership(message);

      // iOS는 위에서 켠 설정으로 시스템이 직접 배너를 표시하므로,
      // 로컬 알림까지 띄우면 배너가 두 번 보인다.
      // Android는 FCM이 포그라운드 알림을 표시하지 않아 로컬 알림이 필요하다.
      if (defaultTargetPlatform == TargetPlatform.iOS) return;
      useCase.showLocalNotification(message);
    });

    if (generation != _buildGeneration) return;
    _openedAppSubscription = useCase.openedAppMessages.listen(_handleMessage);

    final initialMessage = await useCase.getInitialMessage();
    if (generation != _buildGeneration) return;
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

  /// 멤버 구성 변화 알림이면 내 점포 목록·역할과 해당 점포 정보를 다시 읽는다.
  /// 다른 사람의 쓰기로 바뀐 것이라 이 기기의 캐시는 스스로 갱신되지 않는다
  void _refreshMembership(PushMessage message) {
    final storeId = membershipChangeStoreIdOf(message);
    if (storeId == null) return;

    ref.invalidate(currentUserProvider);
    ref.invalidate(storeDetailProvider(storeId));
  }

  void _handleMessage(PushMessage message) {
    final storeId = joinRequestStoreIdOf(message);
    final membershipLocation = membershipChangeLocationOf(message);
    if (storeId == null && membershipLocation == null) return;

    final status = ref.read(appAuthControllerProvider).value;
    if (status != AppStatus.authenticated) {
      // 스플래시·온보딩 중이면 이동할 수 없으므로 보류한다.
      _pendingMessage = message;
      return;
    }

    _refreshMembership(message);

    final router = ref.read(goRouterProvider);

    // 멤버 구성 변화는 해당 위치로 이동만 한다. 점포 상세도 마이페이지 아래에
    // 쌓이므로 뒤로 가면 마이페이지가 나온다
    if (membershipLocation != null) {
      router.go(membershipLocation);
      return;
    }

    router.go(SCRoute.myPage.path);
    if (storeId == null) return;

    // go()는 선언적 이동이라 GoRouter가 다음 프레임에 Navigator의 페이지 목록을
    // 실제로 갱신한다. 프레임 1회면 충분하다 — navigatorKey.currentContext는
    // 루트 Navigator의 context로 앱 시작 후 계속 mount 상태이며(경로 전환과
    // 무관하게 유지됨), addPostFrameCallback은 go() 호출로 예약된 바로 그 프레임의
    // 빌드·레이아웃·페인트가 끝난 뒤 실행되므로 그 시점엔 마이페이지 라우트가
    // Navigator에 반영돼 있다. 모달은 Navigator 위 Overlay로 열리므로 마이페이지가
    // 전환 애니메이션 중이어도 문제없다. 그 이상 프레임을 기다릴 필요는 없다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = router.routerDelegate.navigatorKey.currentContext;
      if (context == null || !context.mounted) return;
      showPendingMemberModal(context, storeId);
    });
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
