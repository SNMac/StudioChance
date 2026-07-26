# Data Layer Critical/Important 이슈 수정 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** GitHub 이슈 [#14](https://github.com/SNMac/StudioChance/issues/14)에서 지적된 Data Layer의 Critical 4건, Important 7건, Minor 3건(총 14건)을 각각 독립적으로 테스트 가능한 최소 단위로 수정한다.

**Architecture:** 기존 Clean Architecture(Data/Domain/Presentation) 구조를 그대로 유지한 채, `data_sources`, `repositories`, `models`, 일부 `domain/enums`, `domain/use_cases` 파일만 손댄다. 새 계층이나 추상화는 추가하지 않고, 이미 코드베이스에 존재하는 패턴(예: `ReservationPlatform.jsonValue`, `updateMemberRole`의 batch 이중 업데이트, `store_model.dart`의 allowlist `toEditableJson()`)을 그대로 재사용해 일관성을 유지한다.

**Tech Stack:** Flutter/Dart, Firestore(`cloud_firestore`), `freezed`+`json_serializable`, `fpdart`(`Either`), `mocktail`(Repository 단위 테스트), `fake_cloud_firestore`(DataSource 단위 테스트).

## Global Constraints

- 모든 Repository 메서드는 `Either<Exception, T>` 반환, `result.fold(...)` 함수형 패턴 사용 (isLeft/isRight 명령형 스타일 금지)
- `Future.wait`에 서로 다른 반환 타입을 섞지 않는다 — 타입별 개별 Future 변수로 분리
- 콘솔 출력은 `logger` 패키지만 사용
- 커밋 메시지: `<type>: #14 - <한국어 설명>` 형식, 태스크 단위로 커밋
- 브랜치: `bug/#14-data-layer-critical-important-fixes` (아직 없다면 `develop`에서 생성)
- 이 계획의 모든 변경은 Freezed 모델의 필드나 `@riverpod` provider 시그니처를 바꾸지 않으므로 `build_runner`는 실행할 필요 없음
- 정식 출시 전(프로덕션 데이터 없음)이므로 Firestore 스키마/문서 변경에 대한 마이그레이션은 고려하지 않는다
- 테스트는 기존 관례를 따른다: DataSource는 `FakeFirebaseFirestore` + `FirestoreEmulatorHelper`, Repository는 `mocktail` Mock

---

## File Structure

| 파일 | 역할 |
|---|---|
| `lib/data/repositories/user_repository_impl.dart` | [C-1] color 직렬화 수정 |
| `lib/domain/enums/reservation_status.dart` | [C-2] `jsonValue` getter 추가 |
| `lib/data/repositories/reservation_repository_impl.dart` | [C-2] status 직렬화 / [I-3] 작성자 없음 방어 / [I-7] currentUser 캐싱 |
| `lib/data/repositories/store_repository_impl.dart` | [C-3] Future.wait 분리 / [I-5] softDeleteStore 정리 / [I-6] 서버시간 사용 / [M-5] legacy fallback 이동 |
| `lib/data/data_sources/user_data_source.dart` | [C-4] fetchUserWithRestoration 재조회 / [M-3] fcmTokens 저장 |
| `lib/data/data_sources/gemini_data_source.dart` | [I-1] 필수 필드 검증 |
| `lib/domain/use_cases/reservation_ocr_use_case.dart` | [I-1] 중복 검증 제거 |
| `lib/data/data_sources/reservation_data_source.dart` | [I-2] Stream handleError StackTrace |
| `lib/data/data_sources/store_data_source.dart` | [I-4] approveMember role 동기화 / [I-5] softDeleteStore 시그니처 변경 / [I-6] getServerTime 추가 |
| `firestore.rules` | [I-6] 서버 시각 조회용 scratch 문서 규칙 추가 |
| `lib/data/models/reservation_model.dart` | [M-4] toUpdateJson allowlist화 |
| `lib/data/models/store_model.dart` | [M-5] legacy fallback 로직 제거 |

각 항목은 파일 하나 또는 서로 강하게 결합된 파일 소수(인터페이스+구현체, 또는 데이터소스+리포지토리)만 건드리며, 태스크 단위로 나눠 커밋한다.

---

## Task 1: [C-1] UserRepositoryImpl — `color` 직렬화 버그 수정

**Files:**
- Modify: `lib/data/repositories/user_repository_impl.dart:130-137`
- Test: `test/data/repositories/user_repository_test.dart` (신규 생성)

**Interfaces:**
- Consumes: `UserStoreInfoModel({required name, required role, required color, required memo})`, `UserRole.none`(이미 `store_repository_impl.dart`에서 사용 중인 값)
- Produces: 없음 (내부 버그 수정, 외부 시그니처 불변)

- [x] **Step 1: 실패하는 테스트 작성**

`store_repository_update_test.dart`와 동일한 mocktail 컨벤션으로 새 파일을 만든다.

```dart
// test/data/repositories/user_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/data/data_sources/auth_data_source.dart';
import 'package:studio_chance/data/data_sources/notification_data_source.dart';
import 'package:studio_chance/data/data_sources/user_data_source.dart';
import 'package:studio_chance/data/repositories/user_repository_impl.dart';
import 'package:studio_chance/domain/enums/store_color.dart';

class MockAuthDataSource extends Mock implements AuthDataSource {}

class MockUserDataSource extends Mock implements UserDataSource {}

class MockNotificationDataSource extends Mock
    implements NotificationDataSource {}

void main() {
  late UserRepositoryImpl repository;
  late MockAuthDataSource mockAuthDs;
  late MockUserDataSource mockUserDs;
  late MockNotificationDataSource mockNotificationDs;

  setUp(() {
    mockAuthDs = MockAuthDataSource();
    mockUserDs = MockUserDataSource();
    mockNotificationDs = MockNotificationDataSource();
    repository = UserRepositoryImpl(
      authDataSource: mockAuthDs,
      userDataSource: mockUserDs,
      notificationDataSource: mockNotificationDs,
    );
  });

  group('updateStoreInfo', () {
    test('color는 대문자 JSON 값(예: GREEN)으로 저장된다', () async {
      Map<String, dynamic>? capturedData;
      when(
        () => mockUserDs.updateStoreInfo(any(), any(), any()),
      ).thenAnswer((invocation) async {
        capturedData =
            invocation.positionalArguments[2] as Map<String, dynamic>;
      });

      final result = await repository.updateStoreInfo(
        uid: 'user-123',
        storeId: 'store-123',
        color: StoreColor.green,
      );

      expect(result.isRight(), true);
      expect(capturedData?['color'], 'GREEN');
    });
  });
}
```

- [x] **Step 2: 테스트 실행하여 실패 확인**

Run: `flutter test test/data/repositories/user_repository_test.dart`
Expected: FAIL — `capturedData?['color']`가 `'green'`(소문자)으로 나와 `'GREEN'`과 불일치

- [x] **Step 3: `user_repository_impl.dart` 수정**

`lib/data/repositories/user_repository_impl.dart` 상단 import에 추가:

```dart
import 'package:studio_chance/data/models/user_store_info_model.dart';
import 'package:studio_chance/domain/enums/user_role.dart';
```

`updateStoreInfo` 내부(기존 130-137줄)를 다음으로 교체:

```dart
      final Map<String, dynamic> data = {};

      if (name != null) data['name'] = name;
      if (color != null) {
        // color.name은 Dart 식별자('green')를 반환하므로 toJson()으로 JSON 값('GREEN') 직렬화
        // (store_repository_impl.dart의 updateStore와 동일한 패턴)
        final colorJson = UserStoreInfoModel(
          name: '', role: UserRole.none, color: color, memo: '',
        ).toJson()['color'] as String;
        data['color'] = colorJson;
      }

      if (data.isEmpty) return right(null);
```

- [x] **Step 4: 테스트 실행하여 통과 확인**

Run: `flutter test test/data/repositories/user_repository_test.dart`
Expected: PASS

- [x] **Step 5: 커밋**

```bash
git add lib/data/repositories/user_repository_impl.dart test/data/repositories/user_repository_test.dart
git commit -m "fix: #14 - [C-1] UserRepositoryImpl color 직렬화 버그 수정"
```

---

## Task 2: [C-2] ReservationRepositoryImpl — `status` 직렬화 버그 수정

**Files:**
- Modify: `lib/domain/enums/reservation_status.dart`
- Modify: `lib/data/repositories/reservation_repository_impl.dart:224-228`
- Test: `test/domain/enums/reservation_status_test.dart` (신규)
- Test: `test/data/repositories/reservation_repository_test.dart:211-229` (기존 잘못된 검증 수정)

**Interfaces:**
- Produces: `ReservationStatus.jsonValue` (String getter) — `ReservationPlatform.jsonValue`와 동일한 스타일

- [x] **Step 1: 실패하는 테스트 작성 (enum)**

```dart
// test/domain/enums/reservation_status_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_chance/domain/enums/reservation_status.dart';

void main() {
  group('ReservationStatus.jsonValue', () {
    test('pending은 PENDING을 반환한다', () {
      expect(ReservationStatus.pending.jsonValue, 'PENDING');
    });

    test('confirmed는 CONFIRMED를 반환한다', () {
      expect(ReservationStatus.confirmed.jsonValue, 'CONFIRMED');
    });

    test('canceled는 CANCELED를 반환한다', () {
      expect(ReservationStatus.canceled.jsonValue, 'CANCELED');
    });
  });
}
```

