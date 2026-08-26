/// Android 알림 채널 ID
/// - AndroidManifest의 `default_notification_channel_id`
/// - Cloud Functions의 `ANDROID_CHANNEL_ID`
/// 세 곳의 값이 반드시 동일해야 알림이 정상 표시된다.
const String notificationChannelId = 'sc_default';

/// 알림 채널 이름 (기기 설정 화면에 노출)
const String notificationChannelName = '일반 알림';

/// 알림 채널 설명 (기기 설정 화면에 노출)
const String notificationChannelDescription = '가입 신청 등 점포 관련 알림';

/// 가입 신청 푸시의 `data.type` 값
/// - Cloud Functions의 `JOIN_REQUEST_TYPE`과 동일해야 한다.
const String joinRequestNotificationType = 'joinRequest';
