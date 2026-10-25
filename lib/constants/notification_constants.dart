/// Android 알림 채널 ID
/// - AndroidManifest의 `default_notification_channel_id`
/// - Cloud Functions의 `ANDROID_CHANNEL_ID`
/// 세 곳의 값이 반드시 동일해야 알림이 정상 표시된다 (계약 테스트
/// `functions/src/contract/shared_constants.test.ts`가 검사한다).
const String notificationChannelId = 'sc_default';

/// 알림 채널 이름 (기기 설정 화면에 노출)
const String notificationChannelName = '일반 알림';

/// 알림 채널 설명 (기기 설정 화면에 노출)
const String notificationChannelDescription = '가입 신청 등 점포 관련 알림';

// 푸시 `data.type` 값. 이름이 `NotificationType`으로 끝나는 상수는 모두 Cloud Functions의
// 같은 값과 동일해야 한다 — 계약 테스트 `functions/src/contract/shared_constants.test.ts`가
// 이 이름 규칙으로 찾아 비교한다.

/// 가입 신청 (`functions/src/notifications/join_request_payload.ts`의 `JOIN_REQUEST_TYPE`)
const String joinRequestNotificationType = 'joinRequest';

// 멤버 구성 변화 (`functions/src/notifications/membership_change.ts`)

/// 관리자 위임 — 새 관리자가 받는다
const String adminDelegatedNotificationType = 'adminDelegated';

/// 점포 나가기 — 관리자가 받는다
const String memberLeftNotificationType = 'memberLeft';

/// 추방 — 추방된 사람이 받는다
const String memberRemovedNotificationType = 'memberRemoved';

/// 가입 승인 — 신청자가 받는다
const String joinApprovedNotificationType = 'joinApproved';

/// 가입 거절 — 신청자가 받는다
const String joinRejectedNotificationType = 'joinRejected';

/// 점포 삭제 — 삭제한 사람을 뺀 멤버·승인 대기자가 받는다
const String storeDeletedNotificationType = 'storeDeleted';