- [x] **Step 2: 테스트 실행하여 실패 확인**

Run: `flutter test test/domain/enums/reservation_status_test.dart`
Expected: FAIL — `jsonValue` getter가 존재하지 않아 컴파일 에러

- [x] **Step 3: `reservation_status.dart`에 `jsonValue` 추가**

`lib/domain/enums/reservation_status.dart`의 `displayName` getter 아래에 추가:

```dart
  String get jsonValue => switch (this) {
    ReservationStatus.pending => 'PENDING',
    ReservationStatus.confirmed => 'CONFIRMED',
    ReservationStatus.canceled => 'CANCELED',
  };
```

- [x] **Step 4: enum 테스트 통과 확인**

Run: `flutter test test/domain/enums/reservation_status_test.dart`
Expected: PASS

- [x] **Step 5: 기존 잘못된 Repository 테스트를 올바른 기대값으로 수정**

`test/data/repositories/reservation_repository_test.dart:211-229`의 `updateReservationStatus` 그룹 중 첫 번째 테스트를 다음으로 교체:

```dart
  group('updateReservationStatus', () {
    test('status를 대문자 JSON 값(jsonValue)으로 DataSource에 전달한다', () async {
      Map<String, dynamic>? capturedData;
      when(
        () => mockReservationDs.updateReservation(any(), any(), any()),
      ).thenAnswer((invocation) async {
        capturedData =
            invocation.positionalArguments[2] as Map<String, dynamic>;
      });

      final result = await repository.updateReservationStatus(
        storeId: 'store-123',
        reservationId: 'res-001',
        status: ReservationStatus.confirmed,
      );

      expect(result.isRight(), true);
      expect(capturedData?['status'], 'CONFIRMED');
    });
```

(이후 `DataSource 실패 시 left(exception)를 반환한다` 테스트는 그대로 둔다.)

- [x] **Step 6: Repository 테스트 실행하여 실패 확인**

Run: `flutter test test/data/repositories/reservation_repository_test.dart`
Expected: FAIL — 현재 구현은 `status.name`(`'confirmed'`)을 보내므로 `'CONFIRMED'`와 불일치

- [x] **Step 7: `reservation_repository_impl.dart` 수정**

`lib/data/repositories/reservation_repository_impl.dart`의 `updateReservationStatus`(224-229줄)를 수정:

```dart
      await _reservationDataSource.updateReservation(
        storeId,
        reservationId,
        {'status': status.jsonValue},
      );
      _logger.i(
        '예약 상태 변경 완료\nid: $reservationId, status: ${status.jsonValue}',
      );
```

- [x] **Step 8: Repository 테스트 통과 확인**

Run: `flutter test test/data/repositories/reservation_repository_test.dart`
Expected: PASS

- [x] **Step 9: 커밋**

```bash
git add lib/domain/enums/reservation_status.dart lib/data/repositories/reservation_repository_impl.dart test/domain/enums/reservation_status_test.dart test/data/repositories/reservation_repository_test.dart
git commit -m "fix: #14 - [C-2] ReservationRepositoryImpl status 직렬화 버그 수정"
```

---

## Task 3: [C-3] StoreRepositoryImpl.getStore — Future.wait 분리 패턴 적용

**Files:**
- Modify: `lib/data/repositories/store_repository_impl.dart:76-99`
- Test: `test/data/repositories/store_repository_integration_test.dart` (기존 회귀 테스트로 검증)

**Interfaces:**
- 외부 시그니처 불변 — 내부 구현만 `getStoreByInviteCode`(179-212줄)와 동일한 분리 패턴으로 통일

- [x] **Step 1: 기존 회귀 테스트가 통과함을 먼저 확인 (베이스라인)**

Run: `flutter test test/data/repositories/store_repository_integration_test.dart --plain-name "getStore memberInfos가 users 컬렉션에서 hydrate된다"`
Expected: PASS (수정 전 베이스라인 확인용, 이 테스트가 리팩터링 후에도 계속 통과해야 함)

- [x] **Step 2: `getStore` 구현을 분리 패턴으로 리팩터링**

`lib/data/repositories/store_repository_impl.dart`의 `getStore`(76-99줄) 중 84-92줄을 교체:

```dart
      final memberInfosFuture = _fetchMembersWithRoles(storeModel.memberById);
      final waitingInfosFuture =
          _fetchMembersWithRoles(storeModel.waitingMemberById);
      final memberInfos = await memberInfosFuture;
      final waitingInfos = await waitingInfosFuture;

      return right(
        storeModel.toEntity(
          memberInfos: memberInfos,
          waitingMemberInfos: waitingInfos,
        ),
      );
```

(`Future.wait([...])` 호출 자체를 제거하고, `getStoreByInviteCode`와 동일하게 개별 Future 변수를 먼저 만든 뒤 순차 `await`한다 — 실제로는 두 Future가 이미 시작된 상태라 병렬로 실행된다.)

- [x] **Step 3: 회귀 테스트 재실행하여 통과 확인**

Run: `flutter test test/data/repositories/store_repository_integration_test.dart`
Expected: PASS (전체 그룹, 특히 `createStore + getStore` 그룹)

- [x] **Step 4: 커밋**

```bash
git add lib/data/repositories/store_repository_impl.dart
git commit -m "fix: #14 - [C-3] StoreRepositoryImpl.getStore Future.wait 혼합 타입 패턴 제거"
```

---

## Task 4: [C-4] UserDataSource.fetchUserWithRestoration — 재조회 방식으로 수정

**Files:**
- Modify: `lib/data/data_sources/user_data_source.dart:117-140`
- Test: `test/data/data_sources/user_data_source_test.dart:161-212` (기존 그룹 확장)

**Interfaces:**
- Consumes: `getUser(String uid)`(같은 클래스 내 기존 메서드), `restoreUser(String uid)`(같은 클래스 내 기존 메서드)
- 외부 시그니처 불변

- [x] **Step 1: 실패하는 테스트 작성**

`test/data/data_sources/user_data_source_test.dart`의 `fetchUserWithRestoration` 그룹(161-212줄)에 테스트 추가:

```dart
    test('복구된 사용자는 갱신된 문서를 재조회하여 반환한다 (deletedAt/expiresAt 없이)', () async {
      final user = _testUser();
      await fakeFirestore.collection('users').doc(user.id).set({
        'email': user.email,
        'name': user.name,
        'nickname': user.nickname,
        'authProviders': <String>[],
        'storeById': <String, dynamic>{},
        'deletedAt': Timestamp.now(),
        'expiresAt': Timestamp.now(),
      });

      final result = await dataSource.fetchUserWithRestoration(user.id);

      // 재조회 결과이므로 로컬에서 임의로 지운 필드가 아니라
      // Firestore에 실제로 반영된 상태를 기반으로 파싱된 모델이어야 한다.
      final doc = await fakeFirestore.collection('users').doc(user.id).get();
      expect(doc.data()?.containsKey('deletedAt'), false);
      expect(doc.data()?.containsKey('expiresAt'), false);
      expect(result, isNotNull);
      expect(result!.id, user.id);
    });
```

- [x] **Step 2: 테스트 실행하여 기존 구현으로도 통과하는지 확인 (회귀 방지 목적)**

Run: `flutter test test/data/data_sources/user_data_source_test.dart --plain-name "fetchUserWithRestoration"`
Expected: PASS (현재 구현도 이 케이스는 통과함 — 이 스텝은 리팩터링 전 동작을 고정하는 안전망)

- [x] **Step 3: `fetchUserWithRestoration`을 재조회 방식으로 리팩터링**

`lib/data/data_sources/user_data_source.dart`의 `fetchUserWithRestoration`(117-140줄)을 교체:

```dart
  @override
  Future<UserModel?> fetchUserWithRestoration(String uid) async {
    try {
      final docSnapshot = await _userDocRef(uid).get();

      if (!docSnapshot.exists || docSnapshot.data() == null) {
        return null;
      }

      final data = docSnapshot.data()!;

      if (data['deletedAt'] == null) {
        data['id'] = docSnapshot.id;
        return UserModel.fromJson(data);
      }

      logger.i('탈퇴 계정 감지: $uid');
      await restoreUser(uid);

      // restoreUser가 실패 없이 완료된 뒤에만 도달 — 로컬에서 필드를 지우는 대신
      // Firestore에 실제로 반영된 최신 상태를 재조회하여 상태 불일치를 방지한다.
      return getUser(uid);
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }
```

- [x] **Step 4: 전체 `fetchUserWithRestoration` / `getUser` 그룹 재실행하여 통과 확인**

Run: `flutter test test/data/data_sources/user_data_source_test.dart`
Expected: PASS (모든 기존 테스트 + 신규 테스트)

- [x] **Step 5: 커밋**

