import assert from 'node:assert/strict';
import { test } from 'node:test';

import { parseRestDeInfo, restDeInfoUrl } from './rest_de_info.js';

// 특일 정보 API(getRestDeInfo, _type=json) 실제 응답 형태
function response(items: unknown, totalCount: number) {
  return {
    response: {
      header: { resultCode: '00', resultMsg: 'NORMAL SERVICE.' },
      body: { items, numOfRows: 100, pageNo: 1, totalCount },
    },
  };
}

test('조회 URL은 월 단위·JSON으로 요청하고 기본값(10건)보다 넉넉히 받는다', () => {
  const url = new URL(restDeInfoUrl('test-key', 2027, 5));

  assert.equal(url.origin + url.pathname, 'https://apis.data.go.kr/B090041/openapi/service/SpcdeInfoService/getRestDeInfo');
  assert.equal(url.searchParams.get('serviceKey'), 'test-key');
  assert.equal(url.searchParams.get('solYear'), '2027');
  assert.equal(url.searchParams.get('solMonth'), '05');
  assert.equal(url.searchParams.get('numOfRows'), '100');
  assert.equal(url.searchParams.get('_type'), 'json');
});

test('항목이 여러 개면 배열로 온다', () => {
  const json = response(
    {
      item: [
        { dateKind: '01', dateName: '노동절', isHoliday: 'Y', locdate: 20260501, seq: 1 },
        { dateKind: '01', dateName: '어린이날', isHoliday: 'Y', locdate: 20260505, seq: 1 },
      ],
    },
    2,
  );

  assert.deepEqual(parseRestDeInfo(json), {
    '2026-05-01': ['노동절'],
    '2026-05-05': ['어린이날'],
  });
});

test('항목이 하나면 객체로 온다', () => {
  const json = response(
    { item: { dateKind: '01', dateName: '제헌절', isHoliday: 'Y', locdate: 20260717, seq: 1 } },
    1,
  );

  assert.deepEqual(parseRestDeInfo(json), { '2026-07-17': ['제헌절'] });
});

test('항목이 없으면 items가 빈 문자열로 온다', () => {
  assert.deepEqual(parseRestDeInfo(response('', 0)), {});
});

test('같은 날짜의 공휴일 이름을 모두 모으고 isHoliday=N은 제외한다', () => {
  const json = response(
    {
      item: [
        { dateKind: '01', dateName: '어린이날', isHoliday: 'Y', locdate: 20250505, seq: 1 },
        { dateKind: '01', dateName: '부처님오신날', isHoliday: 'Y', locdate: 20250505, seq: 2 },
        { dateKind: '02', dateName: '어버이날', isHoliday: 'N', locdate: 20250508, seq: 1 },
      ],
    },
    3,
  );

  assert.deepEqual(parseRestDeInfo(json), {
    '2025-05-05': ['어린이날', '부처님오신날'],
  });
});

test('정상 응답이 아니면 예외를 던진다', () => {
  const json = {
    response: { header: { resultCode: '30', resultMsg: 'SERVICE_KEY_IS_NOT_REGISTERED_ERROR' } },
  };

  assert.throws(() => parseRestDeInfo(json), /SERVICE_KEY_IS_NOT_REGISTERED_ERROR/);
});

test('게이트웨이 오류 형식이면 예외를 던진다', () => {
  const json = {
    OpenAPI_ServiceResponse: {
      cmmMsgHeader: { errMsg: 'SERVICE ERROR', returnReasonCode: '30' },
    },
  };

  assert.throws(() => parseRestDeInfo(json));
});
