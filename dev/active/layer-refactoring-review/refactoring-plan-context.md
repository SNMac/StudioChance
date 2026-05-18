# 리팩토링 검토 — 컨텍스트 파일

Last Updated: 2026-05-18

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

### Domain Layer

| 역할 | 경로 |
|------|------|
| Auth UseCase | `lib/domain/use_cases/auth_use_case.dart` |
| User UseCase | `lib/domain/use_cases/user_use_case.dart` |
| Store UseCase | `lib/domain/use_cases/store_use_case.dart` |
| Reservation UseCase | `lib/domain/use_cases/reservation_use_case.dart` |
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

### Data Layer 확인된 사항

**1-A. `_handleFirestoreError` 중복** — 동일한 Firebase 에러 코드 switch가 3곳에 독립 존재
- `UserFirestoreDataSource` (L263~L316)
- `StoreFirestoreDataSource` (L348~L387)
- `ReservationFirestoreDataSource` (L148~L191)
- 공통 케이스: `permission-denied`, `unauthenticated`, `not-found`, `resource-exhausted`,
  `unavailable`, `deadline-exceeded`, `aborted`, `failed-precondition`, `cancelled`

**1-B. StoreDataSource 비즈니스 로직**
- `createInviteCode` (L248~290): `if (!forceRegenerate)` 블록 내 만료 판단
- `getStoreByInviteCode` (L292~328): `DateTime.now().isAfter(expiresAt)` 판단 후 예외
- `_generateRandomCode` 헬퍼는 DataSource에 적합 (순수 유틸)

**1-C. `updateUser` 마법 값**
- `UserRepositoryImpl.fetchOrCreateUser` (L44~51): `'lastLoginAt': true` 삽입
- `UserFirestoreDataSource.updateUser` (L130~137): `true`를 `serverTimestamp()`로 교체
- 인터페이스 주석이 fcmTokens 관련 경고를 남기고 있으나 `lastLoginAt`에 대한 언급 없음

**1-D. Repository catch 패턴**
- `AuthRepositoryImpl` 전 메서드: `left(e is Exception ? e : Exception(e.toString()))`
- 동일 패턴이 StoreRepositoryImpl, ReservationRepositoryImpl에서도 반복

**1-E. ReservationRepository User 의존성**
- `ReservationRepositoryImpl` 생성자에 `UserDataSource` 주입
- `getReservationsByDateRange`: 현재 사용자 조회 후 `storeById[storeId]`에서 color 읽기
- `_buildStoreSummary` 헬퍼 (L216~228)

---

### Domain Layer 확인된 사항

**2-A. UseCase Data Layer 직접 임포트**
- `auth_use_case.dart` L5~6: `data/repositories/user_repository_impl.dart`, `auth_repository_impl.dart`
- `reservation_use_case.dart` L5~7: 3개 Repository Impl 임포트
- `store_use_case.dart` L5~6: 2개 Repository Impl 임포트
- `user_use_case.dart` L4: `data/repositories/user_repository_impl.dart`
- Provider 팩토리 함수가 UseCase 파일 하단에 있어서 불가피한 상황

**2-B. `_getCurrentUser` 중복**
- `ReservationUseCaseImpl._getCurrentUser` (L162~172)
- `StoreUseCaseImpl._getCurrentUser` (L203~213)
- 완전히 동일한 구현 (TaskEither.tryCatch + UserRepository.getCurrentUser)

**2-C. Either 처리 패턴 혼재**
- `signOut()`: `currentUserResult.isRight()` + `.getRight().toNullable()` (명령형)
- `delete()`: `isLeft()` 체크 + `getLeft().toNullable()!` (명령형, null-force-unwrap 있음)
- `createStore()`, `joinStore()`: `_getCurrentUser().flatMap()...run()` (함수형 TaskEither)
- `StoreCreationController.submit()`: `if (result.isLeft()) throw result.getLeft().toNullable()!`

**2-D. 권한 검증 TODO**
- `StoreUseCaseImpl.approveMember` (L145): 주석만 존재, 실제 검증 없음

**2-E. ReservationUseCase ← StoreRepository 의존**
- `ReservationUseCaseImpl` 생성자에 `StoreRepository` 주입
- `_applyCalculatedPrice` (L177~196): Store 조회 후 가격 계산

---

### Presentation Layer 확인된 사항

**3-B. StoreUpdateController.build — firstWhere 이중 호출**
- L28~31: `firstWhere` 2회 호출 + try-catch로 예외 무시
- `firstWhereOrNull` (collection 패키지) 또는 단일 변수로 개선 가능

**3-C. 컨트롤러 submit 패턴 불일치**
- `StoreCreationController.submit` (L60): `if (result.isLeft()) throw result.getLeft().toNullable()!`
- `StoreUpdateController.submit` (L74~79): `result.fold((e) => ..., (_) => ...)`

**3-E. ReservationInputForm 미완성**
- 전체가 `const Placeholder()` 반환
- 구현이 주석으로 처리됨

---

## 의존성 다이어그램 (현재)

```
Presentation
  └─ UseCase (interface) ← [직접 임포트로 Impl도 참조]
       └─ Repository Interface
            └─ Repository Impl (Data)
                 └─ DataSource Interface
                      └─ DataSource Impl (Firebase)

Domain UseCase Impl
  ├─ AuthRepository (interface) ← auth_repository_impl.dart (Data) [DIP 위반]
  ├─ UserRepository (interface) ← user_repository_impl.dart (Data) [DIP 위반]
  └─ StoreRepository (interface) ← store_repository_impl.dart (Data) [DIP 위반]
```

---

## 기술 결정 사항 (미결)

| ID | 결정 항목 | 선택지 |
|----|----------|--------|
| D1 | ReservationRepository - UserDataSource 의존성 제거 여부 | A: 유지(현행) / B: Presentation에서 color 주입 / C: Firestore 구조 변경 |
| D2 | StoreUseCase - 권한 검증 위치 | A: UseCase / B: Firestore Rules만 |
| D3 | ReservationUseCase - StoreRepository 의존성 | A: 유지 / B: PricingService 분리 / C: 호출부 주입 |
| D4 | Common Exceptions 레이어 배치 | A: 현행(common 공유) / B: Domain/Infra 분리 |
| D5 | UseCase-Provider 파일 분리 | A: 분리 / B: 현행 유지(Provider를 domain에 허용) |

---

## 관련 CLAUDE.md 규칙

- `Future.wait([f1, f2])` — 반환 타입 다르면 별도 변수로 분리
- `ref.watch(provider.select(...))` — 필요한 필드만 구독
- `build()` 내 루프에서 `DateTime.now()` 등 반복 호출 금지
- Repository 조회 시 `currentUid` 필요 (StoreSummary color 조회)
- `DraggableScrollableSheet` 사용 금지 (모달 시트 패턴)