```bash
git add lib/data/data_sources/user_data_source.dart test/data/data_sources/user_data_source_test.dart
git commit -m "fix: #14 - [C-4] fetchUserWithRestoration 재조회 방식으로 상태 불일치 위험 제거"
```

---

## Task 5: [I-1] Gemini OCR 응답 — 필수 필드 null 검증

**Files:**
- Modify: `lib/data/data_sources/gemini_data_source.dart`
- Modify: `lib/domain/use_cases/reservation_ocr_use_case.dart`
- Test: `test/data/data_sources/gemini_data_source_test.dart` (신규)

**Interfaces:**
- Produces: 최상위 함수 `void validateOcrRequiredFields(Map<String, dynamic> json)` — `gemini_data_source.dart`에 정의, `analyzeReservationImage`가 Firebase AI SDK를 직접 호출하는 구조라 SDK 없이는 전체 메서드를 단위 테스트할 수 없으므로, 검증 로직만 순수 함수로 분리해 테스트 가능하게 만든다.
- Consumes: `OcrParsingException`(`lib/common/exceptions/ocr_exceptions.dart`, 기존)

- [x] **Step 1: 실패하는 테스트 작성**

```dart
// test/data/data_sources/gemini_data_source_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_chance/common/exceptions/ocr_exceptions.dart';
import 'package:studio_chance/data/data_sources/gemini_data_source.dart';

void main() {
  group('validateOcrRequiredFields', () {
    test('customerName, customerPhone, startTime이 모두 null이면 OcrParsingException을 던진다', () {
      expect(
        () => validateOcrRequiredFields(const {
          'customerName': null,
          'customerPhone': null,
          'startTime': null,
        }),
        throwsA(isA<OcrParsingException>()),
      );
    });

    test('customerName만 있어도 예외를 던지지 않는다', () {
      expect(
        () => validateOcrRequiredFields(const {
          'customerName': '홍길동',
          'customerPhone': null,
          'startTime': null,
        }),
        returnsNormally,
      );
    });

    test('startTime만 있어도 예외를 던지지 않는다', () {
      expect(
        () => validateOcrRequiredFields(const {
          'customerName': null,
          'customerPhone': null,
          'startTime': '2026-05-01T10:00:00',
        }),
        returnsNormally,
      );
    });
  });
}
```

- [x] **Step 2: 테스트 실행하여 실패 확인**

Run: `flutter test test/data/data_sources/gemini_data_source_test.dart`
Expected: FAIL — `validateOcrRequiredFields`가 존재하지 않아 컴파일 에러

- [x] **Step 3: `gemini_data_source.dart`에 검증 함수 추가 및 호출**

`lib/data/data_sources/gemini_data_source.dart`의 `GeminiDataSourceImpl` 클래스 선언 위(최상위)에 추가:

```dart
/// Gemini 파싱 결과에서 핵심 필드(customerName, customerPhone, startTime)가
/// 모두 null이면 파싱 실패로 간주하고 예외를 던진다.
void validateOcrRequiredFields(Map<String, dynamic> json) {
  final hasCustomerName = json['customerName'] != null;
  final hasCustomerPhone = json['customerPhone'] != null;
  final hasStartTime = json['startTime'] != null;
  if (!hasCustomerName && !hasCustomerPhone && !hasStartTime) {
    throw OcrParsingException('핵심 필드를 추출하지 못했습니다.');
  }
}
```

`analyzeReservationImage` 내부(기존 131-135줄)를 수정:

```dart
    if (json['isReservationImage'] != true) {
      throw OcrNotReservationException('예약 이미지 아님');
    }
    validateOcrRequiredFields(json);
    return ReservationOcrResultModel.fromJson(json);
```

- [x] **Step 4: 테스트 실행하여 통과 확인**

Run: `flutter test test/data/data_sources/gemini_data_source_test.dart`
Expected: PASS

- [x] **Step 5: Domain UseCase의 중복 검증 제거**

`lib/domain/use_cases/reservation_ocr_use_case.dart`의 `execute`를 다음으로 교체 (Data layer에서 이미 검증하므로 중복 로직 제거, DRY):

```dart
  @override
  Future<Either<Exception, ReservationOcrResult>> execute(
    Uint8List imageBytes, {
    Map<String, List<String>>? storeSpaceMap,
  }) async {
    return _repository.analyzeReservationImage(
      imageBytes,
      storeSpaceMap: storeSpaceMap,
    );
  }
```

이제 `ocr_exceptions.dart` import만 남기고 사용하지 않는 import(`OcrParsingException` 직접 참조가 없다면)가 있는지 확인 후 정리한다. 파일 상단의 `import 'package:studio_chance/common/exceptions/ocr_exceptions.dart';`는 더 이상 필요 없으면 제거한다.

- [x] **Step 6: 정적 분석으로 미사용 import 확인**

Run: `dart analyze lib/domain/use_cases/reservation_ocr_use_case.dart`
Expected: `unused_import` 경고 없음 (있다면 해당 import 제거)

- [x] **Step 7: 커밋**

```bash
git add lib/data/data_sources/gemini_data_source.dart lib/domain/use_cases/reservation_ocr_use_case.dart test/data/data_sources/gemini_data_source_test.dart
git commit -m "fix: #14 - [I-1] Gemini OCR 응답 필수 필드 null 검증을 Data Layer로 이동"
```

---

## Task 6: [I-7] ReservationRepositoryImpl.watchReservationsByDateRange — currentUser 캐싱

**Files:**
- Modify: `lib/data/repositories/reservation_repository_impl.dart:136-178`
- Test: `test/data/repositories/reservation_repository_test.dart` (신규 그룹 추가)

**Interfaces:**
- 외부 시그니처 불변

- [x] **Step 1: 실패하는 테스트 작성**

`test/data/repositories/reservation_repository_test.dart` 맨 끝(`updateReservationStatus` 그룹 뒤, 마지막 `}` 앞)에 새 그룹 추가:

```dart
  // =========================================================================
  // watchReservationsByDateRange
  // =========================================================================

  group('watchReservationsByDateRange', () {
    test('currentUser는 스트림 구독 중 최초 1회만 조회된다', () async {
      when(
        () =>
            mockReservationDs.watchReservationsByDateRange(any(), any(), any()),
      ).thenAnswer(
        (_) => Stream.fromIterable([
          [fakeReservationModel],
          [fakeReservationModel],
        ]),
      );
      when(
        () => mockUserDs.getUser('user-123'),
      ).thenAnswer((_) async => fakeUserModel);

      final results = await repository
          .watchReservationsByDateRange(
            storeId: 'store-123',
            currentUid: 'user-123',
            start: DateTime(2026, 5, 1),
            end: DateTime(2026, 5, 31),
          )
          .toList();

      expect(results.length, 2);
      verify(() => mockUserDs.getUser('user-123')).called(1);
    });
  });
```

- [x] **Step 2: 테스트 실행하여 실패 확인**

Run: `flutter test test/data/repositories/reservation_repository_test.dart --plain-name "currentUser는 스트림 구독 중"`
Expected: FAIL — 현재 구현은 스냅샷마다 `getUser`를 호출하므로 2번 호출됨 (`called(1)` 불일치)

- [x] **Step 3: `watchReservationsByDateRange`에 캐싱 추가**

`lib/data/repositories/reservation_repository_impl.dart`의 `watchReservationsByDateRange`(136-178줄)를 수정:

```dart
  @override
  Stream<List<Reservation>> watchReservationsByDateRange({
    required String storeId,
    required String currentUid,
    required DateTime start,
    required DateTime end,
  }) {
    // currentUser는 구독 도중 거의 변경되지 않으므로 스트림 최초 이벤트에서만 조회하고 캐싱한다.
    UserModel? cachedCurrentUserModel;

    return _reservationDataSource
        .watchReservationsByDateRange(storeId, start, end)
        .asyncMap((models) async {
          if (models.isEmpty) return <Reservation>[];

          cachedCurrentUserModel ??= await _userDataSource.getUser(currentUid);
          final storeSummary = _buildStoreSummary(
            storeId: storeId,
            currentUserModel: cachedCurrentUserModel,
          );

          final writerIds = models.map((m) => m.writerId).toSet().toList();
          final writerModels = await Future.wait(
            writerIds.map((uid) => _userDataSource.getUser(uid)),
          );
          final writerById = {
            for (var i = 0; i < writerIds.length; i++)
              if (writerModels[i] != null) writerIds[i]: writerModels[i]!,
          };

          return models.map((model) {
            final writerModel = writerById[model.writerId];
            if (writerModel == null) {
              throw ReservationNotFoundException(
                message: '작성자 정보를 찾을 수 없습니다. writerId: ${model.writerId}',
              );
            }
            return model.toEntity(
              storeSummary,
              _buildWriter(
                writerUserModel: writerModel,
                writerRole: model.writerRole,
              ),
            );
          }).toList();
        });
  }
```

(작성자 없음 방어 처리는 Task 7에서 별도로 다룬다 — 이 단계에서는 캐싱만 적용한다.)

- [x] **Step 4: 테스트 실행하여 통과 확인**

Run: `flutter test test/data/repositories/reservation_repository_test.dart --plain-name "currentUser는 스트림 구독 중"`
Expected: PASS

- [x] **Step 5: 커밋**

