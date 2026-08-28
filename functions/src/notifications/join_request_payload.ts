import type { TokenMessage } from 'firebase-admin/messaging';

/** 푸시 payload의 `data.type` 값. Flutter의 `joinRequestNotificationType`과 동일해야 한다. */
export const JOIN_REQUEST_TYPE = 'joinRequest';

/**
 * Android 알림 채널 ID.
 * AndroidManifest의 `default_notification_channel_id`,
 * Flutter의 `notificationChannelId`와 반드시 동일해야 한다.
 */
export const ANDROID_CHANNEL_ID = 'sc_default';

type MemberInfo = { role?: string };

/**
 * 점포의 `memberById`에서 ADMIN 역할 uid만 추출한다.
 * 역할 문자열은 Dart `UserRole`의 `@JsonValue`와 동일한 대문자 값이다.
 */
export function adminUidsOf(
  memberById: Record<string, MemberInfo> | undefined,
): string[] {
  return Object.entries(memberById ?? {})
    .filter(([, info]) => info?.role === 'ADMIN')
    .map(([uid]) => uid);
}

/** 알림 본문 문구를 만든다. */
export function buildJoinRequestBody(
  applicantName: string,
  storeName: string,
): string {
  return `${applicantName}님이 ${storeName} 가입을 신청했습니다.`;
}

/**
 * 관리자 기기 토큰마다 가입 신청 알림 메시지를 만든다.
 *
 * NOTE: FCM Admin SDK는 registration token 대신 FID를 권장하며 `token` 필드를
 * deprecated로 표시했다. 현재 앱은 `users/{uid}/private/fcm` 문서의 `tokens` 필드에 registration token을
 * 저장하므로 `token`을 사용한다. FID 마이그레이션은 별도 이슈로 다룬다.
 */
export function buildJoinRequestMessages(params: {
  tokens: string[];
  applicantName: string;
  applicantUid: string;
  storeId: string;
  storeName: string;
}): TokenMessage[] {
  const body = buildJoinRequestBody(params.applicantName, params.storeName);

  return params.tokens.map((token) => ({
    token,
    notification: {
      title: '가입 신청',
      body,
    },
    data: {
      type: JOIN_REQUEST_TYPE,
      storeId: params.storeId,
      applicantUid: params.applicantUid,
    },
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
  }));
}
