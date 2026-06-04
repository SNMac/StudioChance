# Firestore DataSource 에뮬레이터 테스트 도입

Last Updated: 2026-06-04

## Executive Summary

Firestore DataSource 계층은 실제 Firebase SDK와 직접 맞닿는 유일한 레이어임에도 기존에 테스트가 전혀 없었습니다. `fake_cloud_firestore` 패키지를 사용하여 `flutter test`에서 동작하는 DataSource 단위 테스트를 추가했습니다. 155개 전체 테스트 통과(기존 106 + 신규 49).

## 도입 배경 및 방식 선택

### fake_cloud_firestore vs 실제 Firestore Emulator 비교

| 항목 | fake_cloud_firestore | 실제 Firestore Emulator |
|------|----------------------|------------------------|
| 실행 환경 | `flutter test` (기기 불필요) | `integration_test` + 시뮬레이터 필요 |
| serverTimestamp | 현재 시각의 Timestamp로 저장 | 정확한 서버 Timestamp |
| count() 쿼리 | 3.x 이상 지원 | 완전 지원 |
| Security Rules | 미적용 | firestore.rules 실제 적용 |
| Composite index | 불필요 | 없으면 실패 |
| 기존 `test/` 구조 유지 | ✅ | ❌ (integration_test/ 필요) |

**선택 이유**: Flutter의 `cloud_firestore`는 iOS/Android 네이티브 SDK 위의 플랫폼 채널 방식이므로 `flutter test` 환경에서 실제 에뮬레이터 연결이 불가합니다. 기존 `test/` 구조를 유지하면서 DataSource 로직(CRUD, 쿼리, 직렬화, 에러 처리)을 검증하기 위해 `fake_cloud_firestore`를 선택했습니다.

## 추가된 파일

### 신규 생성 파일

```
test/
├── helpers/
│   └── firestore_emulator_helper.dart     # FakeFirebaseFirestore 헬퍼
└── data/
    └── data_sources/                      # 신규 디렉토리
        ├── reservation_data_source_test.dart  # 19개 테스트
        ├── store_data_source_test.dart        # 16개 테스트
        └── user_data_source_test.dart         # 14개 테스트
```

### 수정된 파일

- `pubspec.yaml`: `fake_cloud_firestore: ^4.1.1` 추가 (dev_dependencies)
- `firebase.json`: `emulators.firestore.port: 8080` 추가 (실제 에뮬레이터 전환 시 사용)

## 테스트 커버리지

### ReservationFirestoreDataSource (19개)
- `createReservation`: 생성 후 ID 반환, Firestore 문서 확인, **TimestampConverter 검증**
- `getReservation`: 존재하는 예약 조회, null 반환
- `getReservationsByDateRange`: 범위 내/외 필터링, 경계값 처리, startTime 오름차순 정렬, 빈 결과
- `watchReservationsByDateRange`: 스트림 방출, 빈 목록 방출
- `updateReservation`: 필드 업데이트, 기존 필드 유지
- `deleteReservation`: 삭제, Firestore 문서 미존재 확인
- `getReservationCountByCustomer`: 동일 고객 집계, 다른 고객 제외, 0 반환

### StoreFirestoreDataSource (16개)
- `createStore`: batch write (stores + users), users.storeById 업데이트, 문서 직접 확인
- `getStore`: 존재하는 점포, null 반환, **deletedAt soft delete 처리**
- `updateStore`: 필드 업데이트, 기존 필드 유지
- `softDeleteStore`: soft delete 후 null 반환, deletedAt 필드 존재 확인
- `createInviteCode / getInviteInfo`: 6자리 코드 생성, Firestore 저장 확인, null 반환
- `getStoreByInviteCode`: 코드로 조회, null 반환, **soft delete된 점포 제외**

### UserFirestoreDataSource (14개)
- `createUser`: 문서 생성 확인
- `getUser`: 존재하는 사용자, null 반환, **deletedAt soft delete 처리**
- `updateUser`: 필드 업데이트, 기존 필드 유지
- `softDeleteUser`: null 반환, deletedAt 존재 확인, fcmTokens 초기화 확인
- `fetchUserWithRestoration`: 정상 반환, **탈퇴 사용자 복구 후 반환**, deletedAt 삭제 확인, null 반환
- `restoreUser`: deletedAt/expiresAt 삭제, 복구 후 getUser 반환

## 주요 발견사항: Freezed @Default 타입 문제

### 문제
Freezed `@Default({})`, `@Default([])` 는 생성자 기본값으로 `const {}`, `const []`를 사용합니다.
Dart에서 `const {}`의 런타임 타입은 `_Map<dynamic, dynamic>` (또는 `_ImmutableMap<dynamic, dynamic>`)입니다.
`fake_cloud_firestore`가 내부적으로 중첩 Map을 `Map<String, dynamic>`으로 캐스팅할 때 `TypeError`가 발생합니다.

```
type '_Map<dynamic, dynamic>' is not a subtype of type 'Map<String, dynamic>' in type cast
```

### 해결책 (테스트 코드만 수정)
Freezed 모델 생성 시 기본값이 적용될 필드에 **명시적 타입 파라미터**를 가진 빈 컬렉션을 전달합니다.

```dart
// ❌ Freezed @Default({}) 기본값 사용 → const {} → _Map<dynamic, dynamic>
StoreModel(memberById: {}, ...)

// ✅ 명시적 타입 파라미터 → LinkedHashMap<String, T> → 정상 캐스팅
StoreModel(
  memberById: <String, StoreMemberInfoModel>{},
  waitingMemberById: <String, StoreMemberInfoModel>{},
  spaceOptions: <SpaceOptionModel>[],
  ...
)

// Firestore 문서 직접 작성 시에도 동일 적용
await firestore.collection('users').doc(uid).set(<String, dynamic>{
  'storeById': <String, dynamic>{},
  'authProviders': <String>[],
});
```

이 문제는 생산 코드에서도 잠재적으로 존재하지만, 실제 Firestore SDK는 타입 캐스팅을 더 유연하게 처리합니다.

## 실제 Firestore Emulator 전환 가이드

현재 `fake_cloud_firestore`로 대부분의 DataSource 로직을 커버합니다. Security Rules 검증이나 정확한 `serverTimestamp` 값이 필요할 때 전환하세요.

### 전환 절차
1. `test/helpers/firestore_emulator_helper.dart`의 `create()` 메서드를 교체:
   ```dart
   static Future<FirebaseFirestore> setUp() async {
     TestWidgetsFlutterBinding.ensureInitialized();
     if (Firebase.apps.isEmpty) {
       await Firebase.initializeApp(options: ...);
     }
     FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
     return FirebaseFirestore.instance;
   }
   ```
2. 각 테스트 파일의 `setUp`을 `setUpAll`로 변경하고 에뮬레이터 초기화 코드 추가
3. `tearDown`에서 테스트 생성 문서 삭제 (또는 HTTP API로 전체 초기화)
4. CI에 `firebase emulators:exec` 추가

## 실행 명령어

```bash
# 신규 DataSource 테스트만 실행
flutter test test/data/data_sources/

# 개별 파일 실행
flutter test test/data/data_sources/reservation_data_source_test.dart
flutter test test/data/data_sources/store_data_source_test.dart
flutter test test/data/data_sources/user_data_source_test.dart

# 전체 테스트 (회귀 확인)
flutter test

# 실제 Firestore Emulator 실행 (미래 전환 시)
firebase emulators:start --only firestore
```
