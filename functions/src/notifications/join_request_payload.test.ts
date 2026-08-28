import { test } from 'node:test';
import assert from 'node:assert/strict';

import {
  ANDROID_CHANNEL_ID,
  JOIN_REQUEST_TYPE,
  adminUidsOf,
  buildJoinRequestBody,
  buildJoinRequestMessages,
} from './join_request_payload.js';

test('ADMIN 역할 uid만 추출한다', () => {
  const memberById = {
    admin1: { role: 'ADMIN' },
    staff1: { role: 'STAFF' },
    viewer1: { role: 'VIEWER' },
    admin2: { role: 'ADMIN' },
  };

  assert.deepEqual(adminUidsOf(memberById), ['admin1', 'admin2']);
});

test('memberById가 없으면 빈 배열을 반환한다', () => {
  assert.deepEqual(adminUidsOf(undefined), []);
});

test('role이 없는 멤버는 관리자가 아니다', () => {
  assert.deepEqual(adminUidsOf({ ghost: {} }), []);
});

test('알림 본문은 "[닉네임]님이 [점포명] 가입을 신청했습니다." 형식이다', () => {
  assert.equal(
    buildJoinRequestBody('홍길동', '스튜디오 챈스'),
    '홍길동님이 스튜디오 챈스 가입을 신청했습니다.',
  );
});

test('닉네임·점포명의 앞뒤 공백은 다듬어 공백이 겹치지 않는다', () => {
  assert.equal(
    buildJoinRequestBody(' 홍길동 ', '스튜디오 챈스 '),
    '홍길동님이 스튜디오 챈스 가입을 신청했습니다.',
  );
});

test('토큰마다 메시지를 하나씩 만든다', () => {
  const messages = buildJoinRequestMessages({
    tokens: ['t1', 't2'],
    applicantName: '홍길동',
    applicantUid: 'applicant',
    storeId: 'store1',
    storeName: '스튜디오 챈스',
  });

  assert.equal(messages.length, 2);
  assert.equal(messages[0].token, 't1');
  assert.equal(messages[1].token, 't2');
});

test('메시지에 딥링크용 data와 Android 채널이 담긴다', () => {
  const [message] = buildJoinRequestMessages({
    tokens: ['t1'],
    applicantName: '홍길동',
    applicantUid: 'applicant',
    storeId: 'store1',
    storeName: '스튜디오 챈스',
  });

  assert.deepEqual(message.data, {
    type: JOIN_REQUEST_TYPE,
    storeId: 'store1',
    applicantUid: 'applicant',
  });
  assert.equal(message.notification?.title, '가입 신청');
  assert.equal(
    message.notification?.body,
    '홍길동님이 스튜디오 챈스 가입을 신청했습니다.',
  );
  assert.equal(message.android?.notification?.channelId, ANDROID_CHANNEL_ID);
});

test('토큰이 없으면 빈 배열을 반환한다', () => {
  const messages = buildJoinRequestMessages({
    tokens: [],
    applicantName: '홍길동',
    applicantUid: 'applicant',
    storeId: 'store1',
    storeName: '스튜디오 챈스',
  });

  assert.deepEqual(messages, []);
});
