# 레이어별 리팩토링 검토 계획

Last Updated: 2026-05-18

---

## 개요

전체 코드베이스를 **Data → Domain → Presentation** 순서로 순회하며  
SOLID 원칙 위반, 객체지향 원리 미적용, 유지보수·확장성 문제를 식별하고 개선 계획을 수립한다.  
리팩토링 자체는 각 단계별 계획이 완료된 후 순서대로 진행한다.

---

## Phase 0 — 현황 분석 완료 요약

코드베이스를 직접 읽어 확인한 문제들이다.  
각 Phase는 이 문제들을 검토·수정하는 단계다.

---

## Phase 1 — Data Layer 리팩토링 계획

### 검토 대상 파일

| 파일 | 역할 |
|------|------|
| `data/data_sources/auth_data_source.dart` | Firebase Auth 접근 |
| `data/data_sources/user_data_source.dart` | Firestore User 접근 |
| `data/data_sources/store_data_source.dart` | Firestore Store 접근 |
| `data/data_sources/reservation_data_source.dart` | Firestore Reservation 접근 |
| `data/repositories/auth_repository_impl.dart` | Auth Repository 구현 |
| `data/repositories/user_repository_impl.dart` | User Repository 구현 |
| `data/repositories/store_repository_impl.dart` | Store Repository 구현 |
| `data/repositories/reservation_repository_impl.dart` | Reservation Repository 구현 |
| `data/models/*.dart` | Data → Entity 변환 모델 |

---

### 1-A. DataSource — `_handleFirestoreError` 중복 (DRY 위반)

**문제**: `UserFirestoreDataSource`, `StoreFirestoreDataSource`, `ReservationFirestoreDataSource` 세 곳 모두  
`_handleFirestoreError(Object e)` 메서드를 각각 구현하고 있다.  
Firebase 에러 코드 매핑(`permission-denied`, `not-found`, `resource-exhausted`, `unavailable` 등)  
90% 이상이 동일한 패턴이다.

**영향 범위**: 한 곳의 에러 코드 추가/수정이 3곳 모두 변경을 요구함.

**개선 방향**:
- `common/` 또는 `data/` 아래 `FirestoreErrorHandler` 믹스인/추상 클래스 추출
- 도메인별 Exception 타입만 주입받아 공통 switch 처리
- 각 DataSource는 도메인별 Exception 팩토리만 제공

**수용 기준**: 에러 코드 매핑 로직이 단일 위치에 존재하며, 신규 에러 코드 추가 시 1곳만 수정.

---

### 1-B. StoreDataSource — 비즈니스 로직 포함 (SRP 위반)

**문제**: `StoreFirestoreDataSource`가 DataSource 역할을 초과한다.

- `createInviteCode`: 기존 코드의 만료 여부 판단 후 재발급 결정 → 비즈니스 로직
- `getStoreByInviteCode`: 초대 코드 만료 여부 판단 후 `StoreValidationException` 발생 → 비즈니스 로직

DataSource는 DB I/O만 담당해야 하고, "유효한가?", "재발급해야 하나?"는 Repository 또는 UseCase가 판단해야 한다.

**개선 방향**:
- `createInviteCode(forceRegenerate)` 로직 분리: 만료 체크/판단을 Repository로 이동
- `getStoreByInviteCode`: DataSource는 단순히 문서 반환, 만료 검증은 Repository에서
- DataSource 메서드를 단순 CRUD + 쿼리로 단순화

**수용 기준**: DataSource는 Firestore I/O 로직만 포함. 비즈니스 판단(유효성, 만료) 없음.

---

### 1-C. UserDataSource — `updateUser` 마법 값 파라미터 (암묵적 계약)

**문제**: `updateUser(String uid, Map<String, dynamic> data)`에서  
호출부(`UserRepositoryImpl`)가 `'lastLoginAt': true`를 넣으면 내부에서 `FieldValue.serverTimestamp()`로 교체,  
`'fcmTokens': [token]`을 넣으면 `FieldValue.arrayUnion()`으로 교체한다.

호출 측과 구현 측 사이에 암묵적 계약이 존재하며, 인터페이스만 보고는 이 규칙을 파악할 수 없다.

