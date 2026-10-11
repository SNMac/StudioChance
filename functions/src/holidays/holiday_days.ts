/**
 * `holidays/{year}` 문서의 `days` 필드: 날짜 키(`yyyy-MM-dd`) → 그날의 공휴일 이름들.
 *
 * 같은 날 공휴일이 겹칠 수 있어 이름은 목록이다 (예: 2025-05-05 어린이날·부처님오신날).
 * 앱(`HolidayYearModel`, `holidayDateKey`)과 같은 형식을 써야 한다.
 */
export type HolidayDays = Record<string, string[]>;
