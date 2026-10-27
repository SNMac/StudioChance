import type { TokenMessage } from 'firebase-admin/messaging';

import { isAdmin, type MemberInfo } from './member_role.js';
import { buildTokenMessage } from './token_message.js';

/**
 * 푸시 payload의 `data.type` 값. Flutter의 `joinRequestNotificationType`과 동일해야 한다
 * (계약 테스트 `contract/shared_constants.test.ts`가 검사한다).
 */
export const JOIN_REQUEST_TYPE = 'joinRequest';

/**
 * 점포의 `memberById`에서 ADMIN 역할 uid만 추출한다.
 * 역할 문자열은 Dart `UserRole`의 `@JsonValue`와 동일한 대문자 값이다.
 */
export function adminUidsOf(
  memberById: Record<string, MemberInfo> | undefined,
): string[] {
  return Object.entries(memberById ?? {})
    .filter(([, info]) => isAdmin(info))
    .map(([uid]) => uid);
}

/** 알림 본문 문구를 만든다. */
export function buildJoinRequestBody(
  applicantName: string,
  storeName: string,
): string {
  return `${applicantName} 님이 ${storeName} 가입을 신청했습니다.`;
}

/** 관리자 기기 토큰마다 가입 신청 알림 메시지를 만든다. */
export function buildJoinRequestMessages(params: {
  tokens: string[];
  applicantName: string;
  applicantUid: string;
  storeId: string;
  storeName: string;
}): TokenMessage[] {
  const body = buildJoinRequestBody(params.applicantName, params.storeName);

  return params.tokens.map((token) =>
    buildTokenMessage(
      token,
      { title: '가입 신청', body },
      {
        type: JOIN_REQUEST_TYPE,
        storeId: params.storeId,
        applicantUid: params.applicantUid,
      },
    ),
  );
}