```bash
git add lib/data/repositories/reservation_repository_impl.dart test/data/repositories/reservation_repository_test.dart
git commit -m "fix: #14 - [I-7] watchReservationsByDateRange currentUser N+1 조회 캐싱 처리"
```

---

## Task 7: [I-3] ReservationRepositoryImpl.watchReservationsByDateRange — 작성자 없음 방어 처리

**Files:**
- Modify: `lib/data/repositories/reservation_repository_impl.dart` (Task 6에서 수정한 동일 메서드)
- Test: `test/data/repositories/reservation_repository_test.dart` (Task 6에서 추가한 그룹 확장)

**Interfaces:**
- Consumes: Task 6에서 만든 캐싱 로직을 그대로 사용
- 외부 시그니처 불변 (스트림은 예외로 종료되지 않고 해당 건만 건너뜀)

- [x] **Step 1: 실패하는 테스트 작성**

`watchReservationsByDateRange` 그룹에 테스트 추가:

```dart
    test('작성자 정보를 찾을 수 없는 예약은 건너뛰고 나머지는 반환한다', () async {
      final missingWriterModel = fakeReservationModel.copyWith(
        id: 'res-missing-writer',
        writerId: 'ghost-uid',
      );
      when(
        () =>
            mockReservationDs.watchReservationsByDateRange(any(), any(), any()),
      ).thenAnswer(
        (_) => Stream.value([fakeReservationModel, missingWriterModel]),
      );
      when(
        () => mockUserDs.getUser('user-123'),
      ).thenAnswer((_) async => fakeUserModel);
      when(
        () => mockUserDs.getUser('ghost-uid'),
      ).thenAnswer((_) async => null);

      final result = await repository
          .watchReservationsByDateRange(
            storeId: 'store-123',
            currentUid: 'user-123',
            start: DateTime(2026, 5, 1),
            end: DateTime(2026, 5, 31),
          )
          .first;

      expect(result.length, 1);
      expect(result.first.id, 'res-001');
    });
```

- [x] **Step 2: 테스트 실행하여 실패 확인**

Run: `flutter test test/data/repositories/reservation_repository_test.dart --plain-name "작성자 정보를 찾을 수 없는 예약은"`
Expected: FAIL — 현재 구현은 `ReservationNotFoundException`을 던져 스트림 전체가 에러로 종료됨

- [x] **Step 3: 작성자 없음 방어 처리 적용**

`lib/data/repositories/reservation_repository_impl.dart`의 `watchReservationsByDateRange` 안, `models.map((model) { ... }).toList();` 부분을 교체:

```dart
          return models
              .map((model) {
                final writerModel = writerById[model.writerId];
                if (writerModel == null) {
                  _logger.w(
                    '작성자 정보를 찾을 수 없어 예약을 건너뜁니다.'
                    '\nreservationId: ${model.id}, writerId: ${model.writerId}',
                  );
                  return null;
                }
                return model.toEntity(
                  storeSummary,
                  _buildWriter(
                    writerUserModel: writerModel,
                    writerRole: model.writerRole,
                  ),
                );
              })
              .whereType<Reservation>()
              .toList();
```

`ReservationNotFoundException` import가 이 메서드에서만 쓰였다면(`_buildReservationEntity`에서도 사용 중이므로 실제로는 계속 필요) — import는 그대로 유지한다.

- [x] **Step 4: 테스트 실행하여 통과 확인**

Run: `flutter test test/data/repositories/reservation_repository_test.dart`
Expected: PASS (신규 테스트 포함 전체)

- [x] **Step 5: 커밋**

```bash
git add lib/data/repositories/reservation_repository_impl.dart test/data/repositories/reservation_repository_test.dart
git commit -m "fix: #14 - [I-3] 단일 예약 작성자 없음이 전체 스트림을 종료시키지 않도록 방어 처리"
```

---

## Task 8: [I-2] ReservationDataSource — Stream handleError에 StackTrace 포함

**Files:**
- Modify: `lib/data/data_sources/reservation_data_source.dart:158-175`
- Test: `test/data/data_sources/reservation_data_source_test.dart` (기존 `watchReservationsByDateRange` 그룹 확장)

**Interfaces:**
- 외부 시그니처 불변

- [x] **Step 1: 실패하는(컴파일 통과하되 의도 검증용) 테스트 작성**

`fake_cloud_firestore`는 쿼리 단계에서 `FirebaseException`을 인위적으로 던지지 못하므로, 문서 파싱 단계에서 `TypeError`가 발생하도록 유도해 `handleError` 경로를 실제로 통과시킨다.

`test/data/data_sources/reservation_data_source_test.dart` 상단 import 목록에 추가:

```dart
import 'package:studio_chance/common/exceptions/reservation_exceptions.dart';
```

그리고 `watchReservationsByDateRange` 그룹(217-247줄)에 테스트 추가:

```dart
    test('파싱 실패 시 도메인 예외로 변환되어 스트림 에러로 방출된다', () async {
      // customerName 등 필수 필드가 없는 손상된 문서를 직접 주입하여
      // ReservationModel.fromJson이 TypeError를 던지도록 유도한다.
      await fakeFirestore
          .collection('stores')
          .doc(storeId)
          .collection('reservations')
          .doc('broken-doc')
          .set({
        'startTime': Timestamp.fromDate(DateTime(2026, 6, 15)),
      });

      final stream = dataSource.watchReservationsByDateRange(
        storeId,
        DateTime(2026, 6, 1),
        DateTime(2026, 7, 1),
      );

      await expectLater(
        stream,
        emitsError(isA<ReservationDataParsingException>()),
      );
    });
```

- [x] **Step 2: 테스트 실행하여 통과함을 확인 (기존 동작 고정용 베이스라인)**

Run: `flutter test test/data/data_sources/reservation_data_source_test.dart --plain-name "파싱 실패 시 도메인 예외로"`
Expected: PASS (현재 1-인자 `handleError`로도 이미 도메인 예외 변환은 동작함 — 이 테스트는 시그니처 변경 후에도 동일하게 통과해야 함을 보장하는 회귀 테스트)

- [x] **Step 3: `handleError` 시그니처에 StackTrace 포함**

`lib/data/data_sources/reservation_data_source.dart`의 `watchReservationsByDateRange`(158-175줄) 중 마지막 줄을 교체:

```dart
        .handleError((Object e, StackTrace stackTrace) {
          throw handleFirestoreError(e);
        });
```

- [x] **Step 4: 테스트 재실행하여 통과 확인**

Run: `flutter test test/data/data_sources/reservation_data_source_test.dart`
Expected: PASS (전체 `watchReservationsByDateRange` 그룹)

- [x] **Step 5: 커밋**

```bash
git add lib/data/data_sources/reservation_data_source.dart test/data/data_sources/reservation_data_source_test.dart
git commit -m "fix: #14 - [I-2] watchReservationsByDateRange handleError에 StackTrace 포함"
```

---

## Task 9: [I-4] StoreDataSource.approveMember — User 문서 role 동기화

**Files:**
- Modify: `lib/data/data_sources/store_data_source.dart:53-58, 260-275`
- Test: `test/data/data_sources/store_data_source_test.dart:384-411` (기존 그룹 확장)
- Test: `test/data/repositories/store_repository_integration_test.dart:402-440` (기존 테스트 확장)

**Interfaces:**
- 외부 시그니처 불변 (`approveMember(String storeId, String uid, StoreMemberInfoModel memberInfo)`)

- [x] **Step 1: 실패하는 DataSource 테스트 작성**

`test/data/data_sources/store_data_source_test.dart`의 `approveMember` 그룹(384-411줄)에 테스트 추가:

```dart
    test('승인 후 users 컬렉션의 storeById.{storeId}.role도 동기화된다', () async {
      final storeId = FirestoreEmulatorHelper.generateId();
      final uid = FirestoreEmulatorHelper.generateId();
      await _seedStoreWithWaitingMember(fakeFirestore, storeId, uid);
      await fakeFirestore.collection('users').doc(uid).set(<String, dynamic>{
        'email': 'test@example.com',
        'name': '테스트 유저',
        'authProviders': <String>[],
        'storeById': <String, dynamic>{
          storeId: <String, dynamic>{
            'name': '테스트 점포',
            'role': 'VIEWER',
            'color': 'RED',
            'memo': '',
          },
        },
      });
      final memberInfo = StoreMemberInfoModel(role: UserRole.staff);

      await dataSource.approveMember(storeId, uid, memberInfo);

      final userDoc = await fakeFirestore.collection('users').doc(uid).get();
      final storeById = userDoc.data()?['storeById'] as Map<String, dynamic>?;
      expect(storeById?[storeId]['role'], 'STAFF');
    });
```

- [x] **Step 2: 테스트 실행하여 실패 확인**

Run: `flutter test test/data/data_sources/store_data_source_test.dart --plain-name "users 컬렉션의 storeById.{storeId}.role도 동기화"`
Expected: FAIL — user 문서의 role이 `'VIEWER'`로 그대로 남아있음

- [x] **Step 3: 인터페이스 문서와 구현 수정**

`lib/data/data_sources/store_data_source.dart`의 인터페이스 주석(53-58줄) 수정:

```dart
  /// 가입 승인 (waitingMemberById → memberById 이동)
  /// - 승인된 역할을 users/{uid}.storeById.{storeId}.role에도 동기화한다.
  Future<void> approveMember(
    String storeId,
    String uid,
    StoreMemberInfoModel memberInfo,
  );
```

구현(260-275줄)을 교체:

```dart
  @override
  Future<void> approveMember(
    String storeId,
    String uid,
    StoreMemberInfoModel memberInfo,
  ) async {
    try {
      final batch = _firestore.batch();
      final roleJson = memberInfo.toJson()['role'];

      batch.update(_storeDocRef(storeId), {
        'waitingMemberById.$uid': FieldValue.delete(),
        'memberById.$uid': memberInfo.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      batch.update(_firestore.collection('users').doc(uid), {
        'storeById.$storeId.role': roleJson,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }
```

- [x] **Step 4: DataSource 테스트 실행하여 통과 확인**

Run: `flutter test test/data/data_sources/store_data_source_test.dart`
Expected: PASS (approveMember 그룹 전체)

- [x] **Step 5: 통합 테스트에 role 동기화 검증 추가**

`test/data/repositories/store_repository_integration_test.dart`의 `approveMember 후 getStore memberInfos에 승인된 멤버가 포함된다` 테스트(402-440줄) 끝에 검증 추가:

```dart
      final fetched = await repository.getStore(storeId);
      final store = fetched.getRight().toNullable()!;
      final memberIds = store.memberInfos.map((m) => m.user.id).toList();
      expect(memberIds.contains(memberUid), isTrue);

      final memberUserDoc =
          await fakeFirestore.collection('users').doc(memberUid).get();
      final memberStoreById =
          memberUserDoc.data()?['storeById'] as Map<String, dynamic>?;
      expect(memberStoreById?[storeId]['role'], 'STAFF');
    });
```

(기존 `});`를 위 코드로 대체하여 마지막에 검증 두 줄을 추가한다.)

- [x] **Step 6: 통합 테스트 실행하여 통과 확인**

Run: `flutter test test/data/repositories/store_repository_integration_test.dart`
Expected: PASS

- [x] **Step 7: 커밋**

```bash
git add lib/data/data_sources/store_data_source.dart test/data/data_sources/store_data_source_test.dart test/data/repositories/store_repository_integration_test.dart
git commit -m "fix: #14 - [I-4] approveMember 시 User 문서 role 동기화"
```

---

## Task 10: [I-5] softDeleteStore — 멤버 User 문서 정리

**Files:**
- Modify: `lib/data/data_sources/store_data_source.dart:36-37, 277-292`
- Modify: `lib/data/repositories/store_repository_impl.dart:139-149`
- Test: `test/data/data_sources/store_data_source_test.dart:280-302` (기존 그룹 수정 + 확장)
- Test: `test/data/repositories/store_repository_integration_test.dart:240-266` (기존 그룹 확장)

**Interfaces:**
- `StoreDataSource.softDeleteStore` 시그니처 변경: `Future<void> softDeleteStore(String storeId)` → `Future<void> softDeleteStore(String storeId, List<String> memberUids)` (`updateStore`의 `memberUids` 파라미터와 동일한 스타일)
- Repository의 `softDeleteStore(String storeId)` 공개 시그니처는 **불변**

- [x] **Step 1: DataSource 레벨 실패하는 테스트 작성**

`test/data/data_sources/store_data_source_test.dart`의 `softDeleteStore` 그룹(280-302줄)을 교체:

```dart
  group('softDeleteStore', () {
    test('softDelete 후 getStore가 null을 반환한다', () async {
      final uid = FirestoreEmulatorHelper.generateId();
      await _seedUserDoc(fakeFirestore, uid);
      final created = await dataSource.createStore(_testStore(), uid, _creatorInfo);

      await dataSource.softDeleteStore(created.id, []);

      final result = await dataSource.getStore(created.id);
      expect(result, isNull);
    });

    test('softDelete 후 문서에 deletedAt 필드가 존재한다', () async {
      final uid = FirestoreEmulatorHelper.generateId();
      await _seedUserDoc(fakeFirestore, uid);
      final created = await dataSource.createStore(_testStore(), uid, _creatorInfo);

      await dataSource.softDeleteStore(created.id, []);

      final doc = await fakeFirestore.collection('stores').doc(created.id).get();
      expect(doc.data()?.containsKey('deletedAt'), true);
    });

    test('전달된 memberUids의 storeById.{storeId} 캐시가 모두 삭제된다', () async {
      final storeId = FirestoreEmulatorHelper.generateId();
      final memberUid = FirestoreEmulatorHelper.generateId();
      final waitingUid = FirestoreEmulatorHelper.generateId();
      for (final uid in [memberUid, waitingUid]) {
        await fakeFirestore.collection('users').doc(uid).set(<String, dynamic>{
          'email': 'test@example.com',
          'name': '테스트 유저',
          'authProviders': <String>[],
          'storeById': <String, dynamic>{
            storeId: <String, dynamic>{
              'name': '테스트 점포',
              'role': 'STAFF',
              'color': 'RED',
              'memo': '',
            },
          },
        });
      }
      await fakeFirestore.collection('stores').doc(storeId).set(<String, dynamic>{
        'name': '테스트 점포',
        'address': '서울',
        'addressDetail': '',
        'addressGuide': '',
        'memberById': <String, dynamic>{},
        'waitingMemberById': <String, dynamic>{},
        'spaceOptions': <dynamic>[],
      });

      await dataSource.softDeleteStore(storeId, [memberUid, waitingUid]);

      for (final uid in [memberUid, waitingUid]) {
        final doc = await fakeFirestore.collection('users').doc(uid).get();
        final storeById = doc.data()?['storeById'] as Map<String, dynamic>?;
        expect(storeById?.containsKey(storeId), isFalse);
      }
    });
  });
```

- [x] **Step 2: 테스트 실행하여 실패 확인**

Run: `flutter test test/data/data_sources/store_data_source_test.dart --plain-name "softDeleteStore"`
Expected: FAIL — 시그니처 불일치로 컴파일 에러 (`softDeleteStore(created.id, [])`가 기존 1-인자 메서드와 맞지 않음)

- [x] **Step 3: 인터페이스와 구현 수정**

`lib/data/data_sources/store_data_source.dart`의 인터페이스(36-37줄) 수정:

```dart
  /// 점포 삭제 (Soft Delete)
  /// - [memberUids]: 삭제 시점의 멤버+대기 멤버 uid 목록. 각 사용자의
  ///   `storeById.{storeId}` 캐시를 함께 제거하여 데이터 불일치를 방지한다.
  Future<void> softDeleteStore(String storeId, List<String> memberUids);
```

구현(277-292줄)을 교체:

```dart
  @override
  Future<void> softDeleteStore(String storeId, List<String> memberUids) async {
    try {
      final batch = _firestore.batch();
      final hardDeleteDate = DateTime.now().add(
        const Duration(days: storeSoftDeleteDays),
      );

      batch.update(_storeDocRef(storeId), {
        'deletedAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(hardDeleteDate),
        'updatedAt': FieldValue.serverTimestamp(),
        'inviteInfo': null,
      });

      for (final uid in memberUids) {
        batch.update(_firestore.collection('users').doc(uid), {
          'storeById.$storeId': FieldValue.delete(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }
```

- [x] **Step 4: DataSource 테스트 실행하여 통과 확인**

Run: `flutter test test/data/data_sources/store_data_source_test.dart`
Expected: PASS

- [x] **Step 5: Repository의 `softDeleteStore`가 memberUids를 조회해 전달하도록 수정**

`lib/data/repositories/store_repository_impl.dart`의 `softDeleteStore`(139-149줄)를 교체:

```dart
  @override
  Future<Either<Exception, void>> softDeleteStore(String storeId) async {
    try {
      final storeModel = await _storeDataSource.getStore(storeId);
      if (storeModel == null) return right(null);

      final memberUids = {
        ...storeModel.memberById.keys,
        ...storeModel.waitingMemberById.keys,
      }.toList();

      await _storeDataSource.softDeleteStore(storeId, memberUids);
      _logger.i('점포 삭제 완료\nid: $storeId');
      return right(null);
    } catch (e) {
      _logger.e('점포 삭제 실패');
      return left(toException(e));
    }
  }
```

- [x] **Step 6: 통합 테스트에 멤버 정리 검증 추가**

`test/data/repositories/store_repository_integration_test.dart`의 `softDeleteStore` 그룹(240-266줄)에 테스트 추가:

```dart
    test('softDeleteStore 후 멤버(staff)의 storeById 캐시도 제거된다', () async {
      final ownerUid = FirestoreEmulatorHelper.generateId();
      final staffUid = FirestoreEmulatorHelper.generateId();
      await _seedUserDoc(fakeFirestore, ownerUid);
      await _seedUserDoc(fakeFirestore, staffUid);
      final adminUser = User(
        id: ownerUid,
        name: '테스트 유저',
        email: 'test@example.com',
        nickname: null,
        authProviders: [],
        storeInfos: [],
      );
      final created = await repository.createStore(
        store: _testStoreEntity(ownerUid, adminUser),
        color: StoreColor.blue,
        memo: '',
      );
      final storeId = created.getRight().toNullable()!.id;

      await repository.requestJoinStore(
        storeId: storeId,
        uid: staffUid,
        role: UserRole.staff,
        color: StoreColor.red,
        storeAlias: '통합 테스트 점포',
        memo: '',
      );
      await repository.approveMember(
        storeId: storeId,
        uid: staffUid,
        role: UserRole.staff,
      );

      await repository.softDeleteStore(storeId);

      final ownerDoc = await fakeFirestore.collection('users').doc(ownerUid).get();
      final staffDoc = await fakeFirestore.collection('users').doc(staffUid).get();
      final ownerStoreById = ownerDoc.data()?['storeById'] as Map<String, dynamic>?;
      final staffStoreById = staffDoc.data()?['storeById'] as Map<String, dynamic>?;
      expect(ownerStoreById?.containsKey(storeId), isFalse);
      expect(staffStoreById?.containsKey(storeId), isFalse);
    });
```

- [x] **Step 7: 통합 테스트 실행하여 통과 확인**

Run: `flutter test test/data/repositories/store_repository_integration_test.dart`
Expected: PASS

- [x] **Step 8: 커밋**

```bash
git add lib/data/data_sources/store_data_source.dart lib/data/repositories/store_repository_impl.dart test/data/data_sources/store_data_source_test.dart test/data/repositories/store_repository_integration_test.dart
git commit -m "fix: #14 - [I-5] softDeleteStore 시 멤버 User 문서의 storeById 캐시 정리"
```

---

## Task 11: [I-6] 초대 코드 만료 검증 — 서버 시각 사용

**Files:**
- Modify: `firestore.rules`
- Modify: `lib/data/data_sources/store_data_source.dart:60-68, 333-352`(끝부분에 메서드 추가)
- Modify: `lib/data/repositories/store_repository_impl.dart:151-176, 178-212`
- Test: `test/data/data_sources/store_data_source_test.dart` (신규 그룹)
- Test: `test/data/repositories/store_repository_invite_test.dart` (신규 파일)

**Interfaces:**
- Produces: `StoreDataSource.getServerTime()` → `Future<DateTime>`

- [x] **Step 1: firestore.rules에 서버 시각 조회용 scratch 문서 규칙 추가**

`firestore.rules`의 `stores` 컬렉션 블록(37-77줄) 뒤, 최종 닫는 중괄호 앞에 추가:

```
    // ─── system 컬렉션 (서버 시각 동기화 전용) ──────────────────────────────
    // 경로: system/serverTime
    //
    // 클라이언트 기기 시각은 조작되거나 부정확할 수 있어 초대 코드 만료 검증 등에
    // 그대로 신뢰할 수 없다. FieldValue.serverTimestamp()를 기록한 뒤 즉시
    // 서버에서 재조회하는 왕복 조회(round-trip)로 신뢰 가능한 "현재 시각"을 얻기
    // 위한 스크래치 문서이며, 민감 데이터를 저장하지 않으므로 인증된 사용자에게
    // 전체 허용한다.
    match /system/serverTime {
      allow read, write: if request.auth != null;
    }
```

(이 규칙은 `fake_cloud_firestore`가 Security Rules를 적용하지 않으므로 단위 테스트로는 검증되지 않는다 — 실제 배포 시 `firebase deploy --only firestore:rules`로 반영해야 한다.)

- [x] **Step 2: DataSource 레벨 실패하는 테스트 작성**

`test/data/data_sources/store_data_source_test.dart` 끝(마지막 `});` 앞)에 새 그룹 추가:

```dart
  // =========================================================================
  // getServerTime
  // =========================================================================

  group('getServerTime', () {
    test('현재 시각과 근접한 DateTime을 반환한다', () async {
      final before = DateTime.now();

      final serverTime = await dataSource.getServerTime();

      final after = DateTime.now();
      expect(serverTime.isAfter(before.subtract(const Duration(seconds: 5))), true);
      expect(serverTime.isBefore(after.add(const Duration(seconds: 5))), true);
    });
  });
```

- [x] **Step 3: 테스트 실행하여 실패 확인**

Run: `flutter test test/data/data_sources/store_data_source_test.dart --plain-name "getServerTime"`
Expected: FAIL — `getServerTime` 메서드가 존재하지 않아 컴파일 에러

- [x] **Step 4: `StoreDataSource`에 `getServerTime` 추가**

인터페이스(60-68줄 부근, `getStoreByInviteCode` 선언 뒤)에 추가:

```dart
  /// 클라이언트 기기 시각을 신뢰할 수 없는 시각 비교 로직(초대 코드 만료 등)에서
  /// 사용할 Firestore 서버 시각을 조회한다.
  Future<DateTime> getServerTime();
```

구현 클래스 끝(`_generateRandomCode` 헬퍼 위 또는 `getStoreByInviteCode` 구현 뒤)에 추가:

```dart
  @override
  Future<DateTime> getServerTime() async {
    try {
      final ref = _firestore.collection('system').doc('serverTime');
      await ref.set({'probe': FieldValue.serverTimestamp()});
      final snapshot = await ref.get(const GetOptions(source: Source.server));
      final probe = snapshot.data()?['probe'] as Timestamp?;
      // 클라이언트 시각으로 조용히 폴백하면 이 메서드가 막으려는 취약점이 재발하므로,
      // probe가 없으면 예외를 던져 handleFirestoreError로 흡수시킨다 (침묵 폴백 금지).
      if (probe == null) {
        throw StateError('서버 시각 조회 실패: probe 필드가 비어 있습니다.');
      }
      return probe.toDate();
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }
```

- [x] **Step 5: DataSource 테스트 실행하여 통과 확인**

Run: `flutter test test/data/data_sources/store_data_source_test.dart`
Expected: PASS

- [x] **Step 6: Repository 레벨 실패하는 테스트 작성 (mocktail)**

```dart
// test/data/repositories/store_repository_invite_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/data/data_sources/store_data_source.dart';
import 'package:studio_chance/data/data_sources/user_data_source.dart';
import 'package:studio_chance/data/models/invite_info_model.dart';
import 'package:studio_chance/data/models/store_model.dart';
import 'package:studio_chance/data/repositories/store_repository_impl.dart';

import '../../helpers/fake_data.dart';

class MockStoreDataSource extends Mock implements StoreDataSource {}

class MockUserDataSource extends Mock implements UserDataSource {}

void main() {
  late StoreRepositoryImpl repository;
  late MockStoreDataSource mockStoreDs;
  late MockUserDataSource mockUserDs;

  setUp(() {
    mockStoreDs = MockStoreDataSource();
    mockUserDs = MockUserDataSource();
    repository = StoreRepositoryImpl(
      storeDataSource: mockStoreDs,
      userDataSource: mockUserDs,
    );
  });

  group('getStoreByInviteCode 만료 검증', () {
    test('서버 시각 기준으로 만료 시간이 지나면 left(StoreValidationException)을 반환한다', () async {
      final createdAt = DateTime(2026, 1, 1, 0, 0);
      final storeModel = fakeStoreModel.copyWith(
        inviteInfoModel: InviteInfoModel(
          inviteCode: 'ABC123',
          createdAt: createdAt,
        ),
      );
      when(
        () => mockStoreDs.getStoreByInviteCode(any()),
      ).thenAnswer((_) async => storeModel);
      // 기기 시각(DateTime.now())은 미래로 조작되었더라도, 서버 시각이
      // 만료 시각(createdAt + 15분) 이전이면 유효해야 한다.
      when(
        () => mockStoreDs.getServerTime(),
      ).thenAnswer((_) async => createdAt.add(const Duration(minutes: 10)));

      final result = await repository.getStoreByInviteCode('ABC123');

      expect(result.isRight(), true);
    });

    test('서버 시각이 만료 시간을 지났으면 left(StoreValidationException)을 반환한다', () async {
      final createdAt = DateTime(2026, 1, 1, 0, 0);
      final storeModel = fakeStoreModel.copyWith(
        inviteInfoModel: InviteInfoModel(
          inviteCode: 'ABC123',
          createdAt: createdAt,
        ),
      );
      when(
        () => mockStoreDs.getStoreByInviteCode(any()),
      ).thenAnswer((_) async => storeModel);
      when(
        () => mockStoreDs.getServerTime(),
      ).thenAnswer((_) async => createdAt.add(const Duration(minutes: 20)));

      final result = await repository.getStoreByInviteCode('ABC123');

      expect(result.isLeft(), true);
    });
  });
}
```

- [x] **Step 7: 테스트 실행하여 실패 확인**

Run: `flutter test test/data/repositories/store_repository_invite_test.dart`
Expected: FAIL — `mockStoreDs.getServerTime()`이 정의되지 않아 컴파일 에러, 그리고 현재 구현은 `DateTime.now()`를 사용하므로 `getServerTime` 스텁이 호출되지 않음

- [x] **Step 8: `StoreRepositoryImpl`에서 서버 시각 사용**

