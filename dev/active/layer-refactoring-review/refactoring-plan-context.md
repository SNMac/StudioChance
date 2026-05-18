# 리팩토링 검토 — 컨텍스트 파일

Last Updated: 2026-05-19

---

## 핵심 파일 경로

### Data Layer

| 역할 | 경로 |
|------|------|
| Auth DataSource | `lib/data/data_sources/auth_data_source.dart` |
| User DataSource | `lib/data/data_sources/user_data_source.dart` |
| Store DataSource | `lib/data/data_sources/store_data_source.dart` |
| Reservation DataSource | `lib/data/data_sources/reservation_data_source.dart` |
| Auth Repository Impl | `lib/data/repositories/auth_repository_impl.dart` |
| User Repository Impl | `lib/data/repositories/user_repository_impl.dart` |
| Store Repository Impl | `lib/data/repositories/store_repository_impl.dart` |
| Reservation Repository Impl | `lib/data/repositories/reservation_repository_impl.dart` |
| Reservation Model | `lib/data/models/reservation_model.dart` |

### Domain Layer (Phase 2 이후 구조)

| 역할 | 경로 |
|------|------|
| Auth UseCase (순수 Domain) | `lib/domain/use_cases/auth_use_case.dart` |
| User UseCase (순수 Domain) | `lib/domain/use_cases/user_use_case.dart` |
| Store UseCase (순수 Domain) | `lib/domain/use_cases/store_use_case.dart` |
| Reservation UseCase (순수 Domain) | `lib/domain/use_cases/reservation_use_case.dart` |
| Auth Provider (DI 배선) | `lib/domain/use_cases/auth_use_case_provider.dart` |
| User Provider (DI 배선) | `lib/domain/use_cases/user_use_case_provider.dart` |
| Store Provider (DI 배선) | `lib/domain/use_cases/store_use_case_provider.dart` |
| Reservation Provider (DI 배선) | `lib/domain/use_cases/reservation_use_case_provider.dart` |
| UseCase 공통 헬퍼 | `lib/domain/use_cases/use_case_helpers.dart` |
| Repository Interfaces | `lib/domain/repository_interfaces/` |
| Entities | `lib/domain/entities/` |
| AppException | `lib/common/exceptions/app_exception.dart` |
| Exception 파일들 | `lib/common/exceptions/*.dart` |

### Presentation Layer

| 역할 | 경로 |
|------|------|
| AppAuthController | `lib/presentation/providers/app_auth_controller.dart` |
| HomeCalendarController | `lib/presentation/providers/home_calendar_controller.dart` |
| HomeReservationsProvider | `lib/presentation/providers/home_reservations_provider.dart` |
| StoreFormControllerable | `lib/presentation/commons/store_input/controllers/store_form_controllerable.dart` |
| StoreCreationController | `lib/presentation/commons/store_input/controllers/store_creation_controller.dart` |
| StoreUpdateController | `lib/presentation/commons/store_input/controllers/store_update_controller.dart` |
| ReservationInputForm (미완성) | `lib/presentation/commons/widgets/input_form/reservation_input_form.dart` |

---

## 주요 발견 사항 (코드 읽기 결과)

### Data Layer 확인된 사항 (Phase 1에서 해결 완료)

**1-A. `_handleFirestoreError` 중복** → ✅ 공통화 완료
**1-B. StoreDataSource 비즈니스 로직** → ✅ Repository로 이동 완료
**1-C. `updateUser` 마법 값** → ✅ 전용 메서드로 분리 완료
**1-D. Repository catch 패턴** → ✅ `common/utils/exception_utils.dart` `toException()` 헬퍼로 공통화
**1-E. ReservationRepository User 의존성** → ✅ 설계 결정 완료 (아래 참조)

---

### Domain Layer 확인된 사항 (Phase 2에서 해결 완료)

**2-A. UseCase Data Layer 직접 임포트 (DIP 위반)** → ✅ 해결 완료
- `*_use_case.dart`: 순수 Domain 파일 (data import 없음)
- `*_use_case_provider.dart`: DI 배선 파일 (data import 허용)
- Presentation 11개 파일 + 테스트 2개 파일 import 경로 업데이트 완료
- build_runner 재생성 완료

**2-B. `_getCurrentUser` 중복 (DRY 위반)** → ✅ 해결 완료
- `lib/domain/use_cases/use_case_helpers.dart` 생성
- `getCurrentUserOrThrow(UserRepository userRepository)` 최상위 함수
- `StoreUseCaseImpl`, `ReservationUseCaseImpl` 양쪽에서 사용

**2-C. Either 체이닝 패턴 불일치** → ✅ 해결 완료
- 기본 패턴: `result.fold((error) => left(error), (value) => ...)` 함수형 확정
- `AuthUseCaseImpl.signOut()`, `delete()` 개선
- `delete()`의 `isLeft() + getLeft().toNullable()!` (null-force-unwrap) 제거
- AGENTS.md에 `## Either / TaskEither 패턴` 섹션 추가

