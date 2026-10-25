import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { join } from 'node:path';

import { INVITE_CODE_AVAILABLE_MIN } from '../invite/invite_code.js';
import { JOIN_REQUEST_TYPE } from '../notifications/join_request_payload.js';
import { ROLE_DISPLAY_NAMES } from '../notifications/member_role.js';
import {
  ADMIN_DELEGATED_TYPE,
  JOIN_APPROVED_TYPE,
  JOIN_REJECTED_TYPE,
  MEMBER_LEFT_TYPE,
  MEMBER_REMOVED_TYPE,
  STORE_DELETED_TYPE,
} from '../notifications/membership_change.js';
import { ANDROID_CHANNEL_ID } from '../notifications/token_message.js';

/**
 * Functions와 앱이 공유하는 값의 계약 테스트.
 *
 * 값이 어긋나도 오류 없이 알림이 안 뜨거나 만료 판정이 갈라질 뿐이라 테스트로 고정한다.
 * 새 공유 값을 추가하면 양쪽 정의에 이 파일을 가리키는 주석을 달고 여기에 검사를 추가한다.
 * 선언 형식이 바뀌어 값을 찾지 못하면 실패한다 — 검사가 조용히 빠지지 않게 하기 위함이다.
 */

/** 컴파일 결과는 `functions/lib/contract/`에 놓이므로 저장소 루트까지 세 단계 올라간다 */
const REPO_ROOT = join(__dirname, '../../..');

function read(relativePath: string): string {
  return readFileSync(join(REPO_ROOT, relativePath), 'utf8');
}

function capture(source: string, pattern: RegExp, label: string): string {
  const match = source.match(pattern);
  assert.ok(match, `${label}을(를) 찾지 못했다 — 선언 형식이 바뀌었으면 이 테스트도 고친다`);
  return match[1];
}

const notificationConstants = read('lib/constants/notification_constants.dart');

test('알림 data.type 값이 Functions와 앱에서 같다', () => {
  const dartTypes = [
    ...notificationConstants.matchAll(/const String \w+NotificationType = '(\w+)';/g),
  ].map((match) => match[1]);
  assert.ok(dartTypes.length > 0, 'notification_constants.dart에서 NotificationType 상수를 찾지 못했다');

  const functionsTypes = [
    JOIN_REQUEST_TYPE,
    ADMIN_DELEGATED_TYPE,
    MEMBER_LEFT_TYPE,
    MEMBER_REMOVED_TYPE,
    JOIN_APPROVED_TYPE,
    JOIN_REJECTED_TYPE,
    STORE_DELETED_TYPE,
  ];

  assert.deepEqual(new Set(dartTypes), new Set(functionsTypes));
});

test('Android 알림 채널 ID가 Functions·앱·AndroidManifest에서 같다', () => {
  const dartChannelId = capture(
    notificationConstants,
    /const String notificationChannelId = '(\w+)';/,
    'notificationChannelId',
  );
  const manifestChannelId = capture(
    read('android/app/src/main/AndroidManifest.xml'),
    /default_notification_channel_id"\s*android:value="(\w+)"/,
    'default_notification_channel_id',
  );

  assert.equal(dartChannelId, ANDROID_CHANNEL_ID);
  assert.equal(manifestChannelId, ANDROID_CHANNEL_ID);
});

test('초대 코드 유효 시간이 Functions와 앱에서 같다', () => {
  const dartMinutes = capture(
    read('lib/constants/data_constants.dart'),
    /const int storeInviteCodeAvailableMin = (\d+);/,
    'storeInviteCodeAvailableMin',
  );

  assert.equal(Number(dartMinutes), INVITE_CODE_AVAILABLE_MIN);
});

test('멤버 역할 값과 표시 이름이 Functions와 앱에서 같다', () => {
  const userRole = read('lib/common/enums/user_role.dart');
  const jsonValueByEnumName = new Map(
    [...userRole.matchAll(/@JsonValue\('(\w+)'\)\s+(\w+)/g)].map((match) => [match[2], match[1]]),
  );
  const displayNameBlock = capture(
    userRole,
    /get displayName => switch \(this\) \{([\s\S]*?)\};/,
    'UserRole.displayName',
  );
  const dartDisplayNames = Object.fromEntries(
    [...displayNameBlock.matchAll(/UserRole\.(\w+) => '([^']+)'/g)]
      .map(([, enumName, displayName]) => [jsonValueByEnumName.get(enumName), displayName])
      // 'NONE'은 점포 멤버 역할로 저장되지 않으므로 Functions가 다루지 않는다
      .filter(([jsonValue]) => jsonValue !== 'NONE'),
  );

  assert.deepEqual(dartDisplayNames, ROLE_DISPLAY_NAMES);
});
