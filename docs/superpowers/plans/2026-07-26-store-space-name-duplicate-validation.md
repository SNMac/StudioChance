# 점포명·공간명 중복 검증 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 점포 등록/수정 확정 시 (1) 사용자가 이미 보유한 다른 점포와 이름이 중복되는 경우, (2) 같은 점포 내에서 공간명이 중복되는 경우를 막고 alert로 안내한다.

**Architecture:** 검증 로직은 `StoreUseCaseImpl.createStore`/`updateStore`에 추가한다 (Firestore Rules가 아님 — 이건 보안 경계가 아니라 데이터 무결성/UX 목적이므로 D2의 정신을 따라 UseCase 레벨에 둔다). 새 도메인 예외(`StoreNameDuplicateException`, `SpaceNameDuplicateException`)를 던지면, `store_form_screen.dart`에 이미 존재하는 `ref.listen(status) → AppException → showCustomAlertDialog` 파이프라인이 그대로 재사용되어 **Presentation 레이어 코드 변경이 전혀 필요 없다**. 점포명 검증은 `currentUser.storeInfos`(이미 `getCurrentUserOrThrow`로 조회됨, 추가 네트워크 호출 없음)를 사용하고, 공간명 검증은 `store.spaceOptions`(폼에 이미 존재)를 사용한다.

**Tech Stack:** Dart, fpdart(Either/TaskEither), mocktail(테스트)

## Global Constraints

