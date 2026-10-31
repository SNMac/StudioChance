# 운영 절차

배포·디버그 환경 준비처럼 사람이 직접 하는 절차를 모은다. 배포 순서 같은 규칙은 CLAUDE.md에 있다.

## Firebase 프로젝트 설정 파일

`firebase.json`/`.firebaserc`는 gitignore 처리되어 저장소에 없다. 새로 clone한 환경에서 배포하려면 아래 내용을 직접 만든다.
에뮬레이터 테스트(Rules·Functions 쿼리)용 설정은 별도로 추적하는 `firebase.emulator.json`을 쓰므로 이 파일들이 없어도 테스트는 돈다.

```json
// firebase.json (Functions·Rules 배포에 필요한 부분만)
{
  "firestore": {
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  },
  "functions": [
    {
      "source": "functions",
      "codebase": "default",
      "ignore": ["node_modules", ".git", "firebase-debug.log", "firebase-debug.*.log"],
      "predeploy": ["npm --prefix \"$RESOURCE_DIR\" run build"]
    }
  ]
}
```

```json
// .firebaserc (-P dev / -P prod 별칭)
{
  "projects": {
    "default": "studio-chance",
    "dev": "studio-chance",
    "prod": "studio-chance-prod"
  }
}
```

## Cloud Functions 배포

- `firebase deploy --only functions -P dev` / `-P prod` (Blaze 요금제 필요)
- Rules는 `firebase deploy --only firestore:rules -P dev` / `-P prod`
- 인덱스와 TTL 정책은 `firestore.indexes.json`에 있고 `firebase deploy --only firestore:indexes -P dev` / `-P prod`로 배포한다.
  dev 콘솔이나 오류 링크로 만든 인덱스는 `firebase firestore:indexes -P dev`로 내보내 이 파일에 반영한다.
  파일에 없는 인덱스가 프로젝트에 있으면 배포가 지울지 묻는다 — 콘솔에서 만든 것이면 먼저 이 파일에 옮긴다
- **배포 전 Secret 설정**(dev·prod 각각, 최초 1회): `firebase functions:secrets:set DATA_GO_KR_SERVICE_KEY -P dev`
- **`syncHolidays` 첫 배포 직후 1회 수동 실행**: 스케줄 첫 실행이 다음 날 새벽이므로 Cloud Scheduler 콘솔에서 `syncHolidays` 작업을 "강제 실행"한다

## TTL·cascade 동작 확인 (dev)

TTL과 `cascadeStoreDelete`는 에뮬레이터에서 돌릴 수 없어 dev에서 확인한다. TTL 정책은 켠 뒤 활성화까지 시간이 걸리고, 만료 문서는 만료 후 최대 24시간 안에 지워진다.

1. `firebase deploy --only functions -P dev` → `firebase deploy --only firestore:indexes -P dev` (순서를 바꾸면 그 사이 지워진 점포의 예약이 고아가 된다)
   - `cascadeStoreDelete`는 재시도(`retry: true`)를 켜서 처음 배포할 때 CLI가 `--force`를 요구한다. 재시도해도 결과가 같은 함수라 붙여도 된다
2. TTL 정책과 `reservations.writerId` 인덱스가 `CREATING`에서 벗어났는지 본다 (첫 배포 후 수십 분 걸릴 수 있다)
   - `gcloud firestore fields ttls list --project studio-chance` (prod는 `studio-chance-prod`)
   - `gcloud firestore indexes fields describe writerId --collection-group=reservations --project studio-chance`
   - 인덱스가 준비되기 전에 `purgeDeletedUsers`를 실행하면 `FAILED_PRECONDITION: ... index is not ready yet`으로 실패한다
   - **TTL 정책이 처음 켜질 때 이미 만료돼 있던 점포는 `cascadeStoreDelete` 없이 지워진다.** dev에서 정책이 ACTIVE가 되는 순간
     만료된 점포가 일괄 삭제됐지만 트리거가 호출되지 않아 예약이 고아로 남았다(2026-10-27). 정책을 켜기 전에 `expiresAt`이 지난
     점포가 있는지 보고, 있으면 먼저 콘솔에서 점포 문서를 지워 cascade를 돌린다
