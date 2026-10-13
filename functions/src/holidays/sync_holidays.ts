import { FieldValue, getFirestore } from 'firebase-admin/firestore';
import { logger } from 'firebase-functions/v2';
import { defineSecret } from 'firebase-functions/params';
import { onSchedule } from 'firebase-functions/v2/scheduler';

import { HolidayDays } from './holiday_days.js';
import { HolidayYearDoc, planHolidayWrites } from './plan_holiday_writes.js';
import { predictHolidays } from './predict_holidays.js';
import { parseRestDeInfo, restDeInfoUrl } from './rest_de_info.js';

/** 공공데이터포털 특일 정보 API 인증키. dev·prod 각각 `firebase functions:secrets:set`으로 넣는다. */
const DATA_GO_KR_SERVICE_KEY = defineSecret('DATA_GO_KR_SERVICE_KEY');

/** 공식 공휴일을 조회하는 범위 (올해 기준). 작년은 최초 배포 때 지난 예약 수정에 대비해 채운다. */
const OFFICIAL_YEAR_OFFSETS = [-1, 0, 1, 2];

/**
 * 예측 공휴일로 채우는 마지막 연도 — `korean-lunar-calendar`가 양력 2050-12-31까지만 지원한다.
 * 올해부터 이 연도까지 채우며, 2051년 이후 예약은 공휴일 여부를 확인할 수 없다.
 */
const PREDICTED_LAST_YEAR = 2050;

const KST_OFFSET_MS = 9 * 60 * 60 * 1000;

/**
 * 매일 04:00 KST에 `holidays/{year}` 공휴일 달력을 동기화한다 (ADR-0001·0002).
 *
 * 배포 직후에는 다음 날 새벽까지 데이터가 없으므로, Cloud Scheduler 콘솔에서 이 작업을
 * 한 번 "강제 실행"해야 한다.
 */
export const syncHolidays = onSchedule(
  {
    schedule: '0 4 * * *',
    timeZone: 'Asia/Seoul',
    region: 'asia-northeast3',
    secrets: [DATA_GO_KR_SERVICE_KEY],
  },
  async () => {
    // 서버 시계는 UTC라 1월 1일 0~9시에 작년으로 계산되지 않도록 KST로 연도를 구한다
    const thisYear = new Date(Date.now() + KST_OFFSET_MS).getUTCFullYear();
    const officialYears = OFFICIAL_YEAR_OFFSETS.map((offset) => thisYear + offset);

    const official = new Map<number, HolidayDays>();
    for (const year of officialYears) {
      try {
        official.set(year, await fetchOfficialYear(DATA_GO_KR_SERVICE_KEY.value(), year));
      } catch (error) {
        // 일부 월만 받은 채로 교체하면 공휴일이 사라지므로 그 연도는 이번에 건너뛴다
        logger.error('공식 공휴일 조회 실패 — 기존 문서를 유지한다', {
          year,
          error: describeError(error),
        });
      }
    }

    const predicted = new Map<number, HolidayDays>();
    for (let year = thisYear; year <= PREDICTED_LAST_YEAR; year++) {
      const days = predictHolidays(year);
      if (days) predicted.set(year, days);
    }

    const db = getFirestore();
    const years = [...new Set([...officialYears, ...predicted.keys()])];
    const snapshots = await db.getAll(...years.map((year) => db.doc(`holidays/${year}`)));
    const existing = new Map<number, HolidayYearDoc>();
    snapshots.forEach((snapshot, index) => {
      if (snapshot.exists) existing.set(years[index], snapshot.data() as HolidayYearDoc);
    });

    const writes = planHolidayWrites({ existing, official, predicted });
    if (writes.length === 0) {
      logger.info('공휴일 달력 변경 없음', { years });
      return;
    }

    const batch = db.batch();
    for (const { year, days, source } of writes) {
      batch.set(db.doc(`holidays/${year}`), {
        days,
        source,
        syncedAt: FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
    logger.info('공휴일 달력 갱신', {
      writes: writes.map(({ year, source }) => ({ year, source })),
    });
  },
);

/** 한 해의 공식 공휴일. 한 달이라도 실패하면 예외를 던진다. */
async function fetchOfficialYear(serviceKey: string, year: number): Promise<HolidayDays> {
  const days: HolidayDays = {};
  for (let month = 1; month <= 12; month++) {
    const response = await fetch(restDeInfoUrl(serviceKey, year, month));
    // 게이트웨이 오류(미등록 키 등)는 HTTP 4xx와 다른 형식의 본문으로 오므로 JSON 파싱 전에 거른다
    if (!response.ok) {
      const body = (await response.text()).slice(0, 300);
      throw new Error(`HTTP ${response.status} (${year}-${month}): ${body}`);
    }
    Object.assign(days, parseRestDeInfo(await response.json()));
  }
  return days;
}

/**
 * 로그용 오류 설명. Error 객체는 구조화 로그에서 {}로 직렬화되므로 문자열로 꺼낸다.
 * fetch는 네트워크 실패를 모두 "fetch failed"로 던지고 실제 원인(연결 시간 초과 등)을
 * `cause`에 담으므로 함께 남긴다.
 */
function describeError(error: unknown): string {
  if (!(error instanceof Error)) return String(error);
  const cause = error.cause;
  if (cause === undefined) return error.message;
  const code = (cause as { code?: unknown }).code;
  const causeText = cause instanceof Error ? cause.message : String(cause);
  return `${error.message} (cause: ${code ? `${String(code)} ` : ''}${causeText})`;
}