`lib/data/repositories/store_repository_impl.dart`의 `createInviteCode`(151-176줄) 중 클라이언트 시각 비교 부분을 교체:

```dart
      if (!forceRegenerate) {
        final existing = await _storeDataSource.getInviteInfo(storeId);
        if (existing != null && existing.createdAt != null) {
          final expiresAt = existing.createdAt!
              .add(const Duration(minutes: storeInviteCodeAvailableMin));
          final serverNow = await _storeDataSource.getServerTime();
          if (serverNow.isBefore(expiresAt)) {
            _logger.i('유효한 초대 코드 재사용\nstoreId: $storeId');
            return right(existing.toEntity());
          }
        }
      }
```

`getStoreByInviteCode`(178-212줄) 중 만료 검증 부분을 교체:

```dart
      final expiresAt = inviteData.createdAt!
          .add(const Duration(minutes: storeInviteCodeAvailableMin));
      final serverNow = await _storeDataSource.getServerTime();
      if (serverNow.isAfter(expiresAt)) {
        return left(StoreValidationException(message: '만료된 초대 코드입니다.'));
      }
```

- [x] **Step 9: mocktail 테스트 실행하여 통과 확인**

Run: `flutter test test/data/repositories/store_repository_invite_test.dart`
Expected: PASS

- [x] **Step 10: 기존 통합 테스트 회귀 확인**

Run: `flutter test test/data/repositories/store_repository_integration_test.dart --plain-name "createInviteCode"`
Run: `flutter test test/data/repositories/store_repository_integration_test.dart --plain-name "getStoreByInviteCode"`
Expected: PASS (둘 다 15분 이내 시나리오이므로 서버 시각으로 바뀌어도 정상 동작)

- [x] **Step 11: 커밋**

```bash
git add firestore.rules lib/data/data_sources/store_data_source.dart lib/data/repositories/store_repository_impl.dart test/data/data_sources/store_data_source_test.dart test/data/repositories/store_repository_invite_test.dart
git commit -m "fix: #14 - [I-6] 초대 코드 만료 검증에 클라이언트 시각 대신 Firestore 서버 시각 사용"
```

- [x] **Step 12: (수동, 코드 아님) Firestore Rules 배포 안내**

이 태스크의 `firestore.rules` 변경은 로컬 테스트로 검증되지 않으므로, 실제 Firebase 프로젝트에 반영하려면 별도로 `firebase deploy --only firestore:rules`를 실행해야 함을 PR 설명에 명시한다. (이 스텝은 코드 변경이 아니라 배포 안내이므로 커밋 대상 아님.)

---

## Task 12: [M-3] UserDataSource.createUser — fcmTokens 저장

**Files:**
- Modify: `lib/data/data_sources/user_data_source.dart:143-154`
- Test: `test/data/data_sources/user_data_source_test.dart:36-48` (기존 `createUser` 그룹 확장)

**Interfaces:**
- 외부 시그니처 불변

- [x] **Step 1: 실패하는 테스트 작성**

`test/data/data_sources/user_data_source_test.dart`의 `createUser` 그룹(36-48줄)에 테스트 추가:

```dart
    test('fcmTokens가 Firestore 문서에 저장된다', () async {
      final user = _testUser().copyWith(fcmTokens: ['token-abc']);

      await dataSource.createUser(user);

      final doc = await fakeFirestore.collection('users').doc(user.id).get();
      expect(doc.data()?['fcmTokens'], ['token-abc']);
    });
```

- [x] **Step 2: 테스트 실행하여 실패 확인**

Run: `flutter test test/data/data_sources/user_data_source_test.dart --plain-name "fcmTokens가 Firestore 문서에 저장된다"`
Expected: FAIL — `fcmTokens`는 `@JsonKey(includeToJson: false)`라 `toJson()` 결과에 없어 `doc.data()?['fcmTokens']`가 `null`

- [x] **Step 3: `createUser`에서 fcmTokens 명시적 주입**

`lib/data/data_sources/user_data_source.dart`의 `createUser`(143-154줄)를 수정:

```dart
  @override
  Future<void> createUser(UserModel userModel) async {
    try {
      final json = userModel.toJson();
      // fcmTokens는 @JsonKey(includeToJson: false)로 일반 toJson()에서 제외되므로
      // (updateUser 등에서 storeById와 함께 실수로 덮어쓰이지 않도록) 생성 시에만 명시적으로 주입한다.
      json['fcmTokens'] = userModel.fcmTokens;
      json['createdAt'] = FieldValue.serverTimestamp();
      json['updatedAt'] = FieldValue.serverTimestamp();
      json['lastLoginAt'] = FieldValue.serverTimestamp();

      await _userDocRef(userModel.id).set(json);
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }
```

- [x] **Step 4: 테스트 실행하여 통과 확인**

Run: `flutter test test/data/data_sources/user_data_source_test.dart`
Expected: PASS

- [x] **Step 5: 커밋**

```bash
git add lib/data/data_sources/user_data_source.dart test/data/data_sources/user_data_source_test.dart
git commit -m "fix: #14 - [M-3] 신규 유저 생성 시 fcmTokens가 Firestore에 저장되지 않던 문제 수정"
```

---

## Task 13: [M-4] ReservationModel.toUpdateJson() — allowlist 방식으로 변경

**Files:**
- Modify: `lib/data/models/reservation_model.dart:67-74`
- Test: `test/data/models/reservation_model_test.dart` (신규)

**Interfaces:**
- 외부 시그니처 불변 (`Map<String, dynamic> toUpdateJson()`)

- [x] **Step 1: 실패하는 테스트 작성**

```dart
// test/data/models/reservation_model_test.dart
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_data.dart';

void main() {
  group('toUpdateJson', () {
    test('불변 필드(storeId, writerId, writerRole)를 포함하지 않는다', () {
      final json = fakeReservationModel.toUpdateJson();

      expect(json.containsKey('storeId'), false);
      expect(json.containsKey('writerId'), false);
      expect(json.containsKey('writerRole'), false);
    });

    test('수정 가능 필드는 모두 포함한다', () {
      final json = fakeReservationModel.toUpdateJson();

      const editableFields = {
        'status', 'customerName', 'headCount', 'customerPhone', 'memo',
        'isAllDay', 'startTime', 'endTime', 'platform', 'paymentMethod',
        'calculatedPrice', 'priceAdjustment', 'totalPrice', 'spaceOptionId',
      };
      for (final field in editableFields) {
        expect(json.containsKey(field), true, reason: '$field 누락');
      }
    });

    test('id는 포함하지 않는다', () {
      final json = fakeReservationModel.toUpdateJson();
      expect(json.containsKey('id'), false);
    });
  });
}
```

- [x] **Step 2: 테스트 실행하여 통과함을 확인 (현재 구현으로도 통과하는 회귀 방지 베이스라인)**

Run: `flutter test test/data/models/reservation_model_test.dart`
Expected: PASS (현재 블랙리스트 구현도 동일한 최종 결과를 내므로 이 테스트들은 리팩터링 전후 동일하게 통과해야 한다 — allowlist 전환이 순수 리팩터링임을 보장)

- [x] **Step 3: `toUpdateJson()`을 allowlist 방식으로 전환**

`lib/data/models/reservation_model.dart`의 `toUpdateJson()`(67-74줄)을 교체:

```dart
  /// 예약 수정 가능 필드만 반환 (allowlist 방식)
  /// - 새 불변 필드가 추가되어도 여기 명시하지 않는 한 자동으로 제외된다.
  Map<String, dynamic> toUpdateJson() {
    final json = toJson();
    const editableFields = {
      'status', 'customerName', 'headCount', 'customerPhone', 'memo',
      'isAllDay', 'startTime', 'endTime', 'platform', 'paymentMethod',
      'calculatedPrice', 'priceAdjustment', 'totalPrice', 'spaceOptionId',
    };
    return {
      for (final entry in json.entries)
        if (editableFields.contains(entry.key)) entry.key: entry.value,
    };
  }
```

- [x] **Step 4: 테스트 재실행하여 통과 확인**

Run: `flutter test test/data/models/reservation_model_test.dart`
Expected: PASS

- [x] **Step 5: Reservation Repository/DataSource 회귀 테스트 실행**

Run: `flutter test test/data/repositories/reservation_repository_test.dart test/data/data_sources/reservation_data_source_test.dart`
Expected: PASS (updateReservation 관련 테스트 포함 전체)

- [x] **Step 6: 커밋**

```bash
git add lib/data/models/reservation_model.dart test/data/models/reservation_model_test.dart
git commit -m "fix: #14 - [M-4] ReservationModel.toUpdateJson()을 블랙리스트에서 allowlist 방식으로 변경"
```

---

## Task 14: [M-5] StoreModel legacy fallback — Repository 레이어로 이동

**Files:**
- Modify: `lib/data/models/store_model.dart:86-115`
- Modify: `lib/data/repositories/store_repository_impl.dart` (import 추가, `createStore`/`getStore`/`getStoreByInviteCode`에서 사용하는 헬퍼 추가)
- Test: `test/data/models/store_model_test.dart` (신규)
- Test: `test/data/repositories/store_repository_integration_test.dart` (신규 그룹)