3. 테스트 문서는 정책이 ACTIVE가 된 **뒤에** 넣는다 (위 이유로 그 전에 넣은 문서는 cascade 확인에 쓸 수 없다)
   - `stores/ttl-test`: `deletedAt`·`expiresAt`을 과거 시각으로, 하위에 `reservations/r1`·`r2`.
     `memberById`에 `ttl-user: {role: 'STAFF'}`를 넣고 `users/ttl-user`의 `storeById.ttl-test`에 항목을 둔다
   - `inviteLookupAttempts/ttl-test`: `count: 1`, `windowStartAt`·`expiresAt`을 과거 시각으로
4. 24시간 안에 점포·예약 2건·시도 문서와 `users/ttl-user`의 `storeById.ttl-test` 항목이 모두 사라졌는지 본다. 점포만 사라지고 예약이나 항목이 남으면 `cascadeStoreDelete` 로그를 본다
5. `purgeDeletedUsers`는 Cloud Scheduler 콘솔에서 "강제 실행"(또는 `gcloud scheduler jobs run firebase-schedule-purgeDeletedUsers-asia-northeast3 --location asia-northeast3 --project studio-chance`)해 확인한다. `users/purge-test`에 `{nickname, deletedAt}`만 넣되 `deletedAt`을 8일 이상 전으로 두고 실행하면 지워지고,
   `writerId: 'purge-test'`인 예약이 어느 점포에든 있으면 남아야 한다

## App Check 디버그 토큰 등록 (dev 실기기)

초대 코드 Callable(`lookupInviteCode`·`issueInviteCode`·`getServerTime`)은 App Check를 강제한다. dev 실기기에서 디버그 토큰을 등록하지 않으면
초대 코드 조회·발급이 전부 "권한이 없습니다"로 떨어진다(`mapFirebaseCode`가 `unauthenticated` → `StorePermissionDeniedException`).
`getServerTime`은 실패해도 화면에 드러나지 않고 남은 시간이 기기 시계로 표시될 뿐이다.
prod는 Play Integrity / App Attest를 쓰므로 이 절차가 필요 없다.

1. **원인 확인**: 화면에는 원인이 드러나지 않으므로 서버 로그로 판별한다.
   `firebase functions:log --only lookupInviteCode -P dev`에 `{"verifications":{"auth":"VALID","app":"INVALID"}}`가 찍히면 이 경우다
2. **토큰 찾기**: 토큰은 **기기·앱 설치 단위**라 기기를 바꾸거나 앱을 재설치하면 새로 발급된다
   - Android: 앱 시작 시 logcat의 `DebugAppCheckProvider`에 출력
   - iOS: Xcode 콘솔에 `App Check debug token:`으로 출력. 안 보이면 스킴의 Arguments Passed on Launch에
     `-FIRDebugEnabled`를 추가한다 (`main_dev.dart`는 Android·Apple **양쪽** 디버그 Provider를 켠다)
3. **등록**: Firebase 콘솔 **Security > App Check > Apps** 탭에서 해당 앱의 ⋮ 메뉴 → **Manage debug tokens**.
   Android 앱과 iOS 앱은 **각각 따로** 등록해야 한다.
   Firebase CLI에는 `appcheck` 명령이 없다 — 자동화가 필요하면 App Check REST API의 `projects.apps.debugTokens`를 쓴다

## Sign in with Apple 설정 (dev·prod)

