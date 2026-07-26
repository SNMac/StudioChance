# 공휴일 요금 자동 적용 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 예약 가격 계산 시 공휴일 여부를 실제로 판정하여 `PriceSetting.calculatePrice(isHoliday: ...)`에 실제 값을 전달한다. 현재는 모든 호출부에서 `isHoliday: false`로 고정되어 있어 공휴일 요금 그룹(`Weekday.holiday`)이 절대 적용되지 않는다.

**Architecture:** Clean Architecture 4계층으로 신규 `Holiday` 수직 슬라이스를 추가한다. `HolidayDataSource`(공공데이터포털 HTTP 호출) → `HolidayRepositoryImpl`(월별 캐시) → `HolidayUseCase`(단순 위임) → `isHolidayProvider`(Riverpod). `ReservationUseCaseImpl`은 `HolidayRepository`를 직접 주입받아 가격 계산 시점에 공휴일 여부를 조회한다(기존 `StoreRepository` 주입과 동일한 패턴, D3).

**Tech Stack:** `http: ^1.6.0`(이미 pubspec.yaml에 존재, 추가 설치 불필요), `fpdart` Either, `riverpod_generator`, `mocktail`.

## Global Constraints

- API: 한국천문연구원 특일 정보 API — `GET https://apis.data.go.kr/B090041/openapi/service/SpcdeInfoService/getRestDeInfo` (공공데이터포털, `solYear`/`solMonth`/`serviceKey`/`_type=json` 쿼리 파라미터)
- 발급처: https://www.data.go.kr/data/15012690/openapi.do — 이 플랜을 실행하는 사람이 사전에 서비스 키를 발급받아야 한다 (승인까지 통상 1~2시간 소요, 공공데이터포털 특성)
- API 키는 `.gitignore` 처리된 `lib/constants/api_keys.dart`에만 저장 — 절대 커밋 금지 (CLAUDE.md "중요 사항")
- `Either<Exception, T>` 반환 패턴, 프로덕션 코드에서 `isLeft()/isRight()` 명령형 스타일 금지 — `fold`/`getOrElse` 사용 (테스트 코드는 기존 관례상 `isLeft()/isRight()` 허용)
- 공휴일 조회 실패는 예약 흐름을 막지 않고 `isHoliday: false`로 조용히 폴백한다 (silent — 사용자에게 별도 알림 없음)
- 콘솔 출력은 `logger` 라이브러리 사용
- 커밋 메시지는 한국어. 이슈 번호는 아직 GitHub에 생성되지 않았으므로 각 커밋 예시의 `#XX`는 실제 이슈 번호로 치환할 것 (CLAUDE.md Git 컨벤션: `feat/#<이슈번호>-<설명>` 브랜치, `<type>: #<이슈번호> - <설명>` 커밋)
- `dart run build_runner build --delete-conflicting-outputs`는 `@riverpod`/`@Riverpod` 어노테이션이 추가된 파일을 만들 때마다 실행

---

### 현재 상태 (연구 결과)

| 파일 | 현재 상태 |
|------|-----------|
| `lib/domain/entities/price_setting.dart` | `calculatePrice(isHoliday: bool)` 파라미터 이미 구현 완료 — 공휴일 판정 로직 자체는 손댈 필요 없음 |
| `lib/domain/enums/weekday.dart` | `Weekday.holiday`(`@JsonValue(8)`) 이미 정의됨 |
| `lib/domain/use_cases/reservation_use_case.dart:221` | `isHoliday: false, // TODO: 공휴일 API 연동 후 실제 값 전달` |
| `lib/presentation/.../reservation_create_modal.dart:228` | 동일 TODO |
| `lib/presentation/.../reservation_detail_modal.dart:327,344` | 동일 TODO (2곳: `_recalculatePrice`, `_applyInitialPrice`) |
| `pubspec.yaml` | `http: ^1.6.0` 이미 존재하나 `lib/` 어디서도 아직 사용되지 않음 (이번이 첫 사용처) |
| `lib/constants/api_keys.dart` | 존재하지 않음 — 이번 플랜에서 최초 생성 |

이 프로젝트에 외부 HTTP API를 호출하는 기존 DataSource가 없으므로(기존 `gemini_data_source.dart`는 Firebase AI SDK를 사용, Firestore DataSource는 `FirestoreDataSourceBase` 상속), `http.Client`를 직접 사용하는 패턴을 이번에 새로 도입한다. 테스트 용이성을 위해 `http.Client`를 생성자 주입받는다(mocktail로 목킹).

---

### Task 1: HolidayDataSource — 공공데이터포털 API 클라이언트

**Files:**
- Create: `lib/common/exceptions/holiday_exceptions.dart`
- Create: `lib/constants/api_keys.dart` (gitignore 처리)
- Modify: `.gitignore`
- Create: `lib/data/data_sources/holiday_data_source.dart`
- Test: `test/data/data_sources/holiday_data_source_test.dart`

**Interfaces:**
- Consumes: 없음 (최하위 계층)
- Produces:
  - `class HolidayNetworkException extends HolidayException`, `class HolidayParsingException extends HolidayException`, `class HolidayUnknownException extends HolidayException`
  - `abstract interface class HolidayDataSource { Future<Set<DateTime>> getHolidays({required int year, required int month}); }`
  - `class HolidayDataSourceImpl implements HolidayDataSource` — 생성자 `HolidayDataSourceImpl({http.Client? client})`
  - `@Riverpod(keepAlive: true) HolidayDataSource holidayDataSource(Ref ref)`

- [ ] **Step 1: 예외 계층 작성**

`lib/common/exceptions/holiday_exceptions.dart`:

```dart
import 'package:studio_chance/common/exceptions/app_exception.dart';

/// 공휴일 조회 관련 최상위 예외
sealed class HolidayException extends AppException {
  HolidayException(super.message, {super.code});

  @override
  String get title => switch (this) {
    HolidayNetworkException() => '네트워크 에러가 발생했습니다',
    HolidayParsingException() => '공휴일 정보 조회 실패',
    HolidayUnknownException() => '에러가 발생했습니다',
  };

  @override
  String get content => switch (this) {
    HolidayNetworkException() => '인터넷 연결 상태를 확인해주세요.',
    HolidayParsingException() => '공휴일 정보를 불러오지 못했습니다.',
    HolidayUnknownException() => '일시적인 에러가 발생했습니다.',
  };

  // 공휴일 조회 실패는 평일 요금으로 조용히 폴백 — 사용자에게 알리지 않음
  @override
  bool get isSilentable => true;
}

class HolidayNetworkException extends HolidayException {
  HolidayNetworkException(super.message, {super.code});
}

class HolidayParsingException extends HolidayException {
  HolidayParsingException(super.message, {super.code});
}

class HolidayUnknownException extends HolidayException {
  HolidayUnknownException(super.message, {super.code});
}
```