**개선 방향 (경우에 따라 선택)**:
- 옵션 A: `updateUser`를 여러 전용 메서드로 분리 (`updateLastLoginAt()`, `unionFcmToken()`)
- 옵션 B: 마법 값 대신 명시적 파라미터/열거형 사용
- 현재 `addFcmToken`, `removeFcmToken` 같은 전용 메서드가 이미 일부 존재 → `updateUser`에서 fcmTokens 처리 제거 고려

**수용 기준**: 인터페이스를 보고 동작을 추론할 수 있음. 마법 값 없음.

---

### 1-D. Repository — `e is Exception ? e : Exception(e.toString())` 반복 (DRY 위반)

**문제**: 모든 Repository 구현체의 `catch` 블록에서 동일한 패턴 반복:
```dart
return left(e is Exception ? e : Exception(e.toString()));
```
6개 Repository × 평균 5개 메서드 = 30개 이상의 동일 표현식.

**개선 방향**:
- `_toException(Object e) => e is Exception ? e : Exception(e.toString())` 헬퍼 함수를 `common/` 또는 Repository mixin으로 추출
- 혹은 `Either<Exception, T> _safeRun(Future<T> Function() fn)` 래퍼 패턴 도입

**수용 기준**: `e is Exception ? e : Exception(e.toString())` 패턴이 하나의 위치에만 존재.

---

### 1-E. ReservationRepositoryImpl — 현재 사용자 조회 의존성 (설계 검토)

**문제**: `getReservationsByDateRange`, `getReservation`에서 `StoreSummary.color`를  
현재 사용자의 `storeById[storeId]`에서 가져오기 위해 `UserDataSource`를 사용한다.

Reservation 조회가 User 데이터에 의존하는 구조로, 두 도메인이 Repository 레벨에서 결합된다.

**개선 방향 (설계 검토 후 결정)**:
- 옵션 A (현행 유지): CLAUDE.md에 설계 의도 명시. 명확한 이유가 있다면 허용.
- 옵션 B: `StoreSummary.color`를 Presentation에서 주입 (Provider 레벨에서 색상 결합)
- 옵션 C: Reservation에 color를 저장 (Firestore 구조 변경 필요)

**수용 기준**: 선택된 방향이 문서화되고 일관성 있게 적용됨.

---

### 1-F. Models — Entity 변환 패턴 일관성 검토

**문제**: 일부 Model에 `toUpdateJson()` 같은 부분 직렬화 메서드가 있으나  
Model마다 제공 여부가 다름. 향후 수정 가능 필드 추가 시 누락될 수 있음.

**개선 방향**:
- `ReservationModel.toUpdateJson()`처럼 수정 가능 필드 제한 필요한 Model에만 추가
- 패턴 문서화 (어떤 경우에 `toUpdateJson`이 필요한지)

**수용 기준**: Model별 JSON 직렬화 전략이 CLAUDE.md에 명시되거나, 패턴이 일관됨.

---

## Phase 2 — Domain Layer 리팩토링 계획

### 검토 대상 파일

| 파일 | 역할 |
|------|------|
| `domain/use_cases/auth_use_case.dart` | Auth 비즈니스 로직 |
| `domain/use_cases/user_use_case.dart` | User 비즈니스 로직 |
| `domain/use_cases/store_use_case.dart` | Store 비즈니스 로직 |
| `domain/use_cases/reservation_use_case.dart` | Reservation 비즈니스 로직 |
| `domain/repository_interfaces/*.dart` | Repository 인터페이스 |
| `domain/entities/*.dart` | 도메인 엔티티 |
| `domain/enums/*.dart` | 도메인 열거형 |
| `common/exceptions/*.dart` | 예외 계층 |

---

### 2-A. UseCase — Data Layer 직접 임포트 (DIP 위반)

**문제**: Domain 레이어 UseCase 파일들이 Data 레이어 구현체를 직접 임포트한다.