**2-D. 권한 검증 미구현** → ✅ 설계 결정 완료 (문서화)

**2-E. ReservationUseCase ← StoreRepository 의존** → ✅ 설계 결정 완료 (문서화)

**2-F. Common Exceptions 레이어 배치** → ✅ 설계 결정 완료 (문서화)

---

### Presentation Layer 확인된 사항 (Phase 3 대기)

**3-A. `ref.watch` select 미사용** → ⬜ 미시작
**3-B. StoreUpdateController `firstWhere` + try-catch** → ⬜ 미시작 (L28~31)
**3-C. submit 패턴 불일치** → ⬜ 미시작
**3-D. 대형 위젯 책임 분리 검토** → ⬜ 미시작
**3-E. ReservationInputForm Dead Code** → ⬜ 미시작

---

## Phase 2 커밋 이력 (2026-05-19)

| SHA | 설명 |
|-----|------|
| `983a386` | refactor: Domain UseCase-Provider 파일 분리 (DIP 위반 해소) |
| `9b0cf90` | refactor: _getCurrentUser 중복 제거 (DRY 위반 해소) |
| `5b70670` | refactor: Either 체이닝 패턴 통일 (signOut, delete) |
| `47926e9` | refactor: AuthUseCase Either fold 타입 명시성 개선 |
| `ff4e8fa` | docs: Domain Layer 아키텍처 설계 결정 문서화 (D2~D5) |
| `15986de` | fix: 테스트 파일 use_case_provider import 누락 수정 |

현재 브랜치: `refactor/data-layer` (develop 대비 위 커밋들 포함)
테스트: 86개 전부 통과

---

## 기술 결정 사항 (확정)

| ID | 결정 항목 | 결정 |
|----|----------|------|
| D1 | ReservationRepository - UserDataSource 의존성 | 현행 유지 (CLAUDE.md 명시) |
| D2 | StoreUseCase - 권한 검증 위치 | Firestore Rules 주 보안 레이어, UseCase는 선택적 |
| D3 | ReservationUseCase - StoreRepository 의존성 | 현행 유지 (가격 계산 필수 단계) |
| D4 | Common Exceptions 레이어 배치 | common/exceptions/ 공유 유지 |
| D5 | UseCase-Provider 파일 분리 | 분리 완료 (*_use_case_provider.dart) |

---

## 의존성 다이어그램 (Phase 2 이후)

```
Presentation
  └─ *_use_case_provider.dart (DI 배선 - data import 허용)
       └─ *_use_case.dart (순수 Domain - data import 없음)
            └─ Repository Interface
                 └─ Repository Impl (Data)
                      └─ DataSource Interface
                           └─ DataSource Impl (Firebase)

*_use_case_provider.dart
  ├─ *_use_case.dart (Domain)
  └─ *_repository_impl.dart (Data) ← 유일한 Data Layer 참조 지점
```

---

## Phase 3 시작 시 참고사항

### 핵심 파일
- `lib/presentation/commons/store_input/controllers/store_update_controller.dart` → 3-B (firstWhere L28~31)
- `lib/presentation/commons/store_input/controllers/store_creation_controller.dart` → 3-C (submit Either 패턴)
- `lib/presentation/home/widgets/three_day_calendar/` → 3-D (위젯 책임 검토)
- `lib/presentation/commons/widgets/input_form/reservation_input_form.dart` → 3-E (Dead Code)

### 주의사항
- 3-C (submit 패턴 통일): 2-C에서 확정된 `result.fold()` 패턴 기준으로 통일
- 3-D (홈 위젯): `time_grid.dart`와 `all_day_row.dart`가 `reservationUseCaseProvider`를 직접 참조 (Code Review에서 발견된 [I-1] 이슈, 별도 Controller로 분리 검토 필요)
- 3-A (`ref.watch select`): AGENTS.md 성능 규칙 기준으로 검토

### 준비 명령어

```bash
# 현재 브랜치 확인
git status
git log --oneline -6

# 테스트 통과 확인
flutter test

# 정적 분석
dart analyze lib/
```

---

## 관련 CLAUDE.md(AGENTS.md) 규칙

- `Future.wait([f1, f2])` — 반환 타입 다르면 별도 변수로 분리
- `ref.watch(provider.select(...))` — 필요한 필드만 구독
- `build()` 내 루프에서 `DateTime.now()` 등 반복 호출 금지
- Repository 조회 시 `currentUid` 필요 (StoreSummary color 조회)
- `DraggableScrollableSheet` 사용 금지 (모달 시트 패턴)
- Either 패턴: `result.fold()` 함수형, `isLeft()/isRight()` 명령형 금지
- `*_use_case.dart`: data import 금지 / `*_use_case_provider.dart`: data import 허용