- [ ] **Step 2: API 키 파일 생성 및 gitignore 처리**

`lib/constants/api_keys.dart` (실제 발급받은 키로 `YOUR_SERVICE_KEY_HERE`를 교체할 것):

```dart
/// 외부 API 키 상수 모음. .gitignore 처리됨 — 절대 커밋하지 말 것.
class ApiKeys {
  ApiKeys._();

  /// 공공데이터포털(data.go.kr) 발급 서비스 키
  /// 발급처: https://www.data.go.kr/data/15012690/openapi.do
  static const String dataGoKrServiceKey = 'YOUR_SERVICE_KEY_HERE';
}
```

`.gitignore`에 추가 (파일 맨 끝에):

```
# API Keys
lib/constants/api_keys.dart
```

- [ ] **Step 3: 실패하는 테스트 작성**

`test/data/data_sources/holiday_data_source_test.dart`:

```dart
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/common/exceptions/holiday_exceptions.dart';
import 'package:studio_chance/data/data_sources/holiday_data_source.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late MockHttpClient mockClient;
  late HolidayDataSourceImpl dataSource;

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  setUp(() {
    mockClient = MockHttpClient();
    dataSource = HolidayDataSourceImpl(client: mockClient);
  });

  group('getHolidays', () {
    test('공휴일이 여러 건이면 item이 List로 응답되어도 파싱한다', () async {
      final body = jsonEncode({
        'response': {
          'header': {'resultCode': '00', 'resultMsg': 'NORMAL_SERVICE'},
          'body': {
            'items': {
              'item': [
                {'locdate': 20260301, 'isHoliday': 'Y', 'dateName': '삼일절'},
                {'locdate': 20260505, 'isHoliday': 'Y', 'dateName': '어린이날'},
              ],
            },
            'totalCount': 2,
          },
        },
      });
      when(() => mockClient.get(any()))
          .thenAnswer((_) async => http.Response(body, 200));

      final result = await dataSource.getHolidays(year: 2026, month: 3);

      expect(result, {DateTime(2026, 3, 1)});
    });

    test('공휴일이 1건이면 item이 단일 Map으로 응답되어도 파싱한다', () async {
      final body = jsonEncode({
        'response': {
          'header': {'resultCode': '00', 'resultMsg': 'NORMAL_SERVICE'},
          'body': {
            'items': {
              'item': {'locdate': 20260815, 'isHoliday': 'Y', 'dateName': '광복절'},
            },
            'totalCount': 1,
          },
        },
      });
      when(() => mockClient.get(any()))
          .thenAnswer((_) async => http.Response(body, 200));

      final result = await dataSource.getHolidays(year: 2026, month: 8);

      expect(result, {DateTime(2026, 8, 15)});
    });

    test('totalCount가 0이면 빈 Set을 반환한다', () async {
      final body = jsonEncode({
        'response': {
          'header': {'resultCode': '00', 'resultMsg': 'NORMAL_SERVICE'},
          'body': {'items': '', 'totalCount': 0},
        },
      });
      when(() => mockClient.get(any()))
          .thenAnswer((_) async => http.Response(body, 200));

      final result = await dataSource.getHolidays(year: 2026, month: 6);

      expect(result, isEmpty);
    });

    test('isHoliday가 N인 항목은 제외한다', () async {
      final body = jsonEncode({
        'response': {
          'header': {'resultCode': '00', 'resultMsg': 'NORMAL_SERVICE'},
          'body': {
            'items': {
              'item': [
                {'locdate': 20260101, 'isHoliday': 'Y', 'dateName': '신정'},
                {'locdate': 20260102, 'isHoliday': 'N', 'dateName': '해당없음'},
              ],
            },
            'totalCount': 2,
          },
        },
      });
      when(() => mockClient.get(any()))
          .thenAnswer((_) async => http.Response(body, 200));

      final result = await dataSource.getHolidays(year: 2026, month: 1);

      expect(result, {DateTime(2026, 1, 1)});
    });

    test('HTTP 상태 코드가 200이 아니면 HolidayNetworkException을 던진다', () async {
      when(() => mockClient.get(any()))
          .thenAnswer((_) async => http.Response('Internal Server Error', 500));

      expect(
        () => dataSource.getHolidays(year: 2026, month: 1),
        throwsA(isA<HolidayNetworkException>()),
      );
    });

    test('resultCode가 00이 아니면 HolidayParsingException을 던진다', () async {
      final body = jsonEncode({
        'response': {
          'header': {
            'resultCode': '30',
            'resultMsg': 'SERVICE_KEY_IS_NOT_REGISTERED_ERROR',
          },
        },
      });
      when(() => mockClient.get(any()))
          .thenAnswer((_) async => http.Response(body, 200));

      expect(
        () => dataSource.getHolidays(year: 2026, month: 1),
        throwsA(isA<HolidayParsingException>()),
      );
    });

    test('JSON 파싱 자체가 실패하면 HolidayParsingException을 던진다', () async {
      when(() => mockClient.get(any()))
          .thenAnswer((_) async => http.Response('not json', 200));

      expect(
        () => dataSource.getHolidays(year: 2026, month: 1),
        throwsA(isA<HolidayParsingException>()),
      );
    });

    test('요청 URI에 solYear/solMonth(2자리)/serviceKey가 포함된다', () async {
      Uri? capturedUri;
      when(() => mockClient.get(any())).thenAnswer((invocation) async {
        capturedUri = invocation.positionalArguments.first as Uri;
        return http.Response(
          jsonEncode({
            'response': {
              'header': {'resultCode': '00', 'resultMsg': 'NORMAL_SERVICE'},
              'body': {'items': '', 'totalCount': 0},
            },
          }),
          200,
        );
      });

      await dataSource.getHolidays(year: 2026, month: 9);

      expect(capturedUri, isNotNull);
      expect(capturedUri!.queryParameters['solYear'], '2026');
      expect(capturedUri!.queryParameters['solMonth'], '09');
      expect(capturedUri!.queryParameters.containsKey('serviceKey'), isTrue);
    });
  });
}
```

- [ ] **Step 4: 테스트 실패 확인**

Run: `flutter test test/data/data_sources/holiday_data_source_test.dart`
Expected: FAIL — `Error: Type 'HolidayDataSourceImpl' not found` (아직 프로덕션 파일이 없음)

- [ ] **Step 5: HolidayDataSource 구현**

`lib/data/data_sources/holiday_data_source.dart`:

```dart
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studio_chance/common/exceptions/holiday_exceptions.dart';
import 'package:studio_chance/constants/api_keys.dart';

part 'holiday_data_source.g.dart';

abstract interface class HolidayDataSource {
  /// [year]년 [month]월의 공휴일 날짜 목록을 조회한다.
  Future<Set<DateTime>> getHolidays({required int year, required int month});
}

class HolidayDataSourceImpl implements HolidayDataSource {
  static const _baseUrl =
      'https://apis.data.go.kr/B090041/openapi/service/SpcdeInfoService/getRestDeInfo';

  final http.Client _client;

  HolidayDataSourceImpl({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<Set<DateTime>> getHolidays({
    required int year,
    required int month,
  }) async {
    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'serviceKey': ApiKeys.dataGoKrServiceKey,
        'solYear': year.toString(),
        'solMonth': month.toString().padLeft(2, '0'),
        'numOfRows': '20',
        '_type': 'json',
      },
    );

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw HolidayNetworkException(
        '공휴일 API 응답 오류: ${response.statusCode}',
        code: response.statusCode.toString(),
      );
    }

    final Map<String, dynamic> json;
    try {
      json = jsonDecode(response.body) as Map<String, dynamic>;
    } on FormatException catch (e) {
      throw HolidayParsingException(e.toString());
    }

    final responseBody = json['response'] as Map<String, dynamic>?;
    final header = responseBody?['header'] as Map<String, dynamic>?;
    if (header == null || header['resultCode'] != '00') {
      throw HolidayParsingException(
        '공휴일 API 응답 형식 오류: ${header?['resultMsg'] ?? response.body}',
      );
    }

    final body = responseBody!['body'] as Map<String, dynamic>?;
    final totalCount = body?['totalCount'] as int? ?? 0;
    if (totalCount == 0) return {};

    final itemsField = body!['items'];
    if (itemsField is! Map<String, dynamic>) return {};
    final rawItem = itemsField['item'];
    if (rawItem == null) return {};

    // data.go.kr 공통 특성: 결과가 1건이면 item이 단일 Map, 2건 이상이면 List로 응답됨
    final items = rawItem is List ? rawItem : [rawItem];

    final holidays = <DateTime>{};
    for (final raw in items) {
      final item = raw as Map<String, dynamic>;
      if (item['isHoliday'] != 'Y') continue;
      final locdate = item['locdate'].toString();
      holidays.add(
        DateTime(
          int.parse(locdate.substring(0, 4)),
          int.parse(locdate.substring(4, 6)),
          int.parse(locdate.substring(6, 8)),
        ),
      );
    }
    return holidays;
  }
}

@Riverpod(keepAlive: true)
HolidayDataSource holidayDataSource(Ref ref) {
  return HolidayDataSourceImpl();
}
```

- [ ] **Step 6: 코드 생성**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: `lib/data/data_sources/holiday_data_source.g.dart` 생성됨

- [ ] **Step 7: 테스트 통과 확인**

Run: `flutter test test/data/data_sources/holiday_data_source_test.dart`
Expected: PASS (8 tests)

- [ ] **Step 8: 커밋**

```bash
git add lib/common/exceptions/holiday_exceptions.dart lib/constants/api_keys.dart .gitignore lib/data/data_sources/holiday_data_source.dart lib/data/data_sources/holiday_data_source.g.dart test/data/data_sources/holiday_data_source_test.dart
git commit -m "feat: #XX - 공휴일 API HolidayDataSource 구현"
```

---

### Task 2: HolidayRepository — 월별 캐시 포함 도메인 인터페이스

**Files:**
- Create: `lib/domain/repository_interfaces/holiday_repository.dart`
- Create: `lib/data/repositories/holiday_repository_impl.dart`
- Test: `test/data/repositories/holiday_repository_impl_test.dart`

**Interfaces:**
- Consumes: `HolidayDataSource.getHolidays({required int year, required int month}) → Future<Set<DateTime>>` (Task 1), `holidayDataSourceProvider`
- Produces:
  - `abstract interface class HolidayRepository { Future<Either<Exception, bool>> isHoliday(DateTime date); }`
  - `class HolidayRepositoryImpl implements HolidayRepository` — 생성자 `HolidayRepositoryImpl({required HolidayDataSource dataSource})`
  - `@Riverpod(keepAlive: true) HolidayRepository holidayRepository(Ref ref)`

- [ ] **Step 1: 인터페이스 작성**

`lib/domain/repository_interfaces/holiday_repository.dart`:

```dart
import 'package:fpdart/fpdart.dart';

abstract interface class HolidayRepository {
  /// [date]가 공휴일인지 여부를 반환한다. 조회 실패 시 Left.
  Future<Either<Exception, bool>> isHoliday(DateTime date);
}
```

- [ ] **Step 2: 실패하는 테스트 작성**

`test/data/repositories/holiday_repository_impl_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/data/data_sources/holiday_data_source.dart';
import 'package:studio_chance/data/repositories/holiday_repository_impl.dart';

class MockHolidayDataSource extends Mock implements HolidayDataSource {}

void main() {
  late MockHolidayDataSource mockDataSource;
  late HolidayRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockHolidayDataSource();
    repository = HolidayRepositoryImpl(dataSource: mockDataSource);
  });

  group('isHoliday', () {
    test('DataSource가 반환한 날짜와 일치하면 true를 반환한다', () async {
      when(() => mockDataSource.getHolidays(year: 2026, month: 3))
          .thenAnswer((_) async => {DateTime(2026, 3, 1)});

      final result = await repository.isHoliday(DateTime(2026, 3, 1, 14, 30));

      expect(result.getOrElse((_) => false), isTrue);
    });

    test('DataSource가 반환한 날짜와 불일치하면 false를 반환한다', () async {
      when(() => mockDataSource.getHolidays(year: 2026, month: 3))
          .thenAnswer((_) async => {DateTime(2026, 3, 1)});

      final result = await repository.isHoliday(DateTime(2026, 3, 2));

      expect(result.getOrElse((_) => true), isFalse);
    });

    test('같은 월을 다시 조회하면 DataSource를 재호출하지 않는다 (캐시)', () async {
      when(() => mockDataSource.getHolidays(year: 2026, month: 3))
          .thenAnswer((_) async => {DateTime(2026, 3, 1)});

      await repository.isHoliday(DateTime(2026, 3, 1));
      await repository.isHoliday(DateTime(2026, 3, 15));

      verify(() => mockDataSource.getHolidays(year: 2026, month: 3)).called(1);
    });

    test('DataSource가 예외를 던지면 Left를 반환한다', () async {
      when(() => mockDataSource.getHolidays(year: 2026, month: 3))
          .thenThrow(Exception('network error'));

      final result = await repository.isHoliday(DateTime(2026, 3, 1));

      expect(result.isLeft(), isTrue);
    });
  });
}
```