**Interfaces:**
- `StoreModel.toEntity()`는 더 이상 legacy fallback을 적용하지 않고 `spaceOptions`를 그대로 변환한다 (빈 리스트면 빈 리스트 반환)
- Produces: `StoreRepositoryImpl._toStoreEntity(StoreModel model, {required memberInfos, required waitingMemberInfos})` — Data Model이 아닌 Repository가 legacy fallback을 책임진다

- [x] **Step 1: `StoreModel.toEntity()` 실패하는 테스트 작성**

```dart
// test/data/models/store_model_test.dart
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_data.dart';

void main() {
  group('StoreModel.toEntity', () {
    test('spaceOptions가 비어있으면 그대로 빈 리스트를 반환한다 (legacy fallback 없음)', () {
      final store = fakeStoreModel.toEntity(
        memberInfos: [],
        waitingMemberInfos: [],
      );

      expect(store.spaceOptions, isEmpty);
    });
  });
}
```

- [x] **Step 2: 테스트 실행하여 실패 확인**

Run: `flutter test test/data/models/store_model_test.dart`
Expected: FAIL — 현재 구현은 `spaceOptions.isEmpty`일 때 `legacy_default` 1건을 채워 반환하므로 `isEmpty` 매처 실패

- [x] **Step 3: `store_model.dart`에서 fallback 로직 제거**

`lib/data/models/store_model.dart`의 `toEntity()`(86-115줄)를 교체:

```dart
  Store toEntity({
    required List<StoreMemberInfo> memberInfos,
    required List<StoreMemberInfo> waitingMemberInfos,
  }) {
    return Store(
      id: id,
      name: name,
      address: address,
      addressDetail: addressDetail,
      addressGuide: addressGuide,
      spaceOptions: spaceOptions.map((s) => s.toEntity()).toList(),
      memberInfos: memberInfos,
      waitingMemberInfos: waitingMemberInfos,
      inviteInfo: inviteInfoModel?.toEntity(),
      bankName: bankName,
      bankAccountNumber: bankAccountNumber,
      bankAccountHolder: bankAccountHolder,
      paymentDeadlineMinutes: paymentDeadlineMinutes,
      infoNotes: infoNotes,
      cautionNotes: cautionNotes,
    );
  }
```

이제 `PriceSetting`, `SpaceOption` import가 이 파일에서 더 이상 필요 없다면(다른 곳에서 안 쓰인다면) 제거한다.

- [x] **Step 4: 모델 테스트 실행하여 통과 확인**

Run: `flutter test test/data/models/store_model_test.dart`
Expected: PASS

- [x] **Step 5: 통합 테스트로 Repository의 회귀(legacy fallback 소실) 확인하는 실패 테스트 작성**

`test/data/repositories/store_repository_integration_test.dart`의 `createStore + getStore` 그룹(59-115줄) 뒤에 새 그룹 추가:

```dart
  // =========================================================================
  // legacy fallback (spaceOptions 없는 구버전 점포)
  // =========================================================================

  group('legacy spaceOptions fallback', () {
    test('spaceOptions가 없는 점포를 조회하면 legacy_default 공간 하나로 채워진다', () async {
      final uid = FirestoreEmulatorHelper.generateId();
      await _seedUserDoc(fakeFirestore, uid);
      // spaceOptions 필드 자체가 없던 구버전 문서를 직접 시뮬레이션
      final storeId = FirestoreEmulatorHelper.generateId();
      await fakeFirestore.collection('stores').doc(storeId).set(<String, dynamic>{
        'name': '레거시 점포',
        'address': '서울',
        'addressDetail': '',
        'addressGuide': '',
        'memberById': <String, dynamic>{
          uid: <String, dynamic>{'role': 'ADMIN'},
        },
        'waitingMemberById': <String, dynamic>{},
        'spaceOptions': <dynamic>[],
      });

      final fetched = await repository.getStore(storeId);

      final store = fetched.getRight().toNullable()!;
      expect(store.spaceOptions.length, 1);
      expect(store.spaceOptions.first.id, 'legacy_default');
      expect(store.spaceOptions.first.name, '기본 공간');
    });
  });
```

- [x] **Step 6: 테스트 실행하여 실패 확인**

Run: `flutter test test/data/repositories/store_repository_integration_test.dart --plain-name "spaceOptions가 없는 점포를 조회하면"`
Expected: FAIL — `StoreModel.toEntity()`에서 fallback을 제거했으므로 `store.spaceOptions`가 빈 리스트

- [x] **Step 7: `StoreRepositoryImpl`에 fallback 헬퍼 추가 및 적용**

`lib/data/repositories/store_repository_impl.dart` 상단 import에 추가:

```dart
import 'package:studio_chance/domain/entities/price_setting.dart';
import 'package:studio_chance/domain/entities/space_option.dart';
```

`_fetchMembersWithRoles` 위(Private Helpers 섹션)에 헬퍼 추가:

```dart
  /// StoreModel → Store 변환 + legacy fallback 적용
  /// - spaceOptions가 비어있는 구버전 점포 문서는 기본 공간 1건으로 채워 반환한다.
  ///   (이 판단은 Data Model이 아닌 Repository의 책임이다)
  Store _toStoreEntity(
    StoreModel model, {
    required List<StoreMemberInfo> memberInfos,
    required List<StoreMemberInfo> waitingMemberInfos,
  }) {
    final store = model.toEntity(
      memberInfos: memberInfos,
      waitingMemberInfos: waitingMemberInfos,
    );
    if (store.spaceOptions.isNotEmpty) return store;

    return store.copyWith(
      spaceOptions: [
        SpaceOption(
          id: 'legacy_default',
          name: '기본 공간',
          priceSetting: PriceSetting.empty(),
        ),
      ],
    );
  }
```

세 호출부를 `_toStoreEntity`로 교체:

`createStore`(63-68줄):
```dart
      return right(
        _toStoreEntity(
          createdModel,
          memberInfos: store.memberInfos,
          waitingMemberInfos: store.waitingMemberInfos,
        ),
      );
```

`getStore`(Task 3에서 수정한 부분 중 반환문):
```dart
      return right(
        _toStoreEntity(
          storeModel,
          memberInfos: memberInfos,
          waitingMemberInfos: waitingInfos,
        ),
      );
```

`getStoreByInviteCode`(반환문):
```dart
      return right(
        _toStoreEntity(
          storeModel,
          memberInfos: memberInfos,
          waitingMemberInfos: waitingInfos,
        ),
      );
```

- [x] **Step 8: 통합 테스트 재실행하여 통과 확인**

Run: `flutter test test/data/repositories/store_repository_integration_test.dart`
Expected: PASS (전체 그룹, 신규 테스트 포함)

- [x] **Step 9: 전체 Store 관련 테스트 스위트 실행 (최종 회귀 확인)**

Run: `flutter test test/data/models/store_model_test.dart test/data/data_sources/store_data_source_test.dart test/data/repositories/store_repository_integration_test.dart test/data/repositories/store_repository_update_test.dart test/data/repositories/store_repository_invite_test.dart`
Expected: PASS (전체)

- [x] **Step 10: 커밋**

```bash
git add lib/data/models/store_model.dart lib/data/repositories/store_repository_impl.dart test/data/models/store_model_test.dart test/data/repositories/store_repository_integration_test.dart
git commit -m "fix: #14 - [M-5] spaceOptions legacy fallback 로직을 Data Model에서 Repository로 이동"
```

---

## 최종 검증

모든 태스크 완료 후 전체 스위트와 정적 분석을 한 번 더 돌린다.

- [x] **전체 테스트 실행**

Run: `flutter test`
Expected: PASS (전체)

- [x] **정적 분석**

Run: `dart analyze`
Expected: `No issues found!`

- [x] **이슈 #14 체크리스트 문서화 커밋**

이슈 본문의 체크리스트를 실제 GitHub 이슈에서 하나씩 체크하거나, PR 설명에 14개 항목([C-1]~[M-5]) 완료를 명시한다. (CLAUDE.md의 "superpowers 플랜 체크리스트" 규칙은 별도 로컬 플랜 체크리스트 문서에 적용되는 것이므로, 이 문서 자체의 각 Task 체크박스를 실행 중 순서대로 체크 표시하며 진행한다.)

---

## Self-Review 메모

- **Spec coverage**: 이슈 #14의 Critical 4건(C-1~C-4), Important 7건(I-1~I-7), Minor 3건(M-3~M-5) 총 14건 모두 Task 1~14에 1:1로 대응됨.
- **Placeholder scan**: 모든 스텝에 실행 가능한 실제 코드/명령어 포함, "TODO"/"적절히 처리" 류 표현 없음.
- **Type consistency**: `StoreDataSource.softDeleteStore`, `StoreDataSource.approveMember`, `StoreDataSource.getServerTime` 시그니처가 Task 9~11에서 인터페이스·구현·호출부(Repository)·테스트 전체에서 동일하게 사용됨을 교차 확인함.
- **I-6 한계**: Firestore Rules 변경은 `fake_cloud_firestore`가 Rules를 적용하지 않아 로컬 테스트로 검증 불가 — Task 11 Step 12에 수동 배포 안내를 명시함.
