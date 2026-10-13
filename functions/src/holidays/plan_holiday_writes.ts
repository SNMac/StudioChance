import { HolidayDays } from './holiday_days.js';

/** `holidays/{year}` 문서 중 쓰기 판단에 필요한 부분. */
export interface HolidayYearDoc {
  days: HolidayDays;
  /** 덮어쓰기 판단용 내부 값. 앱은 읽지 않는다 (ADR-0002). */
  source: 'official' | 'predicted';
}

export interface HolidayWrite extends HolidayYearDoc {
  year: number;
}

/**
 * 연도별로 어떤 `holidays/{year}` 문서를 써야 하는지 결정한다 (ADR-0002).
 *
 * - 공식 공휴일이 있으면 그 연도를 통째로 공식 공휴일로 교체한다
 * - 공식 공휴일이 없으면(미발표·조회 실패) 이미 있는 공식 문서는 그대로 두고, 아니면 예측으로 채운다
 * - 쓸 내용이 기존 문서와 같으면 쓰지 않는다
 *
 * @param official 이번 동기화에서 조회에 성공한 연도의 공식 공휴일. 빈 객체는 미발표다.
 *                 일부 월만 성공한 연도는 넣지 않아야 한다 — 일부만으로 교체하면 공휴일이 사라진다.
 */
export function planHolidayWrites(params: {
  existing: Map<number, HolidayYearDoc>;
  official: Map<number, HolidayDays>;
  predicted: Map<number, HolidayDays>;
}): HolidayWrite[] {
  const { existing, official, predicted } = params;
  const years = [...new Set([...existing.keys(), ...official.keys(), ...predicted.keys()])].sort(
    (a, b) => a - b,
  );

  const writes: HolidayWrite[] = [];
  for (const year of years) {
    const current = existing.get(year);
    const desired = desiredDoc(official.get(year), predicted.get(year), current);
    if (desired && !isSameDoc(current, desired)) writes.push({ year, ...desired });
  }
  return writes;
}

function desiredDoc(
  official: HolidayDays | undefined,
  predicted: HolidayDays | undefined,
  current: HolidayYearDoc | undefined,
): HolidayYearDoc | undefined {
  if (official && Object.keys(official).length > 0) return { days: official, source: 'official' };
  if (current?.source === 'official') return undefined;
  if (predicted) return { days: predicted, source: 'predicted' };
  return undefined;
}

function isSameDoc(a: HolidayYearDoc | undefined, b: HolidayYearDoc): boolean {
  if (!a || a.source !== b.source) return false;
  const aKeys = Object.keys(a.days).sort();
  const bKeys = Object.keys(b.days).sort();
  return (
    aKeys.length === bKeys.length &&
    aKeys.every(
      (key, i) =>
        key === bKeys[i] && JSON.stringify(a.days[key]) === JSON.stringify(b.days[key]),
    )
  );
}