```dart
// auth_use_case.dart
import 'package:studio_chance/data/repositories/auth_repository_impl.dart';
import 'package:studio_chance/data/repositories/user_repository_impl.dart';

// reservation_use_case.dart
import 'package:studio_chance/data/repositories/reservation_repository_impl.dart';
import 'package:studio_chance/data/repositories/store_repository_impl.dart';
import 'package:studio_chance/data/repositories/user_repository_impl.dart';
```

Riverpod Provider 등록(`@riverpod` 팩토리 함수)이 UseCase 파일 하단에 있어 구현체 참조가 불가피하다.  
UseCase 클래스 자체는 인터페이스만 의존하나, 파일 레벨 의존성이 오염된다.

**개선 방향**:
- UseCase 클래스와 Provider 팩토리를 파일로 분리
  - `auth_use_case.dart` → 순수 UseCase 인터페이스 + 구현체
  - `auth_use_case_provider.dart` → Riverpod Provider 등록 (Data Layer 임포트는 여기서만)
- 혹은 Provider 등록을 별도 `providers/` 디렉토리로 이동

**수용 기준**: Domain 레이어 클래스 파일에 `data/` 경로 import 없음.

---

### 2-B. UseCase — `_getCurrentUser` 중복 (DRY 위반)

**문제**: `StoreUseCaseImpl._getCurrentUser()`와 `ReservationUseCaseImpl._getCurrentUser()`가 완전히 동일한 구현을 가진다.

```dart
TaskEither<Exception, User> _getCurrentUser() {
  return TaskEither.tryCatch(() async {
    final result = await _userRepository.getCurrentUser();
    return result.fold((left) => throw left, (right) {
      if (right == null) throw AuthUserNotFoundException(...);
      return right;
    });
  }, (error, stackTrace) => error is Exception ? error : Exception(error));
}
```

**개선 방향**:
- `mixin CurrentUserMixin` 또는 `extension` 추출
- 또는 `UserRepository`에서 `TaskEither`를 직접 반환하는 메서드 추가 고려

**수용 기준**: `_getCurrentUser` 로직이 단일 위치에 존재.

---

### 2-C. UseCase — Either 체이닝 패턴 불일치 (일관성 문제)

**문제**: UseCase 내에서 Either를 처리하는 방식이 파일마다 다르다.

- `authUseCase.delete()`: `currentUserResult.isLeft()` 체크 + `getLeft().toNullable()!` (명령형)
- `storeUseCase.createStore()`: `_getCurrentUser().flatMap().run()` (함수형 TaskEither)
- `signOut()`: `currentUserResult.isRight()` 체크 (명령형)

명령형/함수형 혼용은 코드 일관성을 해치고 새 UseCase 작성 시 패턴 선택을 어렵게 만든다.

**개선 방향**:
- 팀 내 패턴 합의: 함수형(TaskEither 체이닝)을 기본으로 하되, 예외 상황에서만 명령형 허용
- `authUseCase.delete()`를 TaskEither 체이닝으로 통일 (또는 반대 방향)
- 패턴 결정을 CLAUDE.md에 명시

**수용 기준**: 동일 UseCase 내에서 Either 처리 패턴이 일관됨.

---

### 2-D. StoreUseCase — 권한 검증 미구현

**문제**: `approveMember`, `updateMemberRole`에서 현재 사용자가 Admin인지 검증하지 않는다.  
현재는 Firestore Security Rules에 의존하지만, UseCase 레벨 검증이 없으면  
비즈니스 규칙이 인프라(Firestore)에 분산된다.

```dart
// 실제로는 여기서 '현재 유저가 관리자 권한이 있는지' 체크하는 로직이 들어갈 수 있습니다.
return TaskEither(...).run();
```

**개선 방향**:
- UseCase 레벨에서 현재 사용자 role 검증 추가 여부 결정
- 결정 기준: "Firestore Rules만으로 충분한가" vs "UseCase가 도메인 규칙을 명시해야 하는가"

**수용 기준**: 권한 검증 위치(UseCase vs Firestore Rules)가 명확히 결정되고 문서화됨.

---

### 2-E. ReservationUseCase — 가격 계산을 위한 Store 조회 (결합도)

