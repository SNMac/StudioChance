# Repository Review — 작업 체크리스트

> Last Updated: 2026-04-20

## Phase 1 — 버그 수정 (즉시)

- [x] **[BUG-1]** `reservation_repository_impl.dart:107` `StoreColor.blue` → `StoreColor.red` 수정
  - 파일: `lib/data/repositories/reservation_repository_impl.dart`
  - 변경: `currentUserModel?.storeById[storeId]?.color ?? StoreColor.blue` → `StoreColor.red`
  - 크기: S

## Phase 2 — Firestore 사용량 절감 (단기)

- [x] **[FIRESTORE-2]** `fetchOrCreateUser` 기존 유저 write 2회 → 1회로 합산
  - 파일: `lib/data/repositories/user_repository_impl.dart`
  - 변경: `addFcmToken` 호출 제거, `updateUser` 호출에 `fcmTokens: FieldValue.arrayUnion([fcmToken])` 추가
  - 전제: `UserDataSource.updateUser`가 `FieldValue` 값을 그대로 전달함 (확인됨)
  - 크기: S

- [x] **[FIRESTORE-1]** `updateReservation` — `createdAt` 필드 덮어쓰기 방지
  - 파일: `lib/data/repositories/reservation_repository_impl.dart`
  - 방안 A: `ReservationModel`에 `toUpdateJson()` 추가 (변경 가능 필드만 포함)
  - 방안 B: Repository에서 json에서 `createdAt`, `id`, `storeId`, `writerId` 제거 후 전달
  - 크기: M

## Phase 3 — 유지보수성 개선 (중기)

- [x] **[MAINT-3]** `softDeleteUser` — 의도적 예외 전파 주석 추가
  - 파일: `lib/data/repositories/user_repository_impl.dart:166`
  - 변경: `// NOTE: 탈퇴 흐름에서 예외를 호출부까지 전파하도록 의도적으로 throw` 주석 추가
  - 크기: S

- [x] **[MAINT-1]** `updateStore` — 하드코딩 키 안전화
  - 파일: `lib/data/repositories/store_repository_impl.dart:108-116`
  - 방안 A: `StoreModel`에 `toStoreInfoJson()` 메서드 추가 (업데이트 가능 필드만)
  - 방안 B: 필드명을 상수로 추출
  - 크기: M

- [x] **[MAINT-2]** `_buildReservationEntity` / `getReservationsByDateRange` 중복 헬퍼화
  - 파일: `lib/data/repositories/reservation_repository_impl.dart`
  - 방안: `StoreSummary` 구성 로직과 `writer` 구성 로직을 별도 `_buildStoreSummary`, `_buildWriter` private 메서드로 분리
  - 크기: M

## Phase 4 — 성능 최적화 (장기, 백로그)

- [x] **[PERF-3]** `fetchOrCreateUser` — `lastLoginAt` 기존 유저 로그인 시 갱신
  - 파일: `lib/data/repositories/user_repository_impl.dart`
  - 변경: `updateUser` 호출에 `'lastLoginAt': FieldValue.serverTimestamp()` 추가
  - 참고: `UserDataSource.updateUser`의 `lastLoginAt` 특별 처리 로직 확인 필요 (line 131-133)
  - 크기: S

- [x] **[PERF-1]** `getReservationsByDateRange` — store full document 읽기 최소화 검토
  - 현행 유지 결정 시: 이 항목 닫기
  - 변경 결정 시: 예약 document에 `writerRole` 비정규화 또는 `storeName` 별도 저장 설계
  - 크기: XL (데이터 모델 변경 포함)

- [x] **[PERF-2]** `_fetchMembersWithRoles` — `whereIn` 쿼리로 N+1 해소
  - 현행 유지 결정 시: 이 항목 닫기 (소규모 팀 앱에서 영향 미미)
  - 변경 결정 시: `whereIn` 최대 30개 제한 감안하여 청크 분할 구현
  - 크기: L
