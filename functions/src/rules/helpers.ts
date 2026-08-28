import { readFileSync } from 'node:fs';
import { join } from 'node:path';

import {
  initializeTestEnvironment,
  type RulesTestEnvironment,
} from '@firebase/rules-unit-testing';

/** demo- 프리픽스라 자격증명 없이 에뮬레이터만 사용한다 */
export const PROJECT_ID = 'demo-studio-chance';

/**
 * 컴파일 결과는 `functions/lib/rules/helpers.js`에 놓이므로
 * 저장소 루트의 firestore.rules까지 세 단계 올라간다.
 */
const RULES_PATH = join(__dirname, '../../../firestore.rules');

export async function createTestEnv(): Promise<RulesTestEnvironment> {
  return initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: { rules: readFileSync(RULES_PATH, 'utf8') },
  });
}
