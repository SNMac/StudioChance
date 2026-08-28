import { getFirestore, Timestamp } from 'firebase-admin/firestore';
import { logger } from 'firebase-functions/v2';
import { HttpsError, onCall } from 'firebase-functions/v2/https';

import { isInviteExpired, isValidInviteCode } from './invite_code.js';
import { type AttemptRecord, nextAttemptState } from './rate_limit.js';

type FailureReason = 'invalidCode' | 'notFound' | 'expired' | 'rateLimited';

type LookupResult =
  | {
      ok: true;
      store: {
        storeId: string;
        storeName: string;
        address: string;
        addressDetail: string;
        adminName: string;
      };
    }
  | { ok: false; reason: FailureReason };

/**
 * 초대 코드로 가입 전 화면이 표시할 최소 정보만 조회한다.
 *
 * stores read를 멤버 전용으로 조인 뒤(firestore.rules), 아직 멤버가 아닌
 * 사용자가 넘어야 하는 유일한 경계가 이 함수다. 계좌 정보·memberById·
 * waitingMemberById·inviteInfo는 절대 응답에 넣지 않는다.
 */
export const lookupInviteCode = onCall<{ code?: unknown }, Promise<LookupResult>>(
  {
    region: 'asia-northeast3',
    enforceAppCheck: true,
  },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError('unauthenticated', '로그인이 필요합니다.');
    }

    const db = getFirestore();
    const now = new Date();

    // 브루트포스 제한: 실패한 시도만 센다. 정상 사용자는 오타 몇 번이면 끝나므로
    // 한도에 닿지 않는다. 카운터는 Rules를 정의하지 않아 클라이언트가 볼 수 없다.
    const attemptRef = db.doc(`inviteLookupAttempts/${uid}`);
    const attemptSnap = await attemptRef.get();
    const stored = attemptSnap.data();
    // 기대한 타입이 아니면(수동 조작·손상 등) 기록이 없는 것으로 취급한다.
    // 그렇지 않으면 캐스팅이 이후 write에서 throw해 해당 사용자가
    // 초대 코드 조회를 영구히 못 하게 되는 조용한 고장으로 이어진다.
    const record: AttemptRecord | null =
      typeof stored?.count === 'number' && stored.windowStartAt instanceof Timestamp
        ? { count: stored.count, windowStartAt: stored.windowStartAt.toDate() }
        : null;
    const { blocked, next } = nextAttemptState(record, now);
    if (blocked) {
      logger.warn('초대 코드 조회 시도 한도 초과', { uid });
      return { ok: false, reason: 'rateLimited' };
    }

    const recordFailure = async (reason: FailureReason): Promise<LookupResult> => {
      await attemptRef.set({
        count: next.count,
        windowStartAt: Timestamp.fromDate(next.windowStartAt),
      });
      return { ok: false, reason };
    };

    const code = request.data?.code;
    if (!isValidInviteCode(code)) {
      return recordFailure('invalidCode');
    }

    const snapshot = await db
      .collection('stores')
      .where('inviteInfo.inviteCode', '==', code)
      .limit(1)
      .get();
    if (snapshot.empty) {
      return recordFailure('notFound');
    }

    const storeDoc = snapshot.docs[0];
    const store = storeDoc.data();

    // deletedAt은 softDeleteStore에서만 기록되며, 그 경로는 inviteInfo도 함께
    // null로 만든다. 그래도 방어적으로 확인한다.
    if (store.deletedAt) {
      return recordFailure('notFound');
    }

    const createdAt = store.inviteInfo?.createdAt as Timestamp | undefined;
    if (!createdAt) {
      // 코드가 있는데 발급 시각이 없는 문서 — 만료 판정이 불가능하므로 없는 것으로 본다
      logger.warn('inviteInfo.createdAt이 없는 점포', { storeId: storeDoc.id });
      return recordFailure('notFound');
    }
    if (isInviteExpired(createdAt.toDate(), now)) {
      return recordFailure('expired');
    }

    return {
      ok: true,
      store: {
        storeId: storeDoc.id,
        storeName: (store.name as string | undefined) ?? '',
        address: (store.address as string | undefined) ?? '',
        addressDetail: (store.addressDetail as string | undefined) ?? '',
        adminName: await resolveAdminName(store.memberById),
      },
    };
  },
);

/**
 * 대표 관리자 표시 이름. 찾지 못하면 빈 문자열을 반환한다.
 *
 * nickname을 우선하는 것은 앱의 다른 멤버 표시 경로와 같은 규칙이다
 * (pending_member_modal, 가입 신청 푸시 알림). 기존 점포 확인 화면만
 * name 단독을 써 왔는데, 그쪽이 예외였다.
 *
 * users 문서 조회 실패는 표시용 필드 하나 때문에 조회 전체를 죽이지 않도록
 * 흡수하고 빈 문자열로 대체한다.
 */
async function resolveAdminName(memberById: unknown): Promise<string> {
  if (typeof memberById !== 'object' || memberById === null) return '';

  const adminUid = Object.entries(
    memberById as Record<string, { role?: string }>,
  ).find(([, member]) => member?.role === 'ADMIN')?.[0];
  if (!adminUid) return '';

  try {
    const adminDoc = await getFirestore().doc(`users/${adminUid}`).get();
    // 빈 문자열도 없는 것으로 취급 — ??는 빈 문자열을 통과시키므로 ||를 쓴다.
    const nickname = (adminDoc.get('nickname') as string | undefined) || '';
    const name = (adminDoc.get('name') as string | undefined) || '';
    return nickname || name;
  } catch (error) {
    logger.warn('관리자 표시 이름 조회 실패', { adminUid, error });
    return '';
  }
}
