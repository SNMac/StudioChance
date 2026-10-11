import { HolidayDays } from './holiday_days.js';

/**
 * 공공데이터포털 한국천문연구원 특일 정보 — 공휴일 정보 조회(getRestDeInfo).
 * https://www.data.go.kr/data/15012690/openapi.do
 */
export const REST_DE_INFO_URL =
  'https://apis.data.go.kr/B090041/openapi/service/SpcdeInfoService/getRestDeInfo';

/**
 * 한 달 치 조회 URL. `solMonth` 생략 시 동작이 문서마다 달라 월 단위로 조회한다.
 * 한 달 공휴일은 많아야 몇 건이지만 기본값(10건)에 기대지 않도록 `numOfRows`를 넉넉히 준다.
 *
 * 공공데이터포털이 보여주는 인증키는 URL 인코딩된 형태(`%2B` 등)일 수 있다. 그대로 다시
 * 인코딩하면 `%`가 `%25`가 되어 미등록 키 오류가 나므로 먼저 디코딩한다. 인코딩되지 않은
 * 키에는 `%`가 없어 디코딩해도 그대로다.
 */
export function restDeInfoUrl(serviceKey: string, year: number, month: number): string {
  const params = new URLSearchParams({
    serviceKey: decodeURIComponent(serviceKey),
    solYear: String(year),
    solMonth: String(month).padStart(2, '0'),
    numOfRows: '100',
    _type: 'json',
  });
  return `${REST_DE_INFO_URL}?${params}`;
}

interface RestDeInfoItem {
  dateName: string;
  isHoliday: 'Y' | 'N';
  /** yyyyMMdd 숫자 */
  locdate: number;
}

/**
 * getRestDeInfo JSON 응답 → 공휴일(`isHoliday=Y`) 날짜별 이름.
 *
 * 응답 형태가 건수에 따라 다르다: 2건 이상은 `items.item`이 배열, 1건은 객체,
 * 0건은 `items`가 빈 문자열이다. 정상 응답(`resultCode` "00")이 아니면 예외를 던진다 —
 * 실패를 "공휴일 없음"으로 저장하면 그 연도의 예측 공휴일을 지워버리기 때문이다.
 */
export function parseRestDeInfo(json: unknown): HolidayDays {
  const response = (json as { response?: RestDeInfoResponse }).response;
  const resultCode = response?.header?.resultCode;
  if (resultCode !== '00') {
    throw new Error(
      `특일 정보 API 오류: ${response?.header?.resultMsg ?? JSON.stringify(json)}`,
    );
  }

  const rawItem = typeof response?.body?.items === 'object' ? response.body.items.item : undefined;
  const items = rawItem === undefined ? [] : Array.isArray(rawItem) ? rawItem : [rawItem];

  const days: HolidayDays = {};
  for (const item of items) {
    if (item.isHoliday !== 'Y') continue;
    const key = locdateKey(item.locdate);
    days[key] = [...(days[key] ?? []), item.dateName];
  }
  return days;
}

interface RestDeInfoResponse {
  header?: { resultCode?: string; resultMsg?: string };
  body?: { items: { item?: RestDeInfoItem | RestDeInfoItem[] } | '' };
}

/** 20260501 → '2026-05-01' */
function locdateKey(locdate: number): string {
  const raw = String(locdate);
  return `${raw.slice(0, 4)}-${raw.slice(4, 6)}-${raw.slice(6, 8)}`;
}
