# Repository 코드 개선 계획

> Last Updated: 2026-04-20

## Executive Summary

`lib/data/repositories/` 및 `lib/data/data_sources/` 코드 분석 결과, **버그 1건**, **성능 이슈 3건**, **Firestore 사용량 이슈 2건**, **유지보수성 이슈 3건** 총 9건이 확인됨.

우선순위는 버그 → Firestore 사용량 → 성능 → 유지보수 순으로 처리.

---

## Current State Analysis

### 대상 파일

| 파일 | 역할 |
|------|------|
| `reservation_repository_impl.dart` | 예약 CRUD, 단일/범위 조회 |
| `store_repository_impl.dart` | 점포 CRUD, 초대 코드, 멤버 관리 |
| `user_repository_impl.dart` | 사용자 조회/생성/수정, FCM 토큰 |
| `auth_repository_impl.dart` | Google/Apple 로그인, 로그아웃, 탈퇴 |
| `reservation_data_source.dart` | Firestore 예약 서브컬렉션 |
| `store_data_source.dart` | Firestore 점포 컬렉션 |
| `user_data_source.dart` | Firestore 사용자 컬렉션 |

---

## 발견된 이슈 상세

### 🔴 버그

#### [BUG-1] `getReservationsByDateRange` StoreColor 폴백 불일치
- **위치**: `reservation_repository_impl.dart:107`
- **현상**: `getReservationsByDateRange`에서 폴백 색상으로 `StoreColor.blue` 사용
- **기대**: `_buildReservationEntity`(line 244)와 CLAUDE.md 모두 `StoreColor.red` 지정
- **영향**: 날짜 범위 조회 시 점포 색상이 잘못 표시됨

---

### 🟠 Firestore 사용량

#### [FIRESTORE-1] `updateReservation` — 전체 JSON 덮어쓰기
- **위치**: `reservation_repository_impl.dart:165-176`
- **현상**: `ReservationModel.fromEntity` → `toJson()`으로 전체 필드를 update payload로 전달
- **문제**:
  - `createdAt`, `updatedAt` 등 변경 불필요한 서버 타임스탬프 필드까지 클라이언트 값으로 덮어씀
  - 향후 partial update가 필요한 경우 구조적으로 어려움
- **개선**: Entity에서 변경 가능한 필드만 명시적으로 추출하거나, `toUpdateJson()` 메서드 추가

#### [FIRESTORE-2] `fetchOrCreateUser` — 기존 유저 로그인 시 2회 Write
- **위치**: `user_repository_impl.dart:44-50`
- **현상**: 기존 유저 로그인 시 `addFcmToken` + `updateUser` 각각 별도 Firestore write
- **문제**: 불필요한 write 2회 발생 → 비용 2배 + 경쟁 상태 가능성
- **개선**: 두 업데이트를 단일 `updateUser` 호출로 합산
  ```dart
  // Before
  await _userDataSource.addFcmToken(userModel.id, fcmToken);
  await _userDataSource.updateUser(userModel.id, {'authProviders': ...});
  
  // After
  final updates = {'authProviders': authInfo.authProviders};
  if (fcmToken != null) updates['fcmTokens'] = FieldValue.arrayUnion([fcmToken]);
  await _userDataSource.updateUser(userModel.id, updates);
  ```
  단, `addFcmToken`의 `FieldValue.arrayUnion`을 `updateUser`가 지원해야 함.

---

### 🟡 성능

#### [PERF-1] `getReservationsByDateRange` — 전체 점포 Document 읽기
- **위치**: `reservation_repository_impl.dart:96-99`
- **현상**: 예약 목록 조회 시 `_storeDataSource.getStore(storeId)` 호출 — store 전체 document 읽기
- **목적**: `storeModel.name` (StoreSummary용)과 `memberById[writerId].role` (writer 역할) 추출
- **문제**: 멤버 수가 많아질수록 store document가 커지고, 매 날짜 범위 조회마다 전체 읽기
- **개선 방향**:
  - 단기: 현행 유지 (실사용자 수가 적을 때는 영향 미미)
  - 장기: 예약 document에 `writerRole` 비정규화 저장, 또는 store name을 user의 `storeById`에서 가져오는 방식으로 변경

#### [PERF-2] `_fetchMembersWithRoles` — 멤버 수만큼 병렬 Read
- **위치**: `store_repository_impl.dart:270-287`
- **현상**: `Future.wait`로 멤버 N명을 병렬 조회
- **문제**: 병렬이지만 N개 read 소켓을 동시에 열어 Firestore 연결 수 증가; 멤버 10명 이상 시 부담
- **개선 방향**:
  - 단기: 현행 유지 (소규모 팀 앱에서 큰 문제 없음)
  - 장기: `whereIn` 쿼리 도입 (Firestore에서 최대 30개 지원)
    ```dart
    // 최대 30개 제한으로 청크 분할 필요
    final chunks = userIds.slices(30);
    // .where(FieldPath.documentId, whereIn: chunk) 쿼리
    ```

