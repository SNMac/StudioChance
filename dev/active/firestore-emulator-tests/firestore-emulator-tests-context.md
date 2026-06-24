# Firestore DataSource 에뮬레이터 테스트 - 컨텍스트

Last Updated: 2026-06-04

## 핵심 파일

### 신규 테스트 파일
- `test/helpers/firestore_emulator_helper.dart` — FakeFirebaseFirestore 생성 + generateId() 헬퍼
- `test/data/data_sources/reservation_data_source_test.dart` — 19개 테스트
- `test/data/data_sources/store_data_source_test.dart` — 16개 테스트
- `test/data/data_sources/user_data_source_test.dart` — 14개 테스트

### 수정된 파일
- `pubspec.yaml` — `fake_cloud_firestore: ^4.1.1` (dev_dependencies)
- `firebase.json` — emulators.firestore.port: 8080 추가

### 테스트 대상 DataSource (production)
- `lib/data/data_sources/reservation_data_source.dart` — `ReservationFirestoreDataSource`
- `lib/data/data_sources/store_data_source.dart` — `StoreFirestoreDataSource`
- `lib/data/data_sources/user_data_source.dart` — `UserFirestoreDataSource`
- `lib/data/data_sources/firestore_data_source_base.dart` — 에러 핸들링 기반 클래스

### 기존 테스트 헬퍼 (참조)
- `test/helpers/fake_entities.dart` — Domain Entity 픽스처
- `test/helpers/fake_models.dart` — Data Model 픽스처
- `test/helpers/fake_data.dart` — 위 두 파일 re-export

## 아키텍처 결정사항

### fake_cloud_firestore 선택 이유
- Flutter의 `cloud_firestore`는 플랫폼 채널 방식 → `flutter test`에서 네이티브 코드 미실행
- 실제 Firestore Emulator는 `integration_test` + 기기 필요 → 기존 `test/` 구조와 충돌
- `fake_cloud_firestore`는 순수 Dart로 동작, Firebase 초기화 불필요
- DataSource 로직(CRUD, 쿼리, 직렬화) 검증에 충분

### 테스트 격리 방식
- 각 테스트의 `setUp`에서 `FakeFirebaseFirestore()` 새 인스턴스 생성
- 각 테스트는 완전히 빈 DB에서 시작 → tearDown 불필요
- `generateId()`로 고유 ID 생성 (실제 에뮬레이터 전환 시에도 사용)

## 주요 기술 발견사항

### Freezed @Default({}) 타입 문제
**증상**: `StoreModel`, `UserModel` 등 Freezed 모델을 `toJson()` → `batch.set()` 시 TypeError  
**원인**:
- Freezed `@Default({})` → 생성자에서 `const {}` 기본값 사용
- Dart `const {}`의 런타임 타입은 `_Map<dynamic, dynamic>` (또는 `_ImmutableMap<dynamic, dynamic>`)
- `EqualUnmodifiableMapView(const {}).map(...)` → 타입 파라미터가 `dynamic`으로 추론됨
- `fake_cloud_firestore` 내부에서 `Map<String, dynamic>` 캐스팅 시 TypeError 발생

**해결**: 테스트 코드에서 명시적 타입 파라미터 사용
```dart
// StoreModel 생성 시
memberById: <String, StoreMemberInfoModel>{},
waitingMemberById: <String, StoreMemberInfoModel>{},
spaceOptions: <SpaceOptionModel>[],

// Firestore 직접 set 시
await firestore.collection('users').doc(uid).set(<String, dynamic>{
  'storeById': <String, dynamic>{},
  'authProviders': <String>[],
});
```

**Production 영향**: 실제 Firestore SDK는 이 문제를 내부적으로 처리하므로 production 코드는 수정 불필요

### fake_cloud_firestore 4.1.1 지원 범위
- `cloud_firestore: ^6.2.0`과 호환
- `FieldValue.serverTimestamp()` → 현재 시각의 Timestamp로 저장 (null 아님)
- `FieldValue.delete()` → 필드 삭제 지원
- `FieldValue.arrayUnion/Remove` → 지원
- `count()` 쿼리 → 지원 (확인 완료)
- `snapshots()` 스트림 → 지원
- `isNull: true` where 조건 → 지원
- 중첩 필드 쿼리 (`inviteInfo.inviteCode`) → 지원
- Composite Index → 불필요 (fake에서는 모든 쿼리 동작)
- Security Rules → 미적용

### Firestore 컬렉션 경로
- `stores/{storeId}` — StoreFirestoreDataSource
- `stores/{storeId}/reservations/{reservationId}` — ReservationFirestoreDataSource
- `users/{uid}` — UserFirestoreDataSource

### createStore batch write 테스트 전제조건
`StoreFirestoreDataSource.createStore()`는 `batch.update(userRef, {...})`를 사용하므로
users 문서가 먼저 존재해야 합니다. → `_seedUserDoc()` 헬퍼로 사전 생성 필요

## 의존성

- `fake_cloud_firestore: ^4.1.1` (cloud_firestore ^6.x 호환)
- `flutter_test` (SDK)
- `cloud_firestore: ^6.2.0` (existing)

## 범위 제외 항목 (이번 작업)
- Gemini DataSource (`gemini_data_source.dart`)
- Auth DataSource (`auth_data_source.dart`)
- Notification DataSource (`notification_data_source.dart`)
- FCM 관련 메서드 (addFcmToken, replaceFcmToken, removeFcmToken, recordLogin)
- 마이페이지 관련 미완성 로직
- 멤버 관리 (approveMember, updateMemberRole, removeMember, requestJoinWithBatch)
