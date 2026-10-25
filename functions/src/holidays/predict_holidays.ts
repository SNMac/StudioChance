import KoreanLunarCalendar from 'korean-lunar-calendar';

import { HolidayDays } from './holiday_days.js';

/**
 * 공식 발표(월력요항) 전인 연도의 공휴일을 현행 법령으로 예측한다 (ADR-0002).
 *
 * 근거 법령 (2026-10 기준 현행):
 * - 「관공서의 공휴일에 관한 규정」 제2조(공휴일), 제3조(대체공휴일)
 *   — 2026-04-30 개정(대통령령 제36290호)으로 노동절·제헌절 추가
 * - 「공직선거법」 제34조(선거일)
 *
 * 임시공휴일, 궐위·보궐 선거, 법령 개정은 예측할 수 없다. 공식 데이터가 들어오면
 * 그 연도를 통째로 교체한다.
 *
 * 법령이 바뀌면 이 파일을 고친다: 공휴일 목록·대체공휴일 대상(규정 제3조),
 * 선거 임기 기준일 상수 `ELECTIONS`(궐위·조기 선거 시).
 * 「공휴일에 관한 법률」과 「관공서의 공휴일에 관한 규정」은 선거일·임시공휴일의
 * **호 번호가 다르다** — 주석에 번호를 적을 때 두 법령을 섞지 않는다.
 *
 * @returns 음력 변환 범위(2050년)를 넘는 연도는 null
 */
export function predictHolidays(year: number): HolidayDays | null {
  const lunar = lunarHolidays(year);
  if (!lunar) return null;

  // 대체공휴일 판정에 쓰는 "제2조제2호부터 제10호까지"의 공휴일 (일요일·선거일·임시공휴일 제외)
  const holidays: Holiday[] = [
    { date: utcDate(year, 1, 1), name: '1월1일', kind: 'none' },
    { date: utcDate(year, 3, 1), name: '삼일절', kind: 'weekend' },
    { date: utcDate(year, 5, 1), name: '노동절', kind: 'weekend' },
    { date: utcDate(year, 5, 5), name: '어린이날', kind: 'weekend' },
    { date: utcDate(year, 6, 6), name: '현충일', kind: 'none' },
    { date: utcDate(year, 7, 17), name: '제헌절', kind: 'weekend' },
    { date: utcDate(year, 8, 15), name: '광복절', kind: 'weekend' },
    { date: utcDate(year, 10, 3), name: '개천절', kind: 'weekend' },
    { date: utcDate(year, 10, 9), name: '한글날', kind: 'weekend' },
    { date: utcDate(year, 12, 25), name: '기독탄신일', kind: 'weekend' },
    ...lunar,
  ];

  const days: HolidayDays = {};
  for (const holiday of holidays) addName(days, holiday.date, holiday.name);
  for (const substitute of substituteHolidays(holidays, days)) {
    addName(days, substitute, '대체공휴일');
  }
  for (const election of electionDays(year, days)) {
    addName(days, election.date, election.name);
  }
  return sortedByDate(days);
}

/**
 * 대체공휴일 종류 (규정 제3조①).
 * - weekend: 토·일과 겹치거나 평일에 다른 공휴일과 겹치면 대체 (제1호·제3호)
 * - sunday: 일요일과 겹치거나 평일에 다른 공휴일과 겹치면 대체 — 설·추석 연휴 (제2호·제3호)
 * - none: 대체하지 않음 — 1월 1일, 현충일
 */
type SubstituteKind = 'weekend' | 'sunday' | 'none';

interface Holiday {
  date: Date;
  name: string;
  kind: SubstituteKind;
}

const SUNDAY = 0;
const SATURDAY = 6;
const WEDNESDAY = 3;
const DAY_MS = 24 * 60 * 60 * 1000;

/** 설날·부처님 오신 날·추석 연휴. 음력 변환 범위를 넘으면 null. */
function lunarHolidays(year: number): Holiday[] | null {
  const seollal = lunarToSolar(year, 1, 1);
  const buddha = lunarToSolar(year, 4, 8);
  const chuseok = lunarToSolar(year, 8, 15);
  if (!seollal || !buddha || !chuseok) return null;

  // 설날 전날은 음력 12월 말일이라 29일·30일이 해마다 다르므로 설날에서 하루를 뺀다
  return [
    { date: addDays(seollal, -1), name: '설날', kind: 'sunday' },
    { date: seollal, name: '설날', kind: 'sunday' },
    { date: addDays(seollal, 1), name: '설날', kind: 'sunday' },
    { date: buddha, name: '부처님오신날', kind: 'weekend' },
    { date: addDays(chuseok, -1), name: '추석', kind: 'sunday' },
    { date: chuseok, name: '추석', kind: 'sunday' },
    { date: addDays(chuseok, 1), name: '추석', kind: 'sunday' },
  ];
}

function lunarToSolar(year: number, month: number, day: number): Date | null {
  const calendar = new KoreanLunarCalendar();
  // 범위를 벗어나면 false를 반환하고 이전 날짜가 남으므로 반드시 확인한다
  if (!calendar.setLunarDate(year, month, day, false)) return null;
  const solar = calendar.getSolarCalendar();
  return utcDate(solar.year, solar.month, solar.day);
}