**문제**: `ReservationUseCaseImpl`이 `StoreRepository`를 주입받아 `_applyCalculatedPrice`에서 점포를 조회한다.  
Reservation UseCase가 Store 도메인에 직접 의존하는 구조다.

**개선 방향 (설계 검토 후 결정)**:
- 옵션 A (현행 유지): 가격 계산은 Reservation 저장 전 필수 단계이므로 허용
- 옵션 B: 가격 계산 책임을 별도 PricingService(UseCase)로 분리
- 옵션 C: 호출부(Controller)에서 Store를 직접 전달받아 UseCase에 주입

**수용 기준**: 선택된 방향이 문서화됨.

---

### 2-F. Common Exceptions — 레이어 배치 검토

**문제**: `common/exceptions/` 아래 예외들(`ReservationException`, `StoreException` 등)이  
Firebase 에러 코드와 1:1 매핑되어 있어 사실상 Data Layer에 종속된 정의다.  
Domain Entity가 이 예외를 참조하면 Domain → Data 의존이 발생할 수 있다.

**개선 방향 (설계 검토 후 결정)**:
- 현재 구조: common은 모든 레이어에서 공유 — 허용 가능한 설계
- 더 엄격한 분리: Domain 예외(`DomainException`)와 Infrastructure 예외(`InfraException`)를 분리
- 현행 유지 + 명확한 사용 가이드 문서화

**수용 기준**: Exception 계층의 레이어 배치 결정이 CLAUDE.md에 반영됨.

---

## Phase 3 — Presentation Layer 리팩토링 계획

### 검토 대상 파일

#### 3-A 그룹: Providers (상태 관리)
| 파일 | 역할 |
|------|------|
| `presentation/providers/app_auth_controller.dart` | 앱 인증 상태 |
| `presentation/providers/home_calendar_controller.dart` | 캘린더 UI 상태 |
| `presentation/providers/home_reservations_provider.dart` | 홈 예약 데이터 |
| `presentation/providers/hour_height_preference_provider.dart` | 시간 행 높이 설정 |
| `presentation/providers/auth_provider.dart` | Auth 스트림 |

#### 3-B 그룹: Store 입력 공통 컨트롤러
| 파일 | 역할 |
|------|------|
| `commons/store_input/controllers/store_form_controllerable.dart` | 인터페이스 + Mixin |
| `commons/store_input/controllers/store_creation_controller.dart` | 점포 생성 |
| `commons/store_input/controllers/store_update_controller.dart` | 점포 수정 |

#### 3-C 그룹: 기타 Controller/Screen
| 파일 | 역할 |
|------|------|
| `commons/invite_code/controllers/*.dart` | 초대 코드 검증 |
| `commons/nickname_input/controllers/*.dart` | 닉네임 입력 |
| `commons/role_selection/controllers/*.dart` | 역할 선택 |
| `onboarding/controllers/*.dart` | 온보딩 |
| `sign_in/controllers/*.dart` | 로그인 |

#### 3-D 그룹: 위젯
| 파일 | 역할 |
|------|------|
| `home/widgets/` | 홈 화면 위젯들 (캘린더, 모달) |
| `commons/widgets/` | 공통 위젯들 |

---

### 3-A. Providers — `ref.watch` select 미사용 (성능)

**문제**: CLAUDE.md에 명시된 성능 가이드라인(select 사용)이 일부 파일에서 지켜지지 않을 수 있음.  
`homeCalendarController` 등 상태 객체 전체를 watch하는 위젯이 있을 경우 불필요한 rebuild 발생.

**검토 항목**: 위젯에서 특정 필드 1~2개만 사용하는데 전체 상태를 watch하는 경우  
→ `ref.watch(provider.select((s) => s.field))` 적용 여부 확인

**수용 기준**: 위젯에서 사용하는 필드가 전체의 일부면 select 적용.

---

### 3-B. StoreUpdateController — `firstWhere` + try-catch (코드 품질)

**문제**: `StoreUpdateController.build()`에서:
```dart
try {
  color = currentUser.storeInfos.firstWhere((e) => e.id == store.id).color;
  memo = currentUser.storeInfos.firstWhere((e) => e.id == store.id).memo;
} catch (_) {}
```
- `firstWhere`가 두 번 반복 호출되며, 찾지 못할 경우 예외를 삼킴
- `firstWhereOrNull` 또는 단일 호출로 개선 가능