- 커밋 메시지: 한국어, `<type>: #17 - <설명>` 형식 (기존 OCR 브랜치 PR #24 리뷰에서 파생된 후속 작업이므로 이슈 #17 사용)
- Either 패턴: `result.fold((e) => ..., (v) => ...)` 함수형 스타일만 사용. `isLeft()`/`getLeft().toNullable()!` 명령형 스타일 금지 (테스트 코드 포함)
- `dart analyze` 클린 유지 (freezed 필드 변경 없으므로 `build_runner` 재실행 불필요)
- 테스트: `flutter test test/domain/use_cases/store_use_case_test.dart test/domain/use_cases/store_use_case_update_test.dart`
- 점포명 비교는 `trim()` 후 정확 일치(`==`)만 사용 — 프로젝트 전반의 "퍼지 매칭 없음" 컨벤션(OCR storeName/spaceName 매칭)과 동일하게 유지
- **알려진 한계 (범위 밖):** 검증은 `currentUser.storeInfos` 클라이언트 스냅샷 기준이라, 두 기기에서 동시에 같은 이름으로 점포를 생성하는 극단적 레이스는 이론상 막지 못한다. Firestore 트랜잭션 레벨 강제는 이번 범위에 포함하지 않는다 (D2와 동일한 리스크 허용 수준).

---

### Task 1: 점포명 중복 검증

**Files:**
- Modify: `lib/common/exceptions/store_exceptions.dart`
- Modify: `lib/domain/use_cases/store_use_case.dart`
- Test: `test/domain/use_cases/store_use_case_test.dart`
- Test: `test/domain/use_cases/store_use_case_update_test.dart`

**Interfaces:**
- Consumes: `StoreUseCaseImpl._userRepository` (기존), `User.storeInfos: List<UserStoreInfo>` (기존, `UserStoreInfo.id`/`UserStoreInfo.name` 사용)
- Produces: `StoreException? _findDuplicateNameError({required Store store, required User currentUser})` — Task 2에서 이 메서드를 확장한다. `StoreNameDuplicateException`, `SpaceNameDuplicateException` 클래스(Task 2는 후자를 사용).

- [x] **Step 1: 예외 클래스 2개를 한 번에 추가 (스캐폴딩)**

`lib/common/exceptions/store_exceptions.dart`의 `title` getter switch에서 마지막 그룹(`// 6. 유효성 검사 / 알 수 없는 에러`) 앞에 새 그룹 추가:

```dart
    // 7. 중복 검증
    StoreNameDuplicateException() => '이미 사용 중인 점포명입니다',
    SpaceNameDuplicateException() => '중복된 공간명이 있습니다',

    // 6. 유효성 검사 / 알 수 없는 에러
    StoreValidationException() ||
    StoreUnknownException() => '에러가 발생했습니다',
```

`content` getter switch도 동일하게 마지막 그룹 앞에 추가:

```dart
    // 7. 중복 검증
    StoreNameDuplicateException() =>
      '이미 보유하신 다른 점포와 이름이 같습니다.\n다른 점포명으로 입력해 주세요.',
    SpaceNameDuplicateException() =>
      '같은 점포 안에서는 공간명을 중복해서 사용할 수 없습니다.\n공간명을 다르게 입력해 주세요.',

    // 6. 유효성 검사 / 알 수 없는 에러
    StoreValidationException() ||
    StoreUnknownException() => '일시적인 에러가 발생했습니다.\n잠시 후 다시 시도해 주세요.',
```

`isSilentable` getter switch에 두 예외를 `false` 그룹에 추가:

```dart
  @override
  bool get isSilentable => switch (this) {
    StoreCancelledException() => true,
    StorePermissionDeniedException() ||
    StoreNotFoundException() ||
    StoreAlreadyExistsException() ||
    StoreNetworkException() ||
    StoreResourceExhaustedException() ||
    StoreTransactionException() ||
    StoreDataParsingException() ||
    StoreValidationException() ||
    StoreNameDuplicateException() ||
    SpaceNameDuplicateException() ||
    StoreUnknownException() => false,
  };
```

파일 맨 끝에 클래스 정의 추가:

```dart
/// 이미 보유한 다른 점포와 이름이 중복될 때 발생하는 예외
class StoreNameDuplicateException extends StoreException {
  StoreNameDuplicateException({required String message, String? code})
    : super(message, code: code);
}

/// 같은 점포 내에서 공간명이 중복될 때 발생하는 예외
class SpaceNameDuplicateException extends StoreException {
  SpaceNameDuplicateException({required String message, String? code})
    : super(message, code: code);
}
```

- [x] **Step 2: `dart analyze`로 sealed class exhaustiveness 확인**

Run: `dart analyze lib/common/exceptions/store_exceptions.dart`
Expected: `No issues found!` (이 시점엔 `SpaceNameDuplicateException`이 아직 어디서도 throw되지 않아도 sealed switch가 모든 서브타입을 다뤘으므로 에러 없음)

- [x] **Step 3: 실패하는 테스트 작성 — createStore 점포명 중복**

`test/domain/use_cases/store_use_case_test.dart` 상단 import에 추가:

```dart
import 'package:studio_chance/common/exceptions/store_exceptions.dart';
```

`group('createStore', () { ... })` 블록 안, 기존 테스트들 다음에 추가:

```dart
    test('보유한 다른 점포와 이름이 중복되면 left(StoreNameDuplicateException)를 반환하고 Repository를 호출하지 않는다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(fakeUser));

      final duplicateNameStore = fakeStore.copyWith(
        id: '',
        name: fakeUser.storeInfos.first.name,
      );

      final result = await useCase.createStore(
        store: duplicateNameStore,
        color: StoreColor.blue,
        memo: '메모',
      );

      expect(result.isLeft(), true);
      result.fold(
        (e) => expect(e, isA<StoreNameDuplicateException>()),
        (_) => fail('중복된 점포명인데 성공 처리됨'),
      );
      verifyNever(
        () => mockStoreRepo.createStore(
          store: any(named: 'store'),
          color: any(named: 'color'),
          memo: any(named: 'memo'),
        ),
      );
    });
```

- [x] **Step 4: 실패하는 테스트 작성 — updateStore 점포명 중복 + 자기 자신 예외 처리**

`test/domain/use_cases/store_use_case_update_test.dart` 상단 import에 추가:

```dart
import 'package:studio_chance/common/exceptions/store_exceptions.dart';
import 'package:studio_chance/domain/entities/user_store_info.dart';
import 'package:studio_chance/domain/enums/user_role.dart';
```

`group('updateStore', () { ... })` 블록 안, 기존 테스트들 다음에 추가:

```dart
    test('보유한 다른 점포와 이름이 중복되면 left(StoreNameDuplicateException)를 반환하고 Repository를 호출하지 않는다', () async {
      final userWithTwoStores = fakeUser.copyWith(
        storeInfos: [
          ...fakeUser.storeInfos,
          UserStoreInfo(
            id: 'store-456',
            name: '다른 점포',
            role: UserRole.admin,
            color: StoreColor.blue,
            memo: '',
          ),
        ],
      );
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(userWithTwoStores));

      final duplicateNameStore = fakeStore.copyWith(name: '다른 점포');

      final result = await useCase.updateStore(
        store: duplicateNameStore,
        color: StoreColor.blue,
        memo: '메모',
      );

      expect(result.isLeft(), true);
      result.fold(
        (e) => expect(e, isA<StoreNameDuplicateException>()),
        (_) => fail('중복된 점포명인데 성공 처리됨'),
      );
      verifyNever(
        () => mockStoreRepo.updateStore(
          store: any(named: 'store'),
          uid: any(named: 'uid'),
          color: any(named: 'color'),
          memo: any(named: 'memo'),
        ),
      );
    });

    test('자기 자신의 기존 이름은 중복으로 취급하지 않는다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(fakeUser));
      when(
        () => mockStoreRepo.updateStore(
          store: any(named: 'store'),
          uid: any(named: 'uid'),
          color: any(named: 'color'),
          memo: any(named: 'memo'),
        ),
      ).thenAnswer((_) async => right(null));

      // fakeStore.id == fakeUser.storeInfos.first.id, name도 동일 — 자기 자신이므로 통과해야 함
      final result = await useCase.updateStore(
        store: fakeStore,
        color: StoreColor.blue,
        memo: '메모',
      );

      expect(result.isRight(), true);
    });
```

- [x] **Step 5: 테스트 실행 → 실패 확인**

Run: `flutter test test/domain/use_cases/store_use_case_test.dart test/domain/use_cases/store_use_case_update_test.dart`
Expected: FAIL — 새로 추가한 3개 테스트가 실패 (아직 중복 검증 로직이 없어 `result.isLeft()`가 `false`이거나 `mockStoreRepo.createStore/updateStore`가 호출됨). 기존 테스트는 모두 PASS 유지.

- [x] **Step 6: `store_use_case.dart`에 중복 검증 로직 구현**

상단 import 추가:

```dart
import 'package:studio_chance/common/exceptions/store_exceptions.dart';
import 'package:studio_chance/domain/entities/user.dart';
```

`StoreUseCaseImpl` 클래스 내부(예: `createStore` 위)에 private 헬퍼 추가:

```dart
  /// 현재 유저가 보유한 다른 점포와 이름이 중복되는지 검증한다.
  /// [store.id]가 [currentUser.storeInfos] 항목과 일치하면 자기 자신이므로 제외한다.
  /// (신규 생성 시 store.id는 빈 문자열이라 자연히 아무 항목도 제외되지 않는다)
  StoreException? _findDuplicateNameError({
    required Store store,
    required User currentUser,
  }) {
    final trimmedStoreName = store.name.trim();
    final hasDuplicateStoreName = currentUser.storeInfos.any(
      (info) => info.id != store.id && info.name.trim() == trimmedStoreName,
    );
    if (hasDuplicateStoreName) {
      return StoreNameDuplicateException(message: '중복된 점포명: $trimmedStoreName');
    }
    return null;
  }
```

`createStore`를 다음과 같이 수정 (기존 `getCurrentUserOrThrow(...).flatMap((currentUser) { ... })` 블록 맨 앞에 검증 삽입):

```dart
  @override
  Future<Either<Exception, Store>> createStore({
    required Store store,
    required StoreColor color,
    required String memo,
  }) {
    return getCurrentUserOrThrow(_userRepository).flatMap((currentUser) {
      final duplicateError = _findDuplicateNameError(
        store: store,
        currentUser: currentUser,
      );
      if (duplicateError != null) {
        return TaskEither<Exception, Store>.left(duplicateError);
      }

      final adminMemberInfo = StoreMemberInfo(
        user: currentUser,
        role: UserRole.admin,
      );

      final storeWithAdmin = store.copyWith(
        memberInfos: [adminMemberInfo],
        waitingMemberInfos: [],
      );

      return TaskEither(
        () => _storeRepository.createStore(
          store: storeWithAdmin,
          color: color,
          memo: memo,
        ),
      );
    }).run();
  }
```

`updateStore`를 다음과 같이 수정:

```dart
  @override
  Future<Either<Exception, void>> updateStore({
    required Store store,
    required StoreColor color,
    required String memo,
  }) {
    return getCurrentUserOrThrow(_userRepository).flatMap((currentUser) {
      final duplicateError = _findDuplicateNameError(
        store: store,
        currentUser: currentUser,
      );
      if (duplicateError != null) {
        return TaskEither<Exception, void>.left(duplicateError);
      }

      return TaskEither(
        () => _storeRepository.updateStore(
          store: store,
          uid: currentUser.id,
          color: color,
          memo: memo,
        ),
      );
    }).run();
  }
```

- [x] **Step 7: 테스트 실행 → 통과 확인**

Run: `flutter test test/domain/use_cases/store_use_case_test.dart test/domain/use_cases/store_use_case_update_test.dart`
Expected: PASS — 기존 테스트 전부 + 새로 추가한 3개 테스트 모두 통과.

- [x] **Step 8: `dart analyze`**

Run: `dart analyze`
Expected: `No issues found!`

- [x] **Step 9: 커밋**

```bash
git add lib/common/exceptions/store_exceptions.dart lib/domain/use_cases/store_use_case.dart test/domain/use_cases/store_use_case_test.dart test/domain/use_cases/store_use_case_update_test.dart
git commit -m "feat: #17 - 점포명 중복 등록/수정 방지 검증 추가"
```

---

### Task 2: 공간명 중복 검증 (같은 점포 내)

**Files:**
- Modify: `lib/domain/use_cases/store_use_case.dart`
- Test: `test/domain/use_cases/store_use_case_test.dart`
- Test: `test/domain/use_cases/store_use_case_update_test.dart`

**Interfaces:**
- Consumes: Task 1의 `_findDuplicateNameError({required Store store, required User currentUser})`, `SpaceNameDuplicateException`(Task 1에서 이미 정의됨), `Store.spaceOptions: List<SpaceOption>`(기존)
- Produces: 없음 (이 플랜의 마지막 태스크)

- [ ] **Step 1: 실패하는 테스트 작성 — createStore 공간명 중복**

`test/domain/use_cases/store_use_case_test.dart` 상단 import에 추가:

```dart
import 'package:studio_chance/domain/entities/space_option.dart';
import 'package:studio_chance/domain/entities/price_setting.dart';
```

`group('createStore', () { ... })` 블록 안, Task 1에서 추가한 테스트 다음에 추가:

```dart
    test('같은 점포 내 공간명이 중복되면 left(SpaceNameDuplicateException)를 반환하고 Repository를 호출하지 않는다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(fakeUser));

      final duplicateSpaceStore = fakeStore.copyWith(
        id: '',
        name: '새 점포',
        spaceOptions: [
          SpaceOption(
            id: 'space-1',
            name: '공간A',
            priceSetting: PriceSetting.empty(),
          ),
          SpaceOption(
            id: 'space-2',
            name: '공간A',
            priceSetting: PriceSetting.empty(),
          ),
        ],
      );

      final result = await useCase.createStore(
        store: duplicateSpaceStore,
        color: StoreColor.blue,
        memo: '메모',
      );

      expect(result.isLeft(), true);
      result.fold(
        (e) => expect(e, isA<SpaceNameDuplicateException>()),
        (_) => fail('중복된 공간명인데 성공 처리됨'),
      );
      verifyNever(
        () => mockStoreRepo.createStore(
          store: any(named: 'store'),
          color: any(named: 'color'),
          memo: any(named: 'memo'),
        ),
      );
    });
```

- [ ] **Step 2: 실패하는 테스트 작성 — updateStore 공간명 중복**

`test/domain/use_cases/store_use_case_update_test.dart` 상단 import에 추가:

```dart
import 'package:studio_chance/domain/entities/space_option.dart';
import 'package:studio_chance/domain/entities/price_setting.dart';
```

`group('updateStore', () { ... })` 블록 안, Task 1에서 추가한 테스트 다음에 추가:

```dart
    test('같은 점포 내 공간명이 중복되면 left(SpaceNameDuplicateException)를 반환하고 Repository를 호출하지 않는다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(fakeUser));

      final duplicateSpaceStore = fakeStore.copyWith(
        spaceOptions: [
          SpaceOption(
            id: 'space-1',
            name: '공간A',
            priceSetting: PriceSetting.empty(),
          ),
          SpaceOption(
            id: 'space-2',
            name: '공간A',
            priceSetting: PriceSetting.empty(),
          ),
        ],
      );

      final result = await useCase.updateStore(
        store: duplicateSpaceStore,
        color: StoreColor.blue,
        memo: '메모',
      );

      expect(result.isLeft(), true);
      result.fold(
        (e) => expect(e, isA<SpaceNameDuplicateException>()),
        (_) => fail('중복된 공간명인데 성공 처리됨'),
      );
      verifyNever(
        () => mockStoreRepo.updateStore(
          store: any(named: 'store'),
          uid: any(named: 'uid'),
          color: any(named: 'color'),
          memo: any(named: 'memo'),
        ),
      );
    });
```

- [ ] **Step 3: 테스트 실행 → 실패 확인**

Run: `flutter test test/domain/use_cases/store_use_case_test.dart test/domain/use_cases/store_use_case_update_test.dart`
Expected: FAIL — 새로 추가한 2개 테스트가 실패. 나머지(Task 1 포함 기존 테스트)는 PASS 유지.

- [ ] **Step 4: `_findDuplicateNameError`에 공간명 중복 검증 추가**

`lib/domain/use_cases/store_use_case.dart`의 `_findDuplicateNameError` 메서드를 다음과 같이 수정 (점포명 체크 뒤에 공간명 체크 추가):

```dart
  StoreException? _findDuplicateNameError({
    required Store store,
    required User currentUser,
  }) {
    final trimmedStoreName = store.name.trim();
    final hasDuplicateStoreName = currentUser.storeInfos.any(
      (info) => info.id != store.id && info.name.trim() == trimmedStoreName,
    );
    if (hasDuplicateStoreName) {
      return StoreNameDuplicateException(message: '중복된 점포명: $trimmedStoreName');
    }

    final spaceNames = store.spaceOptions.map((s) => s.name.trim()).toList();
    final hasDuplicateSpaceName = spaceNames.toSet().length != spaceNames.length;
    if (hasDuplicateSpaceName) {
      return SpaceNameDuplicateException(message: '중복된 공간명: ${store.name}');
    }

    return null;
  }
```

`createStore`/`updateStore` 본문은 Task 1에서 이미 이 헬퍼를 호출하도록 연결되어 있으므로 추가 수정 불필요.

- [ ] **Step 5: 테스트 실행 → 통과 확인**

Run: `flutter test test/domain/use_cases/store_use_case_test.dart test/domain/use_cases/store_use_case_update_test.dart`
Expected: PASS — 전체 테스트(기존 + Task 1 + Task 2) 모두 통과.

- [ ] **Step 6: `dart analyze`**

Run: `dart analyze`
Expected: `No issues found!`

- [ ] **Step 7: 전체 회귀 테스트**

Run: `flutter test`
Expected: 모든 테스트 PASS (다른 기능에 영향 없음 확인).

- [ ] **Step 8: 커밋**

```bash
git add lib/domain/use_cases/store_use_case.dart test/domain/use_cases/store_use_case_test.dart test/domain/use_cases/store_use_case_update_test.dart
git commit -m "feat: #17 - 같은 점포 내 공간명 중복 등록/수정 방지 검증 추가"
```

---

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-07-26-store-space-name-duplicate-validation.md`. Two execution options:

1. **Subagent-Driven (recommended)** - 태스크별로 새 subagent를 띄워 리뷰하며 진행
2. **Inline Execution** - 이번 세션에서 executing-plans로 체크포인트마다 진행 상황 보고

Which approach?