#### [PERF-3] `fetchOrCreateUser` — `lastLoginAt` 미갱신
- **위치**: `user_repository_impl.dart:48-50`
- **현상**: 기존 유저 로그인 시 `authProviders`만 업데이트, `lastLoginAt` 미갱신
- **문제**: 마지막 로그인 시간 추적 불가 (분석/CS 대응 시 불편)
- **개선**: `updateUser` 호출 시 `'lastLoginAt': true` 플래그 또는 별도 파라미터로 갱신

---

### 🔵 유지보수성

#### [MAINT-1] `updateStore` — 하드코딩된 JSON 키
- **위치**: `store_repository_impl.dart:108-116`
- **현상**: `storeJson['name']`, `storeJson['priceSettingsModel']` 등 문자열 키로 직접 접근
- **문제**: 모델 필드명 변경 시 컴파일 오류 없이 실패 (null 전달)
- **개선**: 키를 상수로 추출하거나, `StoreModel.toUpdateJson()` 메서드에서 업데이트 가능 필드만 반환하도록 분리

#### [MAINT-2] `_buildReservationEntity`와 `getReservationsByDateRange` 로직 중복
- **위치**: `reservation_repository_impl.dart:96-150, 222-268`
- **현상**: store/user fetch → StoreSummary 구성 → writerRole 조회 로직이 두 곳에 중복
- **문제**: 한 쪽만 수정 시 불일치 버그 발생 가능 (BUG-1도 이 중복 때문에 발생)
- **개선**: 공통 헬퍼로 추출하거나, `_buildReservationEntity`를 단일 사용 시에도 활용하도록 통일

#### [MAINT-3] `softDeleteUser` — `Future<void>` 미일치
- **위치**: `user_repository_impl.dart:166-175`
- **현상**: 다른 메서드는 `Either<Exception, void>` 반환이지만 `softDeleteUser`는 `Future<void>` + rethrow
- **문제**: 호출부(Use Case)에서 예외 처리 방식이 달라져 일관성 저하
- **결정 필요**: Either 패턴으로 통일하거나, `Future<void>` + rethrow를 명시적 주석으로 문서화

---

## Implementation Phases

### Phase 1 — 버그 수정 (즉시)
- [BUG-1] StoreColor 폴백 `blue` → `red` 수정

### Phase 2 — Firestore 사용량 절감 (단기)
- [FIRESTORE-2] 기존 유저 로그인 write 2회 → 1회로 합산
- [FIRESTORE-1] `updateReservation` 전체 JSON 덮어쓰기 검토

### Phase 3 — 유지보수성 개선 (중기)
- [MAINT-1] `updateStore` 하드코딩 키 개선
- [MAINT-2] 중복 로직 헬퍼화
- [MAINT-3] `softDeleteUser` 시그니처 방향 결정 및 주석 추가

### Phase 4 — 성능 최적화 (장기, 트래픽 증가 시)
- [PERF-1] store document partial read / 비정규화 검토
- [PERF-2] `whereIn` 쿼리로 N+1 해소
- [PERF-3] `lastLoginAt` 갱신

---

## Risk Assessment

| 이슈 | 수정 위험도 | 비고 |
|------|------------|------|
| BUG-1 | 낮음 | 1줄 변경 |
| FIRESTORE-2 | 중간 | `updateUser` 메서드가 `FieldValue` 수용 가능한지 확인 필요 |
| FIRESTORE-1 | 중간 | 기존 예약 데이터에 서버 타임스탬프가 클라이언트 값으로 덮어씌워지지 않는지 확인 |
| MAINT-1 | 낮음 | 상수화 또는 메서드 분리 |
| MAINT-2 | 중간 | 리팩터링 후 동작 동일성 테스트 필요 |
| MAINT-3 | 낮음 | 주석/문서화만으로 해결 가능 |

---

## Success Metrics

- [ ] BUG-1: 날짜 범위 예약 조회 시 StoreColor가 `red`로 폴백됨 (기존 `blue` 폴백 제거)
- [ ] FIRESTORE-2: 기존 유저 로그인 시 Firestore write 횟수 1회 감소
- [ ] MAINT-1: `updateStore`에서 모델 필드명 변경 시 안전한 방식으로 필드 추출
- [ ] MAINT-2: `_buildReservationEntity`와 `getReservationsByDateRange` 간 로직 불일치 원천 제거