- [ ] **Step 3: 테스트 실패 확인**

Run: `flutter test test/data/repositories/holiday_repository_impl_test.dart`
Expected: FAIL — `Error: Type 'HolidayRepositoryImpl' not found`

- [ ] **Step 4: HolidayRepositoryImpl 구현**

`lib/data/repositories/holiday_repository_impl.dart`:

```dart
import 'package:fpdart/fpdart.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studio_chance/common/utils/exception_utils.dart';
import 'package:studio_chance/data/data_sources/holiday_data_source.dart';
import 'package:studio_chance/domain/repository_interfaces/holiday_repository.dart';

part 'holiday_repository_impl.g.dart';

class HolidayRepositoryImpl implements HolidayRepository {
  final Logger _logger = Logger();
  final HolidayDataSource _dataSource;

  // key: "yyyy-MM", value: 해당 월의 공휴일 날짜(자정 기준) 집합
  final Map<String, Set<DateTime>> _cache = {};

  HolidayRepositoryImpl({required HolidayDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<Either<Exception, bool>> isHoliday(DateTime date) async {
    final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
    try {
      var holidays = _cache[key];
      if (holidays == null) {
        holidays = await _dataSource.getHolidays(
          year: date.year,
          month: date.month,
        );
        _cache[key] = holidays;
      }
      final normalized = DateTime(date.year, date.month, date.day);
      return right(holidays.contains(normalized));
    } catch (e) {
      _logger.e('공휴일 조회 실패', error: e);
      return left(toException(e));
    }
  }
}

@Riverpod(keepAlive: true)
HolidayRepository holidayRepository(Ref ref) {
  return HolidayRepositoryImpl(
    dataSource: ref.watch(holidayDataSourceProvider),
  );
}
```

- [ ] **Step 5: 코드 생성**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: `lib/data/repositories/holiday_repository_impl.g.dart` 생성됨

- [ ] **Step 6: 테스트 통과 확인**

Run: `flutter test test/data/repositories/holiday_repository_impl_test.dart`
Expected: PASS (4 tests)

- [ ] **Step 7: 커밋**

```bash
git add lib/domain/repository_interfaces/holiday_repository.dart lib/data/repositories/holiday_repository_impl.dart lib/data/repositories/holiday_repository_impl.g.dart test/data/repositories/holiday_repository_impl_test.dart
git commit -m "feat: #XX - HolidayRepositoryImpl 월별 캐시 구현"
```

---

### Task 3: HolidayUseCase + DI 배선

**Files:**
- Create: `lib/domain/use_cases/holiday_use_case.dart`
- Create: `lib/domain/use_cases/holiday_use_case_provider.dart`
- Test: `test/domain/use_cases/holiday_use_case_test.dart`

**Interfaces:**
- Consumes: `HolidayRepository.isHoliday(DateTime) → Future<Either<Exception, bool>>` (Task 2), `holidayRepositoryProvider`
- Produces:
  - `abstract interface class HolidayUseCase { Future<Either<Exception, bool>> isHoliday(DateTime date); }`
  - `class HolidayUseCaseImpl implements HolidayUseCase` — 생성자 `HolidayUseCaseImpl({required HolidayRepository holidayRepository})`
  - `@riverpod HolidayUseCase holidayUseCase(Ref ref)`

- [ ] **Step 1: 실패하는 테스트 작성**

`test/domain/use_cases/holiday_use_case_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/domain/repository_interfaces/holiday_repository.dart';
import 'package:studio_chance/domain/use_cases/holiday_use_case.dart';

class MockHolidayRepository extends Mock implements HolidayRepository {}

void main() {
  late MockHolidayRepository mockRepository;
  late HolidayUseCaseImpl useCase;

  setUp(() {
    mockRepository = MockHolidayRepository();
    useCase = HolidayUseCaseImpl(holidayRepository: mockRepository);
  });

  test('Repository의 결과를 그대로 반환한다', () async {
    when(() => mockRepository.isHoliday(DateTime(2026, 3, 1)))
        .thenAnswer((_) async => right(true));

    final result = await useCase.isHoliday(DateTime(2026, 3, 1));

    expect(result.getOrElse((_) => false), isTrue);
  });

  test('Repository가 Left를 반환하면 그대로 전달한다', () async {
    when(() => mockRepository.isHoliday(DateTime(2026, 3, 1)))
        .thenAnswer((_) async => left(Exception('실패')));

    final result = await useCase.isHoliday(DateTime(2026, 3, 1));

    expect(result.isLeft(), isTrue);
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `flutter test test/domain/use_cases/holiday_use_case_test.dart`
Expected: FAIL — `Error: Type 'HolidayUseCaseImpl' not found`

- [ ] **Step 3: HolidayUseCase 구현**

`lib/domain/use_cases/holiday_use_case.dart`:

```dart
import 'package:fpdart/fpdart.dart';
import 'package:studio_chance/domain/repository_interfaces/holiday_repository.dart';

abstract interface class HolidayUseCase {
  /// [date]가 공휴일인지 여부를 반환한다.
  Future<Either<Exception, bool>> isHoliday(DateTime date);
}

class HolidayUseCaseImpl implements HolidayUseCase {
  final HolidayRepository _holidayRepository;

  const HolidayUseCaseImpl({required HolidayRepository holidayRepository})
      : _holidayRepository = holidayRepository;

  @override
  Future<Either<Exception, bool>> isHoliday(DateTime date) {
    return _holidayRepository.isHoliday(date);
  }
}
```

`lib/domain/use_cases/holiday_use_case_provider.dart` (D5: DI 배선 파일, data import 허용):

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studio_chance/data/repositories/holiday_repository_impl.dart';
import 'package:studio_chance/domain/use_cases/holiday_use_case.dart';

part 'holiday_use_case_provider.g.dart';

@riverpod
HolidayUseCase holidayUseCase(Ref ref) {
  return HolidayUseCaseImpl(
    holidayRepository: ref.watch(holidayRepositoryProvider),
  );
}
```

- [ ] **Step 4: 코드 생성**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: `lib/domain/use_cases/holiday_use_case_provider.g.dart` 생성됨

- [ ] **Step 5: 테스트 통과 확인**

Run: `flutter test test/domain/use_cases/holiday_use_case_test.dart`
Expected: PASS (2 tests)

- [ ] **Step 6: 커밋**

```bash
git add lib/domain/use_cases/holiday_use_case.dart lib/domain/use_cases/holiday_use_case_provider.dart lib/domain/use_cases/holiday_use_case_provider.g.dart test/domain/use_cases/holiday_use_case_test.dart
git commit -m "feat: #XX - HolidayUseCase 및 Provider 배선"
```

