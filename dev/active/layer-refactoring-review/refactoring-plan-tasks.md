# 리팩토링 검토 — 작업 체크리스트

Last Updated: 2026-05-19 (Phase 3 완료)

> **진행 방식**: 계획 수립 → Phase 1 → Phase 2 → Phase 3 순서로 진행  
> 각 Phase 완료 후 `dart analyze` + `flutter test` 통과 확인

---

## Phase 1 — Data Layer

### 1-A: `_handleFirestoreError` 공통화 [크기: M]
- [x] `UserFirestoreDataSource`, `StoreFirestoreDataSource`, `ReservationFirestoreDataSource`의 `_handleFirestoreError` 분석
- [x] 공통 Firebase 에러 코드 목록 정리
- [x] 도메인별 Exception 팩토리를 주입받는 공통 믹스인/헬퍼 설계
- [x] 구현 및 각 DataSource에 적용
- [x] 기존 에러 동작과 동일한지 검증

### 1-B: StoreDataSource 비즈니스 로직 분리 [크기: M]
- [x] `createInviteCode`의 만료 판단 로직 → Repository로 이동 설계
- [x] `getStoreByInviteCode`의 만료 검증 → Repository로 이동 설계
- [x] DataSource 메서드를 단순 Firestore 접근으로 단순화
- [x] StoreRepositoryImpl에 이동된 로직 구현
- [x] 기존 동작과 동일한지 end-to-end 검증

### 1-C: `updateUser` 마법 값 파라미터 개선 [크기: S]
- [x] `UserDataSource.updateUser` 인터페이스의 마법 값 목록 파악 (`lastLoginAt: true`, fcmTokens 등)
- [x] 개선 방향 결정: 전용 메서드 분리 vs 명시적 파라미터
- [x] 결정된 방향으로 구현
- [x] `UserRepositoryImpl.fetchOrCreateUser` 호출부 업데이트

### 1-D: Repository catch 패턴 공통화 [크기: S]
- [x] `e is Exception ? e : Exception(e.toString())` 패턴 발생 횟수 확인
- [x] `_toException(Object e)` 헬퍼 위치 결정 (`common/utils/` 또는 mixin)
- [x] 구현 및 모든 Repository에 적용

### 1-E: ReservationRepository User 의존성 설계 결정 [크기: XL]
- [x] [[refactoring-plan-context]] 기술 결정 D1 검토 및 방향 결정
- [x] 결정된 방향으로 구현 계획 수립
- [x] (결정에 따라) 구현

---

## Phase 2 — Domain Layer

### 2-A: UseCase Data Layer 직접 임포트 제거 [크기: M]
- [x] [[refactoring-plan-context]] 기술 결정 D5 검토 및 방향 결정 → 파일 분리
- [x] UseCase 클래스와 Riverpod Provider 팩토리 분리 방안 설계
- [x] `auth_use_case.dart`, `user_use_case.dart`, `store_use_case.dart`, `reservation_use_case.dart` 적용
- [x] Domain 레이어 파일에 `import 'data/'` 없음 확인
- [x] 신규: `*_use_case_provider.dart` 4개 파일 생성
- [x] Presentation 파일 11개 + 테스트 2개 import 경로 업데이트
- [x] build_runner 재생성 (44 outputs written)

### 2-B: `_getCurrentUser` 중복 제거 [크기: S]
- [x] `ReservationUseCaseImpl._getCurrentUser`와 `StoreUseCaseImpl._getCurrentUser` 비교
- [x] 공통 추출 위치 결정 → `lib/domain/use_cases/use_case_helpers.dart` 최상위 함수
- [x] 구현 및 두 UseCase에 적용 (`getCurrentUserOrThrow(UserRepository)`)

