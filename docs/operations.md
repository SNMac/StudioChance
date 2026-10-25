# 운영 절차

배포·디버그 환경 준비처럼 사람이 직접 하는 절차를 모은다. 배포 순서 같은 규칙은 CLAUDE.md에 있다.

## Firebase 프로젝트 설정 파일

`firebase.json`/`.firebaserc`는 gitignore 처리되어 저장소에 없다. 새로 clone한 환경에서 배포하려면 아래 내용을 직접 만든다.
Rules 테스트용 에뮬레이터 설정은 별도로 추적하는 `firebase.emulator.json`을 쓰므로 이 파일들이 없어도 테스트는 돈다.

```json
// firebase.json (Functions·Rules 배포에 필요한 부분만)
{
  "firestore": {
    "rules": "firestore.rules"
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
- Rules는 `firebase deploy --only firestore:rules -P dev` / `-P prod`. 순서는 Functions → Rules → 앱이다 (CLAUDE.md)
- **배포 전 Secret 설정**(dev·prod 각각, 최초 1회): `firebase functions:secrets:set DATA_GO_KR_SERVICE_KEY -P dev`
- **`syncHolidays` 첫 배포 직후 1회 수동 실행**: 스케줄 첫 실행이 다음 날 새벽이므로 Cloud Scheduler 콘솔에서 `syncHolidays` 작업을 "강제 실행"한다

## App Check 디버그 토큰 등록 (dev 실기기)

`lookupInviteCode`는 이 앱에서 App Check를 실제로 강제하는 첫 경로다. dev 실기기에서 디버그 토큰을 등록하지 않으면
초대 코드 조회가 전부 "권한이 없습니다"로 떨어진다(`mapFirebaseCode`가 `unauthenticated` → `StorePermissionDeniedException`).
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

## iOS 포그라운드 알림 표시 확인

iOS에서 포그라운드 알림이 보이지 않으면 `setForegroundNotificationPresentationOptions` 설정을 의심한다(이유는 `NotificationController` 주석).

- 시뮬레이터 로그로 확인: 꺼진 상태 `Received response 0` / `shouldPresentAlert: 0`, 켜진 상태 `Received response 7` / `shouldPresentAlert: YES`
- 시뮬레이터에 푸시 보내기: `xcrun simctl push <device> <bundleId> payload.apns`
  (APNs·FCM을 우회하므로 전달 경로가 아닌 **표시·탭 처리만** 검증된다)