---

### Task 4: ReservationUseCaseImpl에 HolidayRepository 연동

**Files:**
- Modify: `lib/domain/use_cases/reservation_use_case.dart:1-79` (import, 필드, 생성자), `:204-224` (`_applyCalculatedPrice`)
- Modify: `lib/domain/use_cases/reservation_use_case_provider.dart`
- Modify: `test/domain/use_cases/reservation_use_case_test.dart`

**Interfaces:**
- Consumes: `HolidayRepository.isHoliday(DateTime) → Future<Either<Exception, bool>>` (Task 2), `holidayRepositoryProvider`
- Produces: `ReservationUseCaseImpl`의 `_applyCalculatedPrice`가 실제 공휴일 여부를 `PriceSetting.calculatePrice(isHoliday:)`에 전달 (이후 태스크에서 참조 없음 — 최종 소비 지점)

- [ ] **Step 1: 실패하는 테스트 추가**

`test/domain/use_cases/reservation_use_case_test.dart`의 import 블록 교체:

```dart
// 기존
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/domain/entities/reservation.dart';
import 'package:studio_chance/domain/enums/reservation_status.dart';
import 'package:studio_chance/domain/enums/user_role.dart';
import 'package:studio_chance/domain/repository_interfaces/reservation_repository.dart';
import 'package:studio_chance/domain/repository_interfaces/store_repository.dart';
import 'package:studio_chance/domain/repository_interfaces/user_repository.dart';
import 'package:studio_chance/domain/use_cases/reservation_use_case.dart';

import '../../helpers/fake_entities.dart';

class MockReservationRepository extends Mock implements ReservationRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class MockStoreRepository extends Mock implements StoreRepository {}

class FakeReservation extends Fake implements Reservation {}
```

```dart
// 신규
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/domain/entities/day_group.dart';
import 'package:studio_chance/domain/entities/headcount_rule.dart';
import 'package:studio_chance/domain/entities/price_setting.dart';
import 'package:studio_chance/domain/entities/reservation.dart';
import 'package:studio_chance/domain/entities/space_option.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/entities/time_slot.dart';
import 'package:studio_chance/domain/enums/reservation_status.dart';
import 'package:studio_chance/domain/enums/user_role.dart';
import 'package:studio_chance/domain/enums/weekday.dart';
import 'package:studio_chance/domain/repository_interfaces/holiday_repository.dart';
import 'package:studio_chance/domain/repository_interfaces/reservation_repository.dart';
import 'package:studio_chance/domain/repository_interfaces/store_repository.dart';
import 'package:studio_chance/domain/repository_interfaces/user_repository.dart';
import 'package:studio_chance/domain/use_cases/reservation_use_case.dart';

import '../../helpers/fake_entities.dart';

class MockReservationRepository extends Mock implements ReservationRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class MockStoreRepository extends Mock implements StoreRepository {}

class MockHolidayRepository extends Mock implements HolidayRepository {}

class FakeReservation extends Fake implements Reservation {}
```

`late` 변수 선언 블록 교체:

```dart
// 기존
void main() {
  late ReservationUseCaseImpl useCase;
  late MockReservationRepository mockReservationRepo;
  late MockUserRepository mockUserRepo;
  late MockStoreRepository mockStoreRepo;
```

```dart
// 신규
void main() {
  late ReservationUseCaseImpl useCase;
  late MockReservationRepository mockReservationRepo;
  late MockUserRepository mockUserRepo;
  late MockStoreRepository mockStoreRepo;
  late MockHolidayRepository mockHolidayRepo;
```

`setUpAll`/`setUp` 블록 교체:

```dart
// 기존
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(FakeReservation());
    registerFallbackValue(ReservationStatus.pending);
  });

  setUp(() {
    mockReservationRepo = MockReservationRepository();
    mockUserRepo = MockUserRepository();
    mockStoreRepo = MockStoreRepository();
    // 기본값: store 없음 → 가격 계산 스킵, 기존 값 유지
    when(
      () => mockStoreRepo.getStore(any()),
    ).thenAnswer((_) async => right(null));
    useCase = ReservationUseCaseImpl(
      reservationRepository: mockReservationRepo,
      userRepository: mockUserRepo,
      storeRepository: mockStoreRepo,
    );
  });
```

```dart
// 신규
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(FakeReservation());
    registerFallbackValue(ReservationStatus.pending);
    registerFallbackValue(DateTime(2026));
  });

  setUp(() {
    mockReservationRepo = MockReservationRepository();
    mockUserRepo = MockUserRepository();
    mockStoreRepo = MockStoreRepository();
    mockHolidayRepo = MockHolidayRepository();
    // 기본값: store 없음 → 가격 계산 스킵, 기존 값 유지
    when(
      () => mockStoreRepo.getStore(any()),
    ).thenAnswer((_) async => right(null));
    // 기본값: 공휴일 조회 실패/미설정 시 평일로 취급
    when(
      () => mockHolidayRepo.isHoliday(any()),
    ).thenAnswer((_) async => right(false));
    useCase = ReservationUseCaseImpl(
      reservationRepository: mockReservationRepo,
      userRepository: mockUserRepo,
      storeRepository: mockStoreRepo,
      holidayRepository: mockHolidayRepo,
    );
  });
```

`late` 변수 선언에도 `late MockHolidayRepository mockHolidayRepo;` 추가 (`late MockStoreRepository mockStoreRepo;` 바로 아래).

파일 맨 끝(마지막 `}` 직전)에 새 그룹 추가:

