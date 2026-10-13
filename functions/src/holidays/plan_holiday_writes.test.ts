import assert from 'node:assert/strict';
import { test } from 'node:test';

import { planHolidayWrites } from './plan_holiday_writes.js';

const predicted2027 = { '2027-05-13': ['부처님오신날'] };
const official2027 = { '2027-05-13': ['부처님오신날'], '2027-05-14': ['임시공휴일'] };

test('공식 공휴일이 있으면 예측 공휴일 문서를 연도째 교체한다', () => {
  const writes = planHolidayWrites({
    existing: new Map([[2027, { days: predicted2027, source: 'predicted' }]]),
    official: new Map([[2027, official2027]]),
    predicted: new Map([[2027, predicted2027]]),
  });

  assert.deepEqual(writes, [{ year: 2027, days: official2027, source: 'official' }]);
});

test('공식 응답이 비어 있으면(미발표) 예측 공휴일로 채운다', () => {
  const writes = planHolidayWrites({
    existing: new Map(),
    official: new Map([[2028, {}]]),
    predicted: new Map([[2028, { '2028-01-01': ['1월1일'] }]]),
  });

  assert.deepEqual(writes, [
    { year: 2028, days: { '2028-01-01': ['1월1일'] }, source: 'predicted' },
  ]);
});

test('예측 공휴일은 이미 있는 공식 공휴일 문서를 덮지 않는다', () => {
  const writes = planHolidayWrites({
    existing: new Map([[2027, { days: official2027, source: 'official' }]]),
    official: new Map(), // 이번 동기화에서 조회하지 못했다
    predicted: new Map([[2027, predicted2027]]),
  });

  assert.deepEqual(writes, []);
});

test('내용이 같으면 쓰지 않는다 (날짜 키 순서는 무관)', () => {
  const writes = planHolidayWrites({
    existing: new Map([
      [
        2027,
        {
          days: { '2027-05-14': ['임시공휴일'], '2027-05-13': ['부처님오신날'] },
          source: 'official',
        },
      ],
    ]),
    official: new Map([[2027, official2027]]),
    predicted: new Map(),
  });

  assert.deepEqual(writes, []);
});

test('공식 공휴일이 바뀌면(임시공휴일 지정) 다시 쓴다', () => {
  const writes = planHolidayWrites({
    existing: new Map([
      [2027, { days: { '2027-05-13': ['부처님오신날'] }, source: 'official' }],
    ]),
    official: new Map([[2027, official2027]]),
    predicted: new Map(),
  });

  assert.deepEqual(writes, [{ year: 2027, days: official2027, source: 'official' }]);
});
