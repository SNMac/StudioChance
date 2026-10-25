import { FieldValue, getFirestore } from 'firebase-admin/firestore';
import { getMessaging, type TokenMessage } from 'firebase-admin/messaging';
import { logger } from 'firebase-functions/v2';

import { invalidTokensFrom } from './invalid_tokens.js';

/** 알림 문구에 쓸 사용자 표시 이름 (닉네임 → 이름 → '알 수 없는 사용자') */
export async function displayNameOf(uid: string): Promise<string> {
  const userDoc = await getFirestore().doc(`users/${uid}`).get();
  return (
    (userDoc.get('nickname') as string | undefined) ??
    (userDoc.get('name') as string | undefined) ??
    '알 수 없는 사용자'
  );
}

/**
 * [uids]의 모든 기기에 알림을 보내고, 폐기된 토큰은 각자의 FCM 문서에서 지운다.
 *
 * - [buildMessages]: 모은 토큰으로 보낼 메시지를 만든다
 * - [label]: 로그에 남길 알림 이름 (예: '가입 신청 알림')
 * - [logContext]: 로그에 함께 남길 값 (storeId 등)
 */
export async function sendToUsers(params: {
  uids: string[];
  buildMessages: (tokens: string[]) => TokenMessage[];
  label: string;
  logContext: Record<string, unknown>;
}): Promise<void> {
  const { uids, buildMessages, label, logContext } = params;
  if (uids.length === 0) return;

  const db = getFirestore();

  // 토큰 → 소유자 uid. 폐기 토큰 정리 시 어느 문서를 갱신할지 알기 위해 필요하다.
  // 토큰은 users/{uid}/private/fcm에 있다 (firestore.rules 참고).
  // 서브문서의 id는 모두 'fcm'이라 doc.id로 소유자를 되찾을 수 없으므로
  // getAll에 넘긴 순서와 같은 인덱스로 uids와 짝짓는다.
  const ownerUidByToken = new Map<string, string>();
  const fcmDocs = await db.getAll(
    ...uids.map((uid) => db.doc(`users/${uid}/private/fcm`)),
  );
  fcmDocs.forEach((doc, index) => {
    const tokens = (doc.get('tokens') as string[] | undefined) ?? [];
    for (const token of tokens) {
      ownerUidByToken.set(token, uids[index]);
    }
  });

  const tokens = [...ownerUidByToken.keys()];
  if (tokens.length === 0) {
    logger.warn(`수신자 FCM 토큰이 없어 ${label}을 건너뜁니다`, { ...logContext, uids });
    return;
  }

  const response = await getMessaging().sendEach(buildMessages(tokens));

  logger.info(`${label} 발송 완료`, {
    ...logContext,
    successCount: response.successCount,
    failureCount: response.failureCount,
    // 실패 코드를 남겨야 정리 대상이 아닌 영구 실패 토큰을 사후에 식별할 수 있다
    ...(response.failureCount > 0 && {
      failureCodes: response.responses
        .filter((result) => !result.success)
        .map((result) => result.error?.code ?? 'unknown'),
    }),
  });

  const expiredTokens = invalidTokensFrom(response, tokens);
  if (expiredTokens.length === 0) return;

  await Promise.all(
    expiredTokens.map((token) =>
      db.doc(`users/${ownerUidByToken.get(token)}/private/fcm`).update({
        tokens: FieldValue.arrayRemove(token),
      }),
    ),
  );
  logger.info('폐기된 FCM 토큰 정리', { ...logContext, count: expiredTokens.length });
}
