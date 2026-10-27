import {
  FieldValue,
  type Firestore,
  getFirestore,
  Timestamp,
  type Transaction,
} from 'firebase-admin/firestore';
import { HttpsError, onCall } from 'firebase-functions/v2/https';

import { decideInviteIssue, generateInviteCode } from './invite_code.js';

/** 코드가 다른 점포와 겹칠 때 다시 뽑는 횟수. 32^6 공간이라 두 번째에서 끝나야 정상이다 */
const MAX_CODE_ATTEMPTS = 5;

type IssueOutcome =
  | { ok: true; inviteCode: string; createdAt: Date }
  | { ok: false; reason: 'notFound' | 'permissionDenied' };

/**
 * 점포의 초대 코드를 발급한다 (ADR-0006).
 *
 * 만료 판정과 발급 시각을 모두 서버 시각으로 정한다. 클라이언트는 Rules상
 * inviteInfo를 null로만 쓸 수 있으므로 발급 시각을 미래로 적어 유효 시간을
 * 늘릴 수 없다.
 */
export async function issueInviteCodeFor(
  db: Firestore,
  input: {
    uid: string;
    storeId: string;
    forceRegenerate: boolean;
    clock?: () => Date;
    generateCode?: () => string;
  },
): Promise<IssueOutcome> {
  const clock = input.clock ?? (() => new Date());
  const generateCode = input.generateCode ?? (() => generateInviteCode());
  const storeRef = db.doc(`stores/${input.storeId}`);

  return db.runTransaction(async (tx) => {
    const snap = await tx.get(storeRef);
    // 트랜잭션이 재시도되면 시각도 다시 읽는다
    const now = clock();
    const createdAt = snap.get('inviteInfo.createdAt') as Timestamp | undefined;

    const decision = decideInviteIssue({
      uid: input.uid,
      exists: snap.exists,
      deletedAt: snap.get('deletedAt'),
      memberById: snap.get('memberById'),
      inviteCode: snap.get('inviteInfo.inviteCode'),
      inviteCreatedAt: createdAt instanceof Timestamp ? createdAt.toDate() : null,
      forceRegenerate: input.forceRegenerate,
      now,
    });
    if (decision.kind === 'denied') return { ok: false, reason: decision.reason };
    if (decision.kind === 'reuse') {
      return { ok: true, inviteCode: decision.inviteCode, createdAt: decision.createdAt };
    }

    const inviteCode = await pickUnusedCode(tx, db, generateCode);
    tx.update(storeRef, {
      inviteInfo: { inviteCode, createdAt: Timestamp.fromDate(now) },
      updatedAt: FieldValue.serverTimestamp(),
    });
    return { ok: true, inviteCode, createdAt: now };
  });
}

/**
 * 어느 점포도 쓰고 있지 않은 코드를 고른다.
 *
 * 만료된 코드도 겹치는 것으로 본다. lookupInviteCode는 코드가 같은 점포를 하나만
 * 가져오므로(findStoreByInviteCode의 limit(1)), 다른 점포에 만료된 같은 코드가
 * 남아 있으면 이 점포의 유효한 코드가 "만료"로 조회될 수 있다.
 * 이 점포의 현재 코드와 같은 값도 다시 뽑는다 — 재발급이 옛 코드를 그대로 남기면 안 된다.
 */
async function pickUnusedCode(
  tx: Transaction,
  db: Firestore,
  generateCode: () => string,
): Promise<string> {
  for (let attempt = 0; attempt < MAX_CODE_ATTEMPTS; attempt++) {
    const code = generateCode();
    const existing = await tx.get(
      db.collection('stores').where('inviteInfo.inviteCode', '==', code).limit(1),
    );
    if (existing.empty) return code;
  }
  throw new Error(`겹치지 않는 초대 코드를 ${MAX_CODE_ATTEMPTS}번 안에 찾지 못했다`);
}

/**
 * 관리자가 초대 코드를 발급·재발급한다.
 *
 * 도메인 실패는 lookupInviteCode와 달리 HttpsError로 보낸다. permission-denied·not-found가
 * 앱의 공용 오류 변환(handleFirestoreError)에서 갖는 일반 의미와 그대로 맞기 때문이다.
 */
export const issueInviteCode = onCall<
  { storeId?: unknown; forceRegenerate?: unknown },
  Promise<{ inviteCode: string; createdAtMillis: number }>
>(
  {
    region: 'asia-northeast3',
    enforceAppCheck: true,
  },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError('unauthenticated', '로그인이 필요합니다.');
    }

    const storeId = request.data?.storeId;
    if (typeof storeId !== 'string' || storeId === '' || storeId.includes('/')) {
      throw new HttpsError('invalid-argument', '점포 ID가 올바르지 않습니다.');
    }

    const outcome = await issueInviteCodeFor(getFirestore(), {
      uid,
      storeId,
      forceRegenerate: request.data?.forceRegenerate === true,
    });
    if (!outcome.ok) {
      throw outcome.reason === 'notFound'
        ? new HttpsError('not-found', '점포를 찾을 수 없습니다.')
        : new HttpsError('permission-denied', '초대 코드를 발급할 권한이 없습니다.');
    }

    return {
      inviteCode: outcome.inviteCode,
      createdAtMillis: outcome.createdAt.getTime(),
    };
  },
);
