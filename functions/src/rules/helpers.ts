import { readFileSync } from 'node:fs';
import { join } from 'node:path';

import {
  initializeTestEnvironment,
  type RulesTestEnvironment,
} from '@firebase/rules-unit-testing';

/**
 * 테스트 파일마다 고유한 프로젝트 ID를 쓴다.
 *
 * node --test는 파일을 별도 프로세스에서 병렬 실행하는데, 같은 프로젝트를 공유하면
 * 한 파일의 clearFirestore()가 다른 파일의 시드를 지워 결과가 매번 달라진다.
 * demo- 프리픽스는 유지되므로 자격증명은 여전히 필요 없다.
 */
export function projectIdFor(suffix: string): string {
  return `demo-studio-chance-${suffix}`;
}

/**
 * 컴파일 결과는 `functions/lib/rules/helpers.js`에 놓이므로
 * 저장소 루트의 firestore.rules까지 세 단계 올라간다.
 */
const RULES_PATH = join(__dirname, '../../../firestore.rules');

export async function createTestEnv(suffix: string): Promise<RulesTestEnvironment> {
  return initializeTestEnvironment({
    projectId: projectIdFor(suffix),
    firestore: { rules: readFileSync(RULES_PATH, 'utf8') },
  });
}