### 2-C: Either 체이닝 패턴 통일 [크기: M]
- [x] 현재 UseCase 전체에서 Either 처리 패턴 목록화 (명령형 vs 함수형)
- [x] 팀 합의: 기본 패턴 결정 → `result.fold()` 함수형
- [x] `AuthUseCaseImpl.delete()`, `signOut()` 통일
- [x] CLAUDE.md(AGENTS.md)에 결정된 패턴 추가

### 2-D: 권한 검증 위치 결정 [크기: S~M]
- [x] [[refactoring-plan-context]] 기술 결정 D2 검토 및 방향 결정 → Firestore Rules 주 보안 레이어
- [x] 결정 내용을 AGENTS.md에 추가

### 2-E: ReservationUseCase StoreRepository 의존성 설계 결정 [크기: L]
- [x] [[refactoring-plan-context]] 기술 결정 D3 검토 및 방향 결정 → 현행 유지
- [x] 결정된 방향 AGENTS.md에 문서화

### 2-F: Common Exceptions 레이어 배치 결정 [크기: S]
- [x] [[refactoring-plan-context]] 기술 결정 D4 검토 및 방향 결정 → common/exceptions/ 공유 유지
- [x] AGENTS.md에 Exception 계층 사용 가이드 추가

---

## Phase 3 — Presentation Layer

### 3-A: `ref.watch` select 미적용 위젯 검토 [크기: M]
- [x] 홈 화면 위젯 전체에서 `ref.watch(provider)` 사용처 목록화
- [x] 위젯이 사용하는 필드가 상태 전체의 일부인 경우 확인
- [x] `select` 적용 대상 목록 작성
- [x] select 적용 (ThreeDayCalendar/currentUserProvider, SignInScreen, PriceDaysInput/PriceTimeInput)

### 3-B: StoreUpdateController `firstWhere` 개선 [크기: XS]
- [x] `StoreUpdateController.build()` L28~31 개선
- [x] `.where().firstOrNull` 패턴으로 변경 (collection 패키지 없이 Dart 3 네이티브)
- [x] 동작 검증 (`dart analyze` 통과)

### 3-C: 컨트롤러 submit 패턴 통일 [크기: S]
- [x] `StoreCreationController.submit` Either 처리 → `result.fold()`로 통일
- [x] `StoreUpdateController.submit`과 동일한 패턴 확인
- [x] 2-C (Either 패턴 통일)와 연계하여 동일한 결정 기준 적용

### 3-D: 홈 위젯 책임 분리 검토 [크기: M]
- [x] `three_day_calendar/` 각 파일의 책임 검토
- [x] `monthly_calendar/` 각 파일의 책임 검토 (이미 select 적용 완료)
- [x] `build()` 내 무거운 연산 여부 확인 (DateTime.now()는 루프 밖 단일 호출로 허용)
- [x] ScrollController 관리 패턴이 AGENTS.md 기준 준수하는지 확인 (hasClients 감지 → dispose/재생성 패턴 준수)
- [x] I-1 해결: `HomeReservationActionsController` 생성 — `TimeGrid`, `AllDayCell`의 `reservationUseCaseProvider` 직접 참조 제거

### 3-E: 미완성/Dead Code 정리 [크기: XS]
- [x] `reservation_input_form.dart` → 미사용 Placeholder 파일 삭제
- [x] `dart analyze` — 에러 0개 확인

---

## 공통 완료 기준

각 Phase 완료 시:
- [ ] `dart analyze` — 에러 0개 (경고는 기존 대비 증가 없음)
- [ ] `flutter test` — 기존 테스트 전부 통과
- [ ] 변경 내용 커밋 메시지: `refactor: #[이슈번호] - [한국어 설명]`

---

## 진행 상황

| Phase | 상태 | 완료일 |
|-------|------|--------|
| Phase 0 (현황 분석) | ✅ 완료 | 2026-05-18 |
| Phase 1 (Data) | ✅ 완료 | 2026-05-18 |
| Phase 2 (Domain) | ✅ 완료 | 2026-05-19 |
| Phase 3 (Presentation) | ✅ 완료 | 2026-05-19 |