```dart

  // ===========================================================================
  // holiday pricing (_applyCalculatedPrice)
  // ===========================================================================

  group('holiday pricing', () {
    late Store holidayAwareStore;

    setUp(() {
      holidayAwareStore = fakeStore.copyWith(
        spaceOptions: [
          SpaceOption(
            id: 'space-1',
            name: '테스트 공간',
            priceSetting: PriceSetting(
              dayGroups: [
                DayGroup(
                  days: [Weekday.sunday],
                  headcountRule: const HeadcountRule(
                    headcountBase: 4,
                    headcountExtraPrice: 0,
                    isHeadcountHourly: false,
                    isHeadcountPerPerson: false,
                  ),
                  timeSlots: const [
                    TimeSlot(
                      isAllDay: false,
                      startTime: 0,
                      endTime: 1440,
                      price: 10000,
                      isHourly: false,
                      isPerPerson: false,
                    ),
                  ],
                ),
                DayGroup(
                  days: [Weekday.holiday],
                  headcountRule: const HeadcountRule(
                    headcountBase: 4,
                    headcountExtraPrice: 0,
                    isHeadcountHourly: false,
                    isHeadcountPerPerson: false,
                  ),
                  timeSlots: const [
                    TimeSlot(
                      isAllDay: false,
                      startTime: 0,
                      endTime: 1440,
                      price: 30000,
                      isHourly: false,
                      isPerPerson: false,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
      when(() => mockStoreRepo.getStore(any()))
          .thenAnswer((_) async => right(holidayAwareStore));
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(fakeUser));
      when(
        () => mockReservationRepo.createReservation(
          reservation: any(named: 'reservation'),
        ),
      ).thenAnswer((invocation) async {
        return right(
          invocation.namedArguments[#reservation] as Reservation,
        );
      });
    });

    // 2026-03-01은 일요일(Weekday.sunday)
    final reservation = fakeReservation.copyWith(
      startTime: DateTime(2026, 3, 1, 10, 0),
      endTime: DateTime(2026, 3, 1, 11, 0),
    );

    test('공휴일이면 공휴일 요금(30000원)이 적용된다', () async {
      when(() => mockHolidayRepo.isHoliday(any()))
          .thenAnswer((_) async => right(true));

      final result = await useCase.createReservation(reservation: reservation);

      expect(result.getOrElse((_) => fakeReservation).calculatedPrice, 30000);
    });

    test('평일(공휴일 아님)이면 평일 요금(10000원)이 적용된다', () async {
      when(() => mockHolidayRepo.isHoliday(any()))
          .thenAnswer((_) async => right(false));

      final result = await useCase.createReservation(reservation: reservation);

      expect(result.getOrElse((_) => fakeReservation).calculatedPrice, 10000);
    });

    test('공휴일 조회 실패 시 평일 요금으로 폴백한다', () async {
      when(() => mockHolidayRepo.isHoliday(any()))
          .thenAnswer((_) async => left(Exception('네트워크 오류')));

      final result = await useCase.createReservation(reservation: reservation);

      expect(result.getOrElse((_) => fakeReservation).calculatedPrice, 10000);
    });
  });
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `flutter test test/domain/use_cases/reservation_use_case_test.dart`
Expected: FAIL — `Error: No named parameter with the name 'holidayRepository'` (생성자에 아직 파라미터 없음)

- [ ] **Step 3: ReservationUseCaseImpl 수정**

`lib/domain/use_cases/reservation_use_case.dart` 상단 import에 추가:

```dart
import 'package:studio_chance/domain/repository_interfaces/holiday_repository.dart';
```

생성자 블록 교체:

```dart
// 기존
class ReservationUseCaseImpl implements ReservationUseCase {
  final ReservationRepository _reservationRepository;
  final UserRepository _userRepository;
  final StoreRepository _storeRepository;

  const ReservationUseCaseImpl({
    required ReservationRepository reservationRepository,
    required UserRepository userRepository,
    required StoreRepository storeRepository,
  }) : _reservationRepository = reservationRepository,
       _userRepository = userRepository,
       _storeRepository = storeRepository;
```

```dart
// 신규
class ReservationUseCaseImpl implements ReservationUseCase {
  final ReservationRepository _reservationRepository;
  final UserRepository _userRepository;
  final StoreRepository _storeRepository;
  final HolidayRepository _holidayRepository;