Apple 로그인은 Apple이 준 idToken만 검증하므로 아래 설정이 틀려도 성공한다. 틀린 설정은 계정 삭제의 Apple revoke에서야 드러나고,
revoke가 실패해도 삭제는 계속되므로(#31) 화면에는 아무것도 보이지 않는다.

- **증상**: 계정 삭제 로그에 `Apple revoke 실패`가 찍히고 예외가 `invalid-credential`, 메시지가 `HttpMetadata{status=400, ...}`다.
  Apple ID 이메일로 연결 해제 메일이 오지 않는다
- **Apple Developer > Identifiers**: primary App ID `com.snmac.studio-chance`의 Sign in with Apple 그룹에 아래가 모두 있어야 한다
  - dev App ID `com.snmac.studio-chance.dev`
  - Services ID `com.snmac.studio-chance.signin`(prod)·`com.snmac.studio-chance.dev.signin`(dev). 각 Services ID의 도메인은 `<Firebase 프로젝트 ID>.firebaseapp.com`,
    Return URL은 Firebase 콘솔 Apple 제공자 창에 나오는 콜백 URL
- **Firebase 콘솔 > Authentication > 로그인 방법 > Apple** (dev·prod 각각)
  - 서비스 ID: 위 Services ID
  - OAuth 코드 흐름 구성: 팀 ID `NCJMGH8Z64`, 키 ID·비공개 키는 **Apple Developer > Keys에 실제로 있는** Sign in with Apple 키.
    키는 primary App ID 그룹 단위라 dev·prod가 같은 키를 써도 된다
  - 콘솔은 저장한 비공개 키를 다시 보여주지 않는다. 키 ID가 Keys 목록에 있는지로 확인한다
  - 2026-10-29 dev에는 Keys에 없는 키가 들어 있어 revoke가 모두 실패했다(#48)
- **확인**: 계정을 삭제한 뒤 연결 해제 메일이 오면 revoke된 것이다. 시뮬레이터의 Apple 시트는 해제 뒤에도 동의 화면 없이
  바로 '로그인'으로 나올 수 있어 판단 근거가 되지 않는다

## iOS 포그라운드 알림 표시 확인

iOS에서 포그라운드 알림이 보이지 않으면 `setForegroundNotificationPresentationOptions` 설정을 의심한다(이유는 `NotificationController` 주석).

- 시뮬레이터 로그로 확인: 꺼진 상태 `Received response 0` / `shouldPresentAlert: 0`, 켜진 상태 `Received response 7` / `shouldPresentAlert: YES`
- 시뮬레이터에 푸시 보내기: `xcrun simctl push <device> <bundleId> payload.apns`
  (APNs·FCM을 우회하므로 전달 경로가 아닌 **표시·탭 처리만** 검증된다)

## 의존성 점검

deprecation과 낡은 의존성은 아무도 보지 않으면 쌓인다. Dependabot이 PR을 열고, Dependabot이 다루지 않는 것은 분기마다 손으로 본다.

### Dependabot (`.github/dependabot.yml`)

- **버전 업데이트**: 분기 1회. patch는 PR을 만들지 않고, 서로 맞물리는 패키지(FlutterFire, 코드 생성 스택, Firebase 서버·테스트 SDK)는 한 PR로 묶인다
- **보안 업데이트**: 주기와 무관하게 취약점 경보가 뜨면 바로 PR이 열린다. 저장소 Settings의 Dependabot alerts·security updates로 켜 둔다
  - `dependabot.yml`의 ignore는 모두 `update-types`로 써서 보안 업데이트를 막지 않는다. 보안 업데이트에는 ignore의 `versions`만 적용되기 때문이다(GitHub 문서에는 명시가 없고 dependabot-core 구현 기준). ignore를 추가할 때도 `versions` 대신 `update-types`를 쓴다
  - 임시로 막아 둔 메이저(FlutterFire 5 계열)로 올려야만 고쳐지는 취약점이면 보안 PR이 열려도 해석·빌드가 실패한다. 그때는 해당 이슈(#71)를 먼저 처리한다
- Dependabot PR은 이슈 없이 열리므로 커밋·PR 제목 컨벤션의 예외다

### Dependabot PR 처리

- `deprecated_member_use`가 warning이라 업그레이드가 새 deprecation을 끌고 오면 CI가 실패한다. 그 PR 브랜치에서 고쳐서 머지한다
- **pub — CI는 iOS를 빌드하지 않는다.** 네이티브 플러그인(FlutterFire, google_sign_in 등)이 바뀐 PR은 iOS SPM 해석이 깨져도 초록 불이다.
  `flutter build ios --simulator --flavor dev --target lib/main_dev.dart`로 확인한다
- **pub — 코드 생성 스택(`codegen` 그룹)**: Dependabot은 생성 파일을 다시 만들지 않는다.
  PR 브랜치에서 `dart run build_runner build --delete-conflicting-outputs`를 돌려 생성 파일 변경을 커밋한다
- **npm**: `cd functions && npm test` 후 `firebase deploy --only functions -P dev`로 배포 로그에 경고가 없는지 본다. prod는 머지 후 배포한다

### 분기마다 손으로 볼 것

정식 출시 직전에도 한 번 본다.

- **Dependabot이 올리지 않는 버전**
  - Flutter SDK: CI의 `flutter-version`, `pubspec.yaml`의 `environment.sdk`
  - Node 런타임: `functions/package.json`의 `engines.node`, CI의 `node-version`, `@types/node`(메이저를 런타임에 맞춘다).
    Cloud Functions 런타임 지원 일정은 `firebase-tools`의 `lib/deploy/functions/runtimes/supported/types.js`에 있다
- **`dependabot.yml`에서 임시로 막아 둔 항목**: 주석에 적힌 이슈가 해결됐으면 ignore를 지운다
- **OCR 모델의 지원 종료일**: 아래 "OCR 모델 변경"의 확인처에서 본다. 종료일이 다가오면 모델을 바꾼다
- **현황 실측**

  ```bash
  dart analyze                 # deprecated_member_use는 warning으로 나온다
  dart fix --dry-run
  flutter pub outdated
  cd functions
  npm outdated
  npm audit --omit=dev         # 운영 의존성. dev 도구(firebase-tools 등)의 경보는 상류 수정을 기다리는 경우가 많다
  ```

## OCR 모델 변경

예약 스크린샷 OCR이 쓰는 Gemini 모델은 Remote Config의 `ocr_model_name`으로 정한다. 앱 업데이트 없이 바꿀 수 있다.
콘솔 값이 비어 있거나 아직 가져오지 못했으면 앱 기본값(`lib/data/data_sources/remote_config.dart`의 `defaultOcrModelName`)을 쓴다.

- **모델 목록과 지원 종료일**: Firebase AI Logic의 [지원 모델](https://firebase.google.com/docs/ai-logic/models),
  모델별 종료일은 Agent Platform(구 Vertex AI) 모델 문서. 앱은 `FirebaseAI.agentPlatform()`(location `global`)을 쓰므로 그쪽 종료일이 기준이다
- **반영 시간**: 앱을 **처음부터 다시 실행할 때(콜드 스타트)만** 가져와 바로 적용한다. 백그라운드에서 돌아올 때는 가져오지 않는다.
  다시 실행해도 직전에 가져온 지 최소 간격(dev 5분 / prod 24시간)이 지나지 않았으면 캐시를 쓴다.
  그래서 prod는 바꾼 뒤 "24시간이 지나고 앱을 다시 실행한 기기"부터 반영된다. 앱을 오래 켜 둔 기기는 더 늦으므로
  모델 지원 종료일보다 **며칠 이상 앞서** 바꾼다
- **잘못된 모델 ID를 넣으면 OCR이 전부 실패한다.** 기본값으로 되돌리는 폴백이 없다(설정 오류를 가리지 않기 위해). 로그에 `Gemini 호출 실패 - 모델: ...`이 찍힌다

### 바꾸는 순서

1. **dev**(`studio-chance`) 콘솔 Remote Config에서 `ocr_model_name`을 바꿔 게시한다
2. dev 앱을 다시 실행하고 로그의 `Remote Config 적용 - ocr_model_name: ...`으로 새 값을 확인한다 (예전 값이면 5분 뒤 다시 실행)
3. `개발 자료/OCR 예제`의 4장을 돌려 이전 모델과 비교한다
   - 예약자명·연락처·입퇴실 시각·인원·플랫폼이 맞는지
   - memo에 입실·퇴실 안내문이 들어가지 않는지 (프롬프트 규칙 7. 모델에 따라 지키지 않는 경우가 있었다)
   - 응답 시간
4. 문제가 없으면 **prod**(`studio-chance-prod`)에 같은 값을 게시한다
5. 앱 기본값(`defaultOcrModelName`)도 다음 앱 업데이트 때 같은 값으로 맞춘다. 새로 설치한 앱의 첫 OCR은 기본값을 쓰기 때문이다
