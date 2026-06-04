# Firestore DataSource 에뮬레이터 테스트 - 작업 목록

Last Updated: 2026-06-04

## 완료된 작업

### Phase 1: 기반 구축 ✅
- [x] `fake_cloud_firestore: ^4.1.1` dev_dependencies 추가 (`pubspec.yaml`)
- [x] `firebase.json`에 Firestore Emulator 포트 설정 추가 (port: 8080)
- [x] `test/helpers/firestore_emulator_helper.dart` 생성
  - [x] `create()` — FakeFirebaseFirestore 인스턴스 생성
  - [x] `generateId()` — 타임스탬프 기반 고유 ID 생성
  - [x] `tearDownDocs()` — 실제 에뮬레이터 전환 대비 cleanup 헬퍼

### Phase 2: DataSource 테스트 작성 ✅
- [x] `test/data/data_sources/reservation_data_source_test.dart` (19개 테스트)
  - [x] createReservation: ID 반환, 문서 확인, TimestampConverter 왕복 검증
  - [x] getReservation: 조회, null 반환
  - [x] getReservationsByDateRange: 범위 필터, 경계값, 정렬, 빈 결과
  - [x] watchReservationsByDateRange: 스트림 방출, 빈 방출
  - [x] updateReservation: 필드 업데이트, 기존 필드 유지
  - [x] deleteReservation: 삭제, 문서 미존재 확인
  - [x] getReservationCountByCustomer: 동일 고객 집계, 제외, 0 반환
- [x] `test/data/data_sources/store_data_source_test.dart` (16개 테스트)
  - [x] createStore: batch write, users.storeById 업데이트, 문서 확인
  - [x] getStore: 조회, null, soft delete null 반환
  - [x] updateStore: 필드 업데이트, 기존 필드 유지
  - [x] softDeleteStore: null 반환, deletedAt 존재 확인
  - [x] createInviteCode / getInviteInfo: 6자리 생성, 저장 확인, null
  - [x] getStoreByInviteCode: 코드 조회, null, soft delete 제외
- [x] `test/data/data_sources/user_data_source_test.dart` (14개 테스트)
  - [x] createUser: 문서 생성
  - [x] getUser: 조회, null, soft delete null
  - [x] updateUser: 필드 업데이트, 기존 필드 유지
  - [x] softDeleteUser: null, deletedAt 존재, fcmTokens 초기화
  - [x] fetchUserWithRestoration: 정상 반환, 복구 후 반환, deletedAt 삭제, null
  - [x] restoreUser: deletedAt/expiresAt 삭제, 복구 후 조회

### Phase 3: 검증 ✅
- [x] Freezed @Default({}) 타입 문제 진단 및 수정 (명시적 타입 파라미터 적용)
- [x] `flutter test test/data/data_sources/` — 49개 테스트 전체 통과
- [x] `flutter test` — 155개 전체 통과 (기존 106 + 신규 49, 회귀 없음)

### Phase 4: 문서화 ✅
- [x] `dev/active/firestore-emulator-tests/firestore-emulator-tests-plan.md`
- [x] `dev/active/firestore-emulator-tests/firestore-emulator-tests-context.md`
- [x] `dev/active/firestore-emulator-tests/firestore-emulator-tests-tasks.md`

---

## 남은 TODO (선택적 후속 작업)

### 단기 (선택)
- [x] 멤버 관리 DataSource 테스트 추가
  - [x] `approveMember`: waitingMemberById → memberById 이동
  - [x] `updateMemberRole`: batch write (store + user)
  - [x] `removeMember`: batch delete (store + user)
  - [x] `requestJoinWithBatch`: 가입 신청 batch write

### 중기 (선택)
- [x] `StoreRepositoryImpl` integration test 추가 (DataSource 실제 구현과 연동)
  - [x] `StoreFirestoreDataSource` + `UserFirestoreDataSource` 조합 검증 (12개 테스트)
  - [x] 발견 버그 수정: `updateStore`의 `color.name` → `toJson()` JSON 값으로 수정
  - [x] 발견 버그 수정: `updateMemberRole`의 `newRole.name` → `toJson()` JSON 값으로 수정
  - [x] 발견 버그 수정: `StoreModel.inviteInfoModel`의 `@JsonKey(name: 'inviteInfo')` 누락

### 장기 (선택)
- [ ] 실제 Firestore Emulator 전환
  - 트리거: Security Rules 기반 테스트가 필요해질 때
  - 방법: `test/helpers/firestore_emulator_helper.dart`의 `create()` 교체
  - 추가 필요: `integration_test/` 디렉토리, CI `firebase emulators:exec` 설정
- [ ] `firestore.rules` Rules 기반 테스트 추가 (실제 Emulator 전환 후)
- [x] `firestore.rules` 기본 작성 (stores / users / reservations 3-tier 규칙)
- [x] CI/CD 파이프라인 추가 (`.github/workflows/ci.yml` — `dart analyze` + `flutter test`)

---

## 테스트 실행 참조

```bash
# DataSource 테스트만
flutter test test/data/data_sources/

# 전체 테스트 (회귀 확인)
flutter test

# 특정 파일
flutter test test/data/data_sources/reservation_data_source_test.dart
```

## 결과 요약

| 항목 | 값 |
|------|-----|
| 신규 테스트 수 | 70개 (49 + 멤버 관리 9 + Repository 통합 12) |
| 기존 테스트 수 | 106개 |
| 전체 테스트 | 176개 |
| 통과율 | 100% |
| 회귀 발생 | 없음 |
| 변경 production 파일 | 0개 |