/**
 * 규정 제3조에 따른 대체공휴일 날짜들.
 *
 * 공휴일 때문에 쉬는 날이 하루 사라질 때마다 대체공휴일이 하나 생긴다.
 * 평일에 두 공휴일이 겹치면 사라지는 날은 하루뿐이므로 하나만 생긴다 (2025-05-05 → 05-06).
 * 대체일은 그 공휴일 다음의 첫 비공휴일이고, 토요일이면 그다음 비공휴일로 넘긴다 (제3조③).
 * 대체일끼리 겹치면 다음 비공휴일까지 대체한다 (제3조②).
 */
function substituteHolidays(holidays: Holiday[], days: HolidayDays): Date[] {
  const byDate = new Map<string, Holiday[]>();
  for (const holiday of holidays) {
    const key = dateKey(holiday.date);
    byDate.set(key, [...(byDate.get(key) ?? []), holiday]);
  }

  const occupied = new Set(Object.keys(days));
  const substitutes: Date[] = [];
  const dates = [...byDate.keys()].sort();
  for (const key of dates) {
    const sameDay = byDate.get(key)!;
    const date = sameDay[0].date;
    for (let i = 0; i < lostDayCount(sameDay, date.getUTCDay()); i++) {
      let candidate = addDays(date, 1);
      while (isNonWorkingDay(candidate, occupied)) candidate = addDays(candidate, 1);
      occupied.add(dateKey(candidate));
      substitutes.push(candidate);
    }
  }
  return substitutes;
}

/** 같은 날 공휴일들 때문에 사라지는 쉬는 날 수 (= 생겨야 할 대체공휴일 수). */
function lostDayCount(sameDay: Holiday[], weekday: number): number {
  if (weekday === SATURDAY) {
    return sameDay.filter((h) => h.kind === 'weekend').length;
  }
  if (weekday === SUNDAY) {
    return sameDay.filter((h) => h.kind !== 'none').length;
  }
  // 평일에 겹치면 대체 대상(weekend·sunday) 공휴일이 하나라도 있어야 생긴다 (제3조①제3호)
  const hasSubstitutable = sameDay.some((h) => h.kind !== 'none');
  return hasSubstitutable ? sameDay.length - 1 : 0;
}

/** 대체공휴일이 될 수 없는 날 — 토요일, 일요일, 이미 공휴일이거나 대체일로 정해진 날. */
function isNonWorkingDay(date: Date, occupied: Set<string>): boolean {
  const weekday = date.getUTCDay();
  return weekday === SATURDAY || weekday === SUNDAY || occupied.has(dateKey(date));
}

/**
 * 임기만료 선거의 기준 임기만료일과 주기 (헌법 제42조·제70조, 지방자치법 제39조·제108조).
 *
 * 궐위·조기 선거나 임기 조정이 생기면 이 상수를 고쳐야 한다.
 * - 대통령: 2025-06-03 궐위선거 당선자 임기만료 2030-06-03
 * - 국회의원: 제22대 임기만료 2028-05-29
 * - 지방선거: 제9회(2026) 당선자 임기만료 2030-06-30
 */
const ELECTIONS = [
  { name: '대통령선거', termEnd: { year: 2030, month: 6, day: 3 }, cycle: 5, daysBefore: 70 },
  { name: '국회의원선거', termEnd: { year: 2028, month: 5, day: 29 }, cycle: 4, daysBefore: 50 },
  { name: '전국동시지방선거', termEnd: { year: 2030, month: 6, day: 30 }, cycle: 4, daysBefore: 30 },
] as const;

/**
 * 공직선거법 제34조: 임기만료일 전 N일 이후 첫 번째 수요일.
 * 그날이 공휴일이거나 전날·다음 날이 공휴일이면 다음 주 수요일로 한다 (제34조②).
 */
function electionDays(year: number, days: HolidayDays): { date: Date; name: string }[] {
  const isHoliday = (date: Date) =>
    date.getUTCDay() === SUNDAY || dateKey(date) in days;

  return ELECTIONS.filter(
    ({ termEnd, cycle }) => (((year - termEnd.year) % cycle) + cycle) % cycle === 0,
  ).map(({ name, termEnd, daysBefore }) => {
    let date = addDays(utcDate(year, termEnd.month, termEnd.day), -daysBefore);
    while (date.getUTCDay() !== WEDNESDAY) date = addDays(date, 1);
    while (isHoliday(date) || isHoliday(addDays(date, -1)) || isHoliday(addDays(date, 1))) {
      date = addDays(date, 7);
    }
    return { date, name };
  });
}

function addName(days: HolidayDays, date: Date, name: string): void {
  const key = dateKey(date);
  days[key] = [...(days[key] ?? []), name];
}

function sortedByDate(days: HolidayDays): HolidayDays {
  return Object.fromEntries(Object.entries(days).sort(([a], [b]) => a.localeCompare(b)));
}

// 날짜 계산은 서버 타임존(UTC)에 흔들리지 않도록 모두 UTC 자정으로 다룬다
function utcDate(year: number, month: number, day: number): Date {
  return new Date(Date.UTC(year, month - 1, day));
}

function addDays(date: Date, amount: number): Date {
  return new Date(date.getTime() + amount * DAY_MS);
}

function dateKey(date: Date): string {
  return date.toISOString().slice(0, 10);
}