  const ReservationUseCaseImpl({
    required ReservationRepository reservationRepository,
    required UserRepository userRepository,
    required StoreRepository storeRepository,
    required HolidayRepository holidayRepository,
  }) : _reservationRepository = reservationRepository,
       _userRepository = userRepository,
       _storeRepository = storeRepository,
       _holidayRepository = holidayRepository;
```

`_applyCalculatedPrice` 교체:

```dart
// 기존
  Future<Reservation> _applyCalculatedPrice(Reservation reservation) async {
    final storeResult = await _storeRepository.getStore(
      reservation.storeSummary.id,
    );

    final store = storeResult.toOption().toNullable();
    if (store == null) return reservation;

    final priceSetting = store.priceSettingForSpace(reservation.spaceOptionId);
    if (priceSetting == null) return reservation;

    final calculatedPrice = priceSetting.calculatePrice(
      start: reservation.startTime,
      end: reservation.endTime,
      headCount: reservation.headCount,
      isAllDay: reservation.isAllDay,
      isHoliday: false, // TODO: 공휴일 API 연동 후 실제 값 전달
    );

    return reservation.copyWith(
      calculatedPrice: calculatedPrice,
      totalPrice: calculatedPrice + reservation.priceAdjustment,
    );
  }
```

```dart
// 신규
  Future<Reservation> _applyCalculatedPrice(Reservation reservation) async {
    final storeResult = await _storeRepository.getStore(
      reservation.storeSummary.id,
    );

    final store = storeResult.toOption().toNullable();
    if (store == null) return reservation;

    final priceSetting = store.priceSettingForSpace(reservation.spaceOptionId);
    if (priceSetting == null) return reservation;

    final isHolidayResult = await _holidayRepository.isHoliday(
      reservation.startTime,
    );
    final isHoliday = isHolidayResult.getOrElse((_) => false);

    final calculatedPrice = priceSetting.calculatePrice(
      start: reservation.startTime,
      end: reservation.endTime,
      headCount: reservation.headCount,
      isAllDay: reservation.isAllDay,
      isHoliday: isHoliday,
    );

    return reservation.copyWith(
      calculatedPrice: calculatedPrice,
      totalPrice: calculatedPrice + reservation.priceAdjustment,
    );
  }
```

`lib/domain/use_cases/reservation_use_case_provider.dart` 전체 교체:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studio_chance/data/repositories/holiday_repository_impl.dart';
import 'package:studio_chance/data/repositories/reservation_repository_impl.dart';
import 'package:studio_chance/data/repositories/store_repository_impl.dart';
import 'package:studio_chance/data/repositories/user_repository_impl.dart';
import 'package:studio_chance/domain/use_cases/reservation_use_case.dart';

part 'reservation_use_case_provider.g.dart';

@riverpod
ReservationUseCase reservationUseCase(Ref ref) {
  final reservationRepository = ref.watch(reservationRepositoryProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final storeRepository = ref.watch(storeRepositoryProvider);
  final holidayRepository = ref.watch(holidayRepositoryProvider);

  return ReservationUseCaseImpl(
    reservationRepository: reservationRepository,
    userRepository: userRepository,
    storeRepository: storeRepository,
    holidayRepository: holidayRepository,
  );
}
```

- [ ] **Step 4: 테스트 통과 확인**

Run: `flutter test test/domain/use_cases/reservation_use_case_test.dart`
Expected: PASS (모든 기존 테스트 + 신규 3개)

- [ ] **Step 5: 전체 회귀 확인**

Run: `flutter test`
Expected: 전체 PASS, `dart analyze` 에러 없음

- [ ] **Step 6: 커밋**

```bash
git add lib/domain/use_cases/reservation_use_case.dart lib/domain/use_cases/reservation_use_case_provider.dart test/domain/use_cases/reservation_use_case_test.dart
git commit -m "feat: #XX - ReservationUseCase에 HolidayRepository 연동, 공휴일 요금 적용"
```

---

### Task 5: 프레젠테이션 계층 isHolidayProvider

**Files:**
- Create: `lib/presentation/providers/is_holiday_provider.dart`
- Test: `test/presentation/providers/is_holiday_provider_test.dart`

**Interfaces:**
- Consumes: `HolidayUseCase.isHoliday(DateTime) → Future<Either<Exception, bool>>` (Task 3), `holidayUseCaseProvider`
- Produces: `@riverpod Future<bool> isHoliday(Ref ref, DateTime date)` → `isHolidayProvider(DateTime date)` (Task 6, 7에서 `ref.read(isHolidayProvider(date).future)`로 사용)

- [ ] **Step 1: 실패하는 테스트 작성**

`test/presentation/providers/is_holiday_provider_test.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/domain/use_cases/holiday_use_case.dart';
import 'package:studio_chance/domain/use_cases/holiday_use_case_provider.dart';
import 'package:studio_chance/presentation/providers/is_holiday_provider.dart';

class MockHolidayUseCase extends Mock implements HolidayUseCase {}

void main() {
  late MockHolidayUseCase mockUseCase;

  setUpAll(() {
    registerFallbackValue(DateTime(2026));
  });

  setUp(() {
    mockUseCase = MockHolidayUseCase();
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [holidayUseCaseProvider.overrideWith((ref) => mockUseCase)],
    );
  }

  test('UseCase가 true를 반환하면 true를 반환한다', () async {
    when(() => mockUseCase.isHoliday(DateTime(2026, 3, 1)))
        .thenAnswer((_) async => right(true));
    final container = createContainer();
    addTearDown(container.dispose);

    final sub = container.listen(isHolidayProvider(DateTime(2026, 3, 1)), (_, _) {});
    addTearDown(sub.close);
    final result = await container.read(isHolidayProvider(DateTime(2026, 3, 1)).future);

    expect(result, isTrue);
  });

  test('UseCase가 Left를 반환하면 false로 폴백한다', () async {
    when(() => mockUseCase.isHoliday(DateTime(2026, 3, 1)))
        .thenAnswer((_) async => left(Exception('실패')));
    final container = createContainer();
    addTearDown(container.dispose);

    final sub = container.listen(isHolidayProvider(DateTime(2026, 3, 1)), (_, _) {});
    addTearDown(sub.close);
    final result = await container.read(isHolidayProvider(DateTime(2026, 3, 1)).future);

    expect(result, isFalse);
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `flutter test test/presentation/providers/is_holiday_provider_test.dart`
Expected: FAIL — `Error: Target of URI doesn't exist: 'package:studio_chance/presentation/providers/is_holiday_provider.dart'`

- [ ] **Step 3: isHolidayProvider 구현**

`lib/presentation/providers/is_holiday_provider.dart`:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studio_chance/domain/use_cases/holiday_use_case_provider.dart';

part 'is_holiday_provider.g.dart';

/// [date]가 공휴일인지 여부를 반환한다. 조회 실패 시 false로 폴백한다.
@riverpod
Future<bool> isHoliday(Ref ref, DateTime date) async {
  final useCase = ref.watch(holidayUseCaseProvider);
  final result = await useCase.isHoliday(date);
  return result.getOrElse((_) => false);
}
```

- [ ] **Step 4: 코드 생성**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: `lib/presentation/providers/is_holiday_provider.g.dart` 생성됨

- [ ] **Step 5: 테스트 통과 확인**

Run: `flutter test test/presentation/providers/is_holiday_provider_test.dart`
Expected: PASS (2 tests)

- [ ] **Step 6: 커밋**

```bash
git add lib/presentation/providers/is_holiday_provider.dart lib/presentation/providers/is_holiday_provider.g.dart test/presentation/providers/is_holiday_provider_test.dart
git commit -m "feat: #XX - isHolidayProvider 추가"
```

---

### Task 6: ReservationCreateModal 연동

**Files:**
- Modify: `lib/presentation/home/widgets/three_day_calendar/reservation_create_modal.dart:216-230`

**Interfaces:**
- Consumes: `isHolidayProvider(DateTime) → Future<bool>` (Task 5)
- Produces: 없음 (UI 최종 소비 지점, 자동화 테스트 대상 아님 — 화면 레벨 수동 검증으로 대체)

이 모달은 `ConsumerStatefulWidget`이므로 `_recalculatePrice()`는 `ref`에 접근 가능하다. 기존 코드베이스는 "State 변경이 필요한 비동기 조회"를 `async/await`로 함수 시그니처를 바꾸는 대신, 같은 파일의 `_loadReservationCount()`처럼 `.then()` 콜백 + `if (!mounted) return;` 패턴을 쓴다 (`reservation_detail_modal.dart:309-312` 참고). `_recalculatePrice()`는 7곳에서 `await` 없이 호출되므로, 시그니처를 유지한 채 내부만 비동기로 바꾸는 이 방식이 호출부 변경을 요구하지 않아 가장 안전하다.

- [ ] **Step 1: import 추가**

`lib/presentation/home/widgets/three_day_calendar/reservation_create_modal.dart` 상단에 추가:

```dart
import 'package:studio_chance/presentation/providers/is_holiday_provider.dart';
```

- [ ] **Step 2: `_recalculatePrice()` 교체**

```dart
// 기존
  void _recalculatePrice() {
    final spaces = _spaceOptions;
    if (spaces.isEmpty) return;
    final priceSetting = _spaceOptionId != null
        ? (spaces.where((s) => s.id == _spaceOptionId).firstOrNull?.priceSetting ?? spaces.first.priceSetting)
        : spaces.first.priceSetting;
    final headCount = int.tryParse(_headCountController.text) ?? 0;
    final price = priceSetting.calculatePrice(
      start: _startTime,
      end: _endTime,
      headCount: headCount,
      isAllDay: _isAllDay,
      isHoliday: false, // TODO: 공휴일 API 연동 후 실제 값 전달
    );
    setState(() => _calculatedPrice = price);
  }
```

```dart
// 신규
  void _recalculatePrice() {
    final spaces = _spaceOptions;
    if (spaces.isEmpty) return;
    final priceSetting = _spaceOptionId != null
        ? (spaces.where((s) => s.id == _spaceOptionId).firstOrNull?.priceSetting ?? spaces.first.priceSetting)
        : spaces.first.priceSetting;
    final headCount = int.tryParse(_headCountController.text) ?? 0;
    // 콜백 실행 시점에 _startTime 등이 바뀌어 있을 수 있으므로 호출 시점 값을 캡처
    final start = _startTime;
    final end = _endTime;
    final isAllDay = _isAllDay;
    ref.read(isHolidayProvider(start).future).then((isHoliday) {
      if (!mounted) return;
      final price = priceSetting.calculatePrice(
        start: start,
        end: end,
        headCount: headCount,
        isAllDay: isAllDay,
        isHoliday: isHoliday,
      );
      setState(() => _calculatedPrice = price);
    });
  }
```

- [ ] **Step 3: 정적 분석 확인**

Run: `dart analyze lib/presentation/home/widgets/three_day_calendar/reservation_create_modal.dart`
Expected: No issues found!

- [ ] **Step 4: 커밋**

```bash
git add lib/presentation/home/widgets/three_day_calendar/reservation_create_modal.dart
git commit -m "feat: #XX - 예약 생성 모달에 공휴일 요금 반영"
```

---

### Task 7: ReservationDetailModal 연동

**Files:**
- Modify: `lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart:172-176` (`initState`), `:315-330` (`_recalculatePrice`)

**Interfaces:**
- Consumes: `isHolidayProvider(DateTime) → Future<bool>` (Task 5)
- Produces: 없음 (UI 최종 소비 지점)

`_applyInitialPrice()`는 "initState에서 setState 호출 불가"라는 이유로 존재하는 동기 함수이므로 그대로 둔다(첫 프레임에 즉시 대략적인 가격을 보여주는 역할, `isHoliday: false` 고정은 유지). 대신 `initState` 마지막에 `_recalculatePrice()`를 추가로 호출해 마운트 직후 공휴일 여부를 반영한 값으로 자동 보정한다.

- [ ] **Step 1: import 추가**

`lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart` 상단에 추가:

```dart
import 'package:studio_chance/presentation/providers/is_holiday_provider.dart';
```

- [ ] **Step 2: `initState`에서 보정 호출 추가**

```dart
// 기존
    if (preloaded != null) {
      _spaceOptions = preloaded;
      if (preloaded.isNotEmpty && _spaceOptionId == null) {
        _spaceOptionId = preloaded.first.id;
      }
      // initState에서 직접 계산 (setState 호출 불가)
      _applyInitialPrice(preloaded);
    } else {
      _loadSpaceOptions(widget.reservation.storeSummary.id);
    }
```

```dart
// 신규
    if (preloaded != null) {
      _spaceOptions = preloaded;
      if (preloaded.isNotEmpty && _spaceOptionId == null) {
        _spaceOptionId = preloaded.first.id;
      }
      // initState에서 직접 계산 (setState 호출 불가) — 공휴일 여부는 아직 미반영
      _applyInitialPrice(preloaded);
      // 공휴일 여부를 반영한 최종 가격으로 마운트 직후 비동기 보정
      _recalculatePrice();
    } else {
      _loadSpaceOptions(widget.reservation.storeSummary.id);
    }
```

- [ ] **Step 3: `_recalculatePrice()` 교체**

```dart
// 기존
  void _recalculatePrice() {
    final spaces = _spaceOptions;
    if (spaces == null || spaces.isEmpty) return;
    final priceSetting = _spaceOptionId != null
        ? (spaces.where((s) => s.id == _spaceOptionId).firstOrNull?.priceSetting ?? spaces.first.priceSetting)
        : spaces.first.priceSetting;
    final headCount = int.tryParse(_headCountController.text) ?? 0;
    final price = priceSetting.calculatePrice(
      start: _startTime,
      end: _endTime,
      headCount: headCount,
      isAllDay: _isAllDay,
      isHoliday: false, // TODO: 공휴일 API 연동 후 실제 값 전달
    );
    setState(() => _calculatedPrice = price);
  }
```

```dart
// 신규
  void _recalculatePrice() {
    final spaces = _spaceOptions;
    if (spaces == null || spaces.isEmpty) return;
    final priceSetting = _spaceOptionId != null
        ? (spaces.where((s) => s.id == _spaceOptionId).firstOrNull?.priceSetting ?? spaces.first.priceSetting)
        : spaces.first.priceSetting;
    final headCount = int.tryParse(_headCountController.text) ?? 0;
    final start = _startTime;
    final end = _endTime;
    final isAllDay = _isAllDay;
    ref.read(isHolidayProvider(start).future).then((isHoliday) {
      if (!mounted) return;
      final price = priceSetting.calculatePrice(
        start: start,
        end: end,
        headCount: headCount,
        isAllDay: isAllDay,
        isHoliday: isHoliday,
      );
      setState(() => _calculatedPrice = price);
    });
  }
```

- [ ] **Step 4: 정적 분석 확인**

Run: `dart analyze lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart`
Expected: No issues found!

- [ ] **Step 5: 커밋**

```bash
git add lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart
git commit -m "feat: #XX - 예약 수정 모달에 공휴일 요금 반영"
```

---

### Task 8: 전체 검증 및 실기기 확인

**Files:** 없음 (검증 전용)

**Interfaces:**
- Consumes: Task 1~7의 전체 산출물
- Produces: 없음 (완료 기준 확인)

- [ ] **Step 1: 전체 정적 분석**

Run: `dart analyze`
Expected: No issues found!

- [ ] **Step 2: 전체 테스트**

Run: `flutter test`
Expected: 전체 PASS, 회귀 없음

- [ ] **Step 3: 실제 API 키로 수동 스모크 테스트**

`lib/constants/api_keys.dart`에 실제 발급받은 서비스 키를 넣은 상태로:

```bash
flutter run --target lib/main_dev.dart
```

앱에서 알려진 공휴일(예: 삼일절 3/1)에 예약을 생성해보고, `PriceSetting`에 공휴일 요금 그룹(`Weekday.holiday`)을 설정한 점포에서 계산된 금액이 공휴일 요금으로 표시되는지 확인. 평일 날짜로도 동일하게 확인하여 회귀가 없는지 확인.

- [ ] **Step 4: 커밋 (검증 완료 표시가 필요하면)**

검증만 수행하는 태스크이므로 코드 변경 없음 — 별도 커밋 불필요. 문제 발견 시 해당 태스크로 돌아가 수정 후 재커밋.

---

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-07-23-holiday-pricing.md`. Two execution options:

1. **Subagent-Driven (recommended)** - 태스크별로 새 subagent를 띄워 리뷰하며 빠르게 반복
2. **Inline Execution** - 이번 세션에서 executing-plans로 배치 실행, 체크포인트마다 검토

Which approach?
