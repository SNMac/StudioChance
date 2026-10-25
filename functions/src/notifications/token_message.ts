import type { TokenMessage } from 'firebase-admin/messaging';

/**
 * Android 알림 채널 ID.
 * AndroidManifest의 `default_notification_channel_id`,
 * Flutter의 `notificationChannelId`와 반드시 동일해야 한다
 * (계약 테스트 `contract/shared_constants.test.ts`가 검사한다).
 */
export const ANDROID_CHANNEL_ID = 'sc_default';

/**
 * 기기 토큰 하나에 보낼 알림 메시지를 만든다. 모든 알림이 같은 채널·소리·배지를 쓴다.
 *
 * NOTE: FCM Admin SDK는 registration token 대신 FID를 권장하며 `token` 필드를
 * deprecated로 표시했다. 현재 앱은 `users/{uid}/private/fcm` 문서의 `tokens` 필드에 registration token을
 * 저장하므로 `token`을 사용한다. FID 마이그레이션은 별도 이슈로 다룬다.
 */
export function buildTokenMessage(
  token: string,
  notification: { title: string; body: string },
  data: Record<string, string>,
): TokenMessage {
  return {
    token,
    notification,
    data,
    android: {
      priority: 'high',
      notification: {
        channelId: ANDROID_CHANNEL_ID,
      },
    },
    apns: {
      payload: {
        aps: {
          sound: 'default',
          badge: 1,
        },
      },
    },
  };
}
