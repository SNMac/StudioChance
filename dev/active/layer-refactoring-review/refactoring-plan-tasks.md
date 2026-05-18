# 리팩토링 검토 — 작업 체크리스트

Last Updated: 2026-05-18

> **진행 방식**: 계획 수립 → Phase 1 → Phase 2 → Phase 3 순서로 진행  
> 각 Phase 완료 후 `dart analyze` + `flutter test` 통과 확인

---

## Phase 1 — Data Layer

### 1-A: `_handleFirestoreError` 공통화 [크기: M]
- [ ] `UserFirestoreDataSource`, `StoreFirestoreDataSource`, `ReservationFirestoreDataSource`의 `_handleFirestoreError` 분석
- [ ] 공통 Firebase 에러 코드 목록 정리
- [ ] 도메인별 Exception 팩토리를 주입받는 공통 믹스인/헬퍼 설계
- [ ] 구현 및 각 DataSource에 적용
- [ ] 기존 에러 동작과 동일한지 검증

### 1-B: StoreDataSource 비즈니스 로직 분리 [크기: M]
- [ ] `createInviteCode`의 만료 판단 로직 → Repository로 이동 설계
- [ ] `getStoreByInviteCode`의 만료 검증 → Repository로 이동 설계
- [ ] DataSource 메서드를 단순 Firestore 접근으로 단순화
- [ ] StoreRepositoryImpl에 이동된 로직 구현
- [ ] 기존 동작과 동일한지 end-to-end 검증

### 1-C: `updateUser` 마법 값 파라미터 개선 [크기: S]
- [ ] `UserDataSource.updateUser` 인터페이스의 마법 값 목록 파악 (`lastLoginAt: true`, fcmTokens 등)
- [ ] 개선 방향 결정: 전용 메서드 분리 vs 명시적 파라미터
- [ ] 결정된 방향으로 구현
- [ ] `UserRepositoryImpl.fetchOrCreateUser` 호출부 업데이트

### 1-D: Repository catch 패턴 공통화 [크기: S]
- [ ] `e is Exception ? e : Exception(e.toString())` 패턴 발생 횟수 확인
- [ ] `_toException(Object e)` 헬퍼 위치 결정 (`common/utils/` 또는 mixin)
- [ ] 구현 및 모든 Repository에 적용

### 1-E: ReservationRepository User 의존성 설계 결정 [크기: XL]
- [ ] [[refactoring-plan-context]] 기술 결정 D1 검토 및 방향 결정
- [ ] 결정된 방향으로 구현 계획 수립
- [ ] (결정에 따라) 구현

---

## Phase 2 — Domain Layer

### 2-A: UseCase Data Layer 직접 임포트 제거 [크기: M]
- [ ] [[refactoring-plan-context]] 기술 결정 D5 검토 및 방향 결정
- [ ] UseCase 클래스와 Riverpod Provider 팩토리 분리 방안 설계
- [ ] `auth_use_case.dart`, `user_use_case.dart`, `store_use_case.dart`, `reservation_use_case.dart` 적용
- [ ] Domain 레이어 파일에 `import 'data/'` 없음 확인

### 2-B: `_getCurrentUser` 중복 제거 [크기: S]
- [ ] `ReservationUseCaseImpl._getCurrentUser`와 `StoreUseCaseImpl._getCurrentUser` 비교
- [ ] 공통 추출 위치 결정 (mixin, extension, 공유 헬퍼)
- [ ] 구현 및 두 UseCase에 적용

### 2-C: Either 체이닝 패턴 통일 [크기: M]
- [ ] 현재 UseCase 전체에서 Either 처리 패턴 목록화 (명령형 vs 함수형)
- [ ] 팀 합의: 기본 패턴 결정 (TaskEither 함수형 vs 명령형 fold)
- [ ] `AuthUseCaseImpl.delete()`, `signOut()` 통일
- [ ] `StoreCreationController.submit()` 패턴도 통일 (3-C와 연계)
- [ ] CLAUDE.md에 결정된 패턴 추가

### 2-D: 권한 검증 위치 결정 [크기: S~M]
- [ ] [[refactoring-plan-context]] 기술 결정 D2 검토 및 방향 결정
- [ ] 결정 내용을 CLAUDE.md에 추가
- [ ] (UseCase 검증 선택 시) `approveMember`, `updateMemberRole`에 검증 구현

### 2-E: ReservationUseCase StoreRepository 의존성 설계 결정 [크기: L]
- [ ] [[refactoring-plan-context]] 기술 결정 D3 검토 및 방향 결정
- [ ] 결정된 방향으로 구현 계획 수립
- [ ] (분리 선택 시) PricingService 구현

### 2-F: Common Exceptions 레이어 배치 결정 [크기: S]
- [ ] [[refactoring-plan-context]] 기술 결정 D4 검토 및 방향 결정
- [ ] CLAUDE.md에 Exception 계층 사용 가이드 추가

---

## Phase 3 — Presentation Layer

### 3-A: `ref.watch` select 미적용 위젯 검토 [크기: M]
- [ ] 홈 화면 위젯 전체에서 `ref.watch(provider)` 사용처 목록화
- [ ] 위젯이 사용하는 필드가 상태 전체의 일부인 경우 확인
- [ ] `select` 적용 대상 목록 작성
- [ ] select 적용

### 3-B: StoreUpdateController `firstWhere` 개선 [크기: XS]
- [ ] `StoreUpdateController.build()` L28~31 개선
- [ ] `firstWhereOrNull` 또는 단일 변수 패턴으로 변경
- [ ] 동작 검증 (색상/메모 초기값이 올바르게 로드되는지)

### 3-C: 컨트롤러 submit 패턴 통일 [크기: S]
- [ ] `StoreCreationController.submit` Either 처리 → `result.fold()`로 통일
- [ ] `StoreUpdateController.submit`과 동일한 패턴 확인
- [ ] 2-C (Either 패턴 통일)와 연계하여 동일한 결정 기준 적용

### 3-D: 홈 위젯 책임 분리 검토 [크기: M]
- [ ] `three_day_calendar/` 각 파일의 책임 검토
- [ ] `monthly_calendar/` 각 파일의 책임 검토
- [ ] `build()` 내 무거운 연산 여부 확인
- [ ] ScrollController 관리 패턴이 CLAUDE.md 기준 준수하는지 확인
- [ ] 문제 발견 시 세부 리팩토링 계획 추가 작성

### 3-E: 미완성/Dead Code 정리 [크기: XS]
- [ ] `reservation_input_form.dart` 상태 확인 (WIP인지, 삭제 대상인지)
- [ ] 사용되지 않는 주석 코드 정리 또는 TODO 표시
- [ ] `dart analyze`로 미사용 import/변수 확인

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
| Phase 2 (Domain) | ⬜ 미시작 | — |
| Phase 3 (Presentation) | ⬜ 미시작 | — |
