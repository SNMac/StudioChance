# DataSource 개선 - 작업 목록

Last Updated: 2026-04-20

## Phase 1: 버그 수정 (높은 우선순위)

- [x] **[user_data_source]** `replaceFcmToken` — `WriteBatch` → `runTransaction`으로 변경
- [x] **[notification_data_source]** `getFcmToken` 반환 타입 `Future<String?>`→ `Future<String>`
  - 인터페이스 + 구현체 수정
  - `user_repository_impl.dart`의 dead null 체크 제거

## Phase 2: 코드 정확성

- [x] **[auth_data_source]** `_getGoogleCredential` — `googleAuth.idToken` 재참조 → `idToken` 변수 사용 (line 201)
- [x] **[user_data_source]** `softDeleteUser` — `expiresAt` 클럭 불일치 주석 추가

## Phase 3: 유지보수성

- [x] **[store_data_source]** `Random` → 클래스 필드 `_rnd`로 추출
- [x] **[reservation_data_source]** `_reservationsRef(String storeId)` helper 추출 (4개 메서드 적용)
- [x] **[user_data_source]** `_userDocRef(String uid)` helper 추출 (전체 메서드 적용)
- [x] **[store_data_source]** `_storeDocRef(String storeId)` helper 추출 (전체 메서드 적용)
- [x] **[store_data_source]** 만료 초대코드 예외 → `StoreNotFoundException` → `StoreValidationException`

## 검증

- [x] `dart analyze lib/data/data_sources/` — No issues found
- [x] `dart analyze lib/data/repositories/` — No issues found