**개선 방향**:
```dart
final storeInfo = currentUser.storeInfos.firstWhereOrNull((e) => e.id == store.id);
final color = storeInfo?.color ?? StoreColor.red;
final memo = storeInfo?.memo ?? '';
```

**수용 기준**: `firstWhere` + try-catch 대신 null-safe 패턴 사용.

---

### 3-C. StoreCreationController.submit — Either 처리 불일치

**문제**: `submit()`에서:
```dart
if (result.isLeft()) throw result.getLeft().toNullable()!;
```
`StoreUpdateController`는 `result.fold()`를 사용하는데 `StoreCreationController`는 명령형 스타일.  
같은 기능의 컨트롤러가 다른 패턴을 사용하여 코드 일관성이 떨어짐.

**개선 방향**: 두 컨트롤러 모두 `result.fold()`로 통일 또는 `AsyncValue.guard` 활용 고려.

**수용 기준**: StoreCreationController와 StoreUpdateController의 submit 패턴이 동일.

---

### 3-D. Home 위젯 — 대형 위젯 분해 검토

**검토 대상**: `home/widgets/three_day_calendar/`, `home/widgets/monthly_calendar/`  
현재는 여러 파일로 분리되어 있으나, 각 파일의 책임 분리가 적절한지 확인.

**검토 항목**:
- 위젯이 과도한 비즈니스 로직을 포함하는가
- `build()` 내에서 무거운 연산이 발생하는가
- `ScrollController` 관리가 CLAUDE.md 패턴을 준수하는가

---

### 3-E. ReservationInputForm — 미완성 코드 (Dead Code)

**문제**: `reservation_input_form.dart`가 `Placeholder()`만 반환하며, 실제 구현이 주석 처리됨.  
이 파일은 현재 사용되지 않거나 WIP 상태.

**개선 방향**: 미완성 파일임을 명확히 하거나 삭제 후 필요 시 재생성.

---

## 실행 순서 (Phase 별)

```
Phase 1 (Data)
  ├── 1-A: _handleFirestoreError 공통화
  ├── 1-B: StoreDataSource 비즈니스 로직 분리
  ├── 1-C: updateUser 마법 값 정리
  ├── 1-D: Repository catch 패턴 공통화
  └── 1-E: ReservationRepository User 의존성 설계 결정

Phase 2 (Domain)
  ├── 2-A: UseCase Data Layer 직접 임포트 제거
  ├── 2-B: _getCurrentUser 중복 제거
  ├── 2-C: Either 체이닝 패턴 통일
  ├── 2-D: 권한 검증 위치 결정
  └── 2-E: 가격 계산 의존성 설계 결정

Phase 3 (Presentation)
  ├── 3-A: select 미적용 위젯 확인 및 적용
  ├── 3-B: firstWhere + try-catch 개선
  ├── 3-C: submit 패턴 통일
  ├── 3-D: 대형 위젯 책임 검토
  └── 3-E: Dead code 정리
```

---

## 위험 평가

| 항목 | 위험도 | 이유 |
|------|--------|------|
| 1-A (에러 핸들러 공통화) | 낮음 | 행동 변화 없음, 리팩토링만 |
| 1-B (DS 비즈니스 로직 분리) | 중간 | Repository 로직 변경, 테스트 필요 |
| 2-A (UseCase import 분리) | 낮음 | 파일 분리만, 런타임 변화 없음 |
| 2-C (Either 패턴 통일) | 낮음 | 동작 동일, 스타일만 |
| 3-B (firstWhere 개선) | 낮음 | 버그 수정에 가까움 |

---

## 성공 지표

- SOLID 원칙 각 항목별 위반 사례 0개 (리팩토링 후)
- 새 기능 추가 시 변경 파일 수 최소화 (OCP 검증)
- 코드 리뷰 시 "왜 이렇게 했나?" 질문 없는 코드
- 각 Phase 완료 후 `flutter analyze` 에러 0개
