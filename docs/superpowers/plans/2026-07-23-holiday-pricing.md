# 공휴일 요금 자동 적용 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 예약 가격 계산 시 공휴일 여부를 실제로 판정하여 `PriceSetting.calculatePrice(isHoliday: ...)`에 실제 값을 전달한다. 현재는 모든 호출부에서 `isHoliday: (date) => false`로 고정되어 있어 공휴일 요금 그룹(`Weekday.holiday`)이 절대 적용되지 않는다.

> **⚠️ #15 [C-1] 이후 재검토 완료 (2026-07-27):** 이 플랜은 최초 작성 시 `calculatePrice(isHoliday: bool)`(단일 bool) 시그니처를 전제로 설계되었다. 이후 #15 [C-1]에서 다일 예약의 날짜별 공휴일 반영을 위해 시그니처가 `bool Function(DateTime date)?`(날짜별 동기 콜백)로 변경되었다. 아래 내용은 이 새 시그니처에 맞춰 전면 갱신된 버전이다 — `HolidayRepository`/`HolidayUseCase`는 단일 날짜 대신 **예약 기간 전체의 공휴일 날짜 Set**을 비동기로 미리 조회한 뒤, 그 Set을 캡처하는 동기 콜백을 `calculatePrice`에 전달하는 방식으로 재설계했다.

**Architecture:** Clean Architecture 4계층으로 신규 `Holiday` 수직 슬라이스를 추가한다. `HolidayDataSource`(공공데이터포털 HTTP 호출, 월별 단위) → `HolidayRepositoryImpl`(월별 캐시 + 기간 병합) → `HolidayUseCase`(단순 위임) → `holidaysInRangeProvider`(Riverpod, 예약 기간의 공휴일 `Set<DateTime>` 반환). `ReservationUseCaseImpl`은 `HolidayRepository`를 직접 주입받아 가격 계산 시점에 예약 기간의 공휴일 Set을 조회하고, 그 Set을 캡처하는 동기 콜백을 `calculatePrice(isHoliday: ...)`에 전달한다(기존 `StoreRepository` 주입과 동일한 패턴, D3).

**Tech Stack:** `http: ^1.6.0`(이미 pubspec.yaml에 존재, 추가 설치 불필요), `fpdart` Either, `riverpod_generator`, `mocktail`.

## Global Constraints

- API: 한국천문연구원 특일 정보 API — `GET https://apis.data.go.kr/B090041/openapi/service/SpcdeInfoService/getRestDeInfo` (공공데이터포털, `solYear`/`solMonth`/`serviceKey`/`_type=json` 쿼리 파라미터)
- 발급처: https://www.data.go.kr/data/15012690/openapi.do — 이 플랜을 실행하는 사람이 사전에 서비스 키를 발급받아야 한다 (승인까지 통상 1~2시간 소요, 공공데이터포털 특성)
- API 키는 `.gitignore` 처리된 `lib/constants/api_keys.dart`에만 저장 — 절대 커밋 금지 (CLAUDE.md "중요 사항")
- `Either<Exception, T>` 반환 패턴, 프로덕션 코드에서 `isLeft()/isRight()` 명령형 스타일 금지 — `fold`/`getOrElse` 사용 (테스트 코드는 기존 관례상 `isLeft()/isRight()` 허용)
- 공휴일 조회 실패는 예약 흐름을 막지 않고 빈 `Set<DateTime>`(=모든 날짜를 공휴일 아님으로 처리)으로 조용히 폴백한다 (silent — 사용자에게 별도 알림 없음)
- 콘솔 출력은 `logger` 라이브러리 사용
- 커밋 메시지는 한국어. 이슈 번호는 아직 GitHub에 생성되지 않았으므로 각 커밋 예시의 `#XX`는 실제 이슈 번호로 치환할 것 (CLAUDE.md Git 컨벤션: `feat/#<이슈번호>-<설명>` 브랜치, `<type>: #<이슈번호> - <설명>` 커밋)
- `dart run build_runner build --delete-conflicting-outputs`는 `@riverpod`/`@Riverpod` 어노테이션이 추가된 파일을 만들 때마다 실행

---

### 현재 상태 (2026-07-27 갱신)

| 파일 | 현재 상태 |
|------|-----------|
| `lib/domain/entities/price_setting.dart` | `calculatePrice({..., bool Function(DateTime date)? isHoliday})` — 날짜별 동기 콜백으로 이미 구현 완료(#15 [C-1]). 생략 시 모든 날짜를 공휴일 아님으로 처리. 공휴일 판정 로직 자체는 손댈 필요 없음 |
| `lib/common/enums/weekday.dart` | `Weekday.holiday`(`@JsonValue(8)`) 이미 정의됨 (#15 [I-1]에서 `domain/enums`→`common/enums`로 이동) |
| `lib/domain/use_cases/reservation_use_case.dart:254` | `isHoliday: (date) => false, // TODO: 공휴일 API 연동 후 실제 판단 로직 전달` |
| `lib/presentation/.../reservation_create_modal.dart:232` | 동일 TODO |
| `lib/presentation/.../reservation_detail_modal.dart:328,345` | 동일 TODO (2곳: `_recalculatePrice`, `_applyInitialPrice`) |
| `pubspec.yaml` | `http: ^1.6.0` 이미 존재하나 `lib/` 어디서도 아직 사용되지 않음 (이번이 첫 사용처) |
| `lib/constants/api_keys.dart` | 존재하지 않음 — 이번 플랜에서 최초 생성 |

> `isHoliday`가 `bool Function(DateTime date)?` 콜백이므로, `HolidayRepository`/`HolidayUseCase`는 "단일 날짜 하나가 공휴일인지"가 아니라 "예약 기간에 걸친 날짜들 중 공휴일인 날짜의 `Set<DateTime>`"을 비동기로 반환하도록 설계한다(아래 Task 2/3). 호출부는 그 Set을 캡처하는 동기 콜백 `(date) => holidays.contains(...)`을 만들어 `calculatePrice`에 전달한다.

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
  - `abstract interface class HolidayRepository { Future<Either<Exception, Set<DateTime>>> getHolidaysInRange({required DateTime start, required DateTime end}); }`
  - `class HolidayRepositoryImpl implements HolidayRepository` — 생성자 `HolidayRepositoryImpl({required HolidayDataSource dataSource})`
  - `@Riverpod(keepAlive: true) HolidayRepository holidayRepository(Ref ref)`

`isHoliday(DateTime)` 대신 `getHolidaysInRange`로 설계한 이유: `PriceSetting.calculatePrice`의 `isHoliday` 파라미터가 `bool Function(DateTime date)?`(동기 콜백)이므로, 호출부는 예약 기간 전체의 공휴일 날짜를 미리 비동기로 조회해 `Set<DateTime>`으로 받은 뒤 그 Set을 캡처하는 동기 콜백을 만들어야 한다. 단일 날짜만 조회하는 API로는 다일(allDay) 예약에서 날짜마다 반복 조회가 필요해 비효율적이고, 콜백 자체를 동기로 유지할 수 없다.

- [ ] **Step 1: 인터페이스 작성**

`lib/domain/repository_interfaces/holiday_repository.dart`:

```dart
import 'package:fpdart/fpdart.dart';

abstract interface class HolidayRepository {
  /// [start] 이상 [end] 미만 범위에 포함된 날짜 중 공휴일인 날짜(자정 기준)의 Set을 반환한다.
  /// 조회 실패 시 Left.
  Future<Either<Exception, Set<DateTime>>> getHolidaysInRange({
    required DateTime start,
    required DateTime end,
  });
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

  group('getHolidaysInRange', () {
    test('단일 월 범위 — DataSource가 반환한 공휴일 Set을 그대로 반환한다', () async {
      when(() => mockDataSource.getHolidays(year: 2026, month: 3))
          .thenAnswer((_) async => {DateTime(2026, 3, 1)});

      final result = await repository.getHolidaysInRange(
        start: DateTime(2026, 3, 1, 10, 0),
        end: DateTime(2026, 3, 1, 12, 0),
      );

      expect(result.getOrElse((_) => {}), {DateTime(2026, 3, 1)});
    });

    test('두 달에 걸친 범위 — 두 달의 DataSource 결과를 병합한다', () async {
      when(() => mockDataSource.getHolidays(year: 2026, month: 2))
          .thenAnswer((_) async => {DateTime(2026, 2, 28)});
      when(() => mockDataSource.getHolidays(year: 2026, month: 3))
          .thenAnswer((_) async => {DateTime(2026, 3, 1)});

      final result = await repository.getHolidaysInRange(
        start: DateTime(2026, 2, 27),
        end: DateTime(2026, 3, 2),
      );

      expect(
        result.getOrElse((_) => {}),
        {DateTime(2026, 2, 28), DateTime(2026, 3, 1)},
      );
    });

    test('같은 월을 다시 조회하면 DataSource를 재호출하지 않는다 (캐시)', () async {
      when(() => mockDataSource.getHolidays(year: 2026, month: 3))
          .thenAnswer((_) async => {DateTime(2026, 3, 1)});

      await repository.getHolidaysInRange(
        start: DateTime(2026, 3, 1),
        end: DateTime(2026, 3, 2),
      );
      await repository.getHolidaysInRange(
        start: DateTime(2026, 3, 15),
        end: DateTime(2026, 3, 16),
      );

      verify(() => mockDataSource.getHolidays(year: 2026, month: 3)).called(1);
    });

    test('DataSource가 예외를 던지면 Left를 반환한다', () async {
      when(() => mockDataSource.getHolidays(year: 2026, month: 3))
          .thenThrow(Exception('network error'));

      final result = await repository.getHolidaysInRange(
        start: DateTime(2026, 3, 1),
        end: DateTime(2026, 3, 2),
      );

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
  Future<Either<Exception, Set<DateTime>>> getHolidaysInRange({
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      // [start, end] 사이에 걸친 연-월 쌍을 모두 구한다 (end는 보통 다음 날 자정이므로
      // 포함 관계를 안전하게 처리하기 위해 end를 그대로 순회 상한에 포함시킨다).
      final months = <String>{};
      var cursor = DateTime(start.year, start.month);
      final endMonth = DateTime(end.year, end.month);
      while (!cursor.isAfter(endMonth)) {
        months.add('${cursor.year}-${cursor.month.toString().padLeft(2, '0')}');
        cursor = DateTime(cursor.year, cursor.month + 1);
      }

      final merged = <DateTime>{};
      for (final key in months) {
        var holidays = _cache[key];
        if (holidays == null) {
          final parts = key.split('-');
          holidays = await _dataSource.getHolidays(
            year: int.parse(parts[0]),
            month: int.parse(parts[1]),
          );
          _cache[key] = holidays;
        }
        merged.addAll(holidays);
      }

      return right(merged);
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
- Consumes: `HolidayRepository.getHolidaysInRange({required DateTime start, required DateTime end}) → Future<Either<Exception, Set<DateTime>>>` (Task 2), `holidayRepositoryProvider`
- Produces:
  - `abstract interface class HolidayUseCase { Future<Either<Exception, Set<DateTime>>> getHolidaysInRange({required DateTime start, required DateTime end}); }`
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
    when(
      () => mockRepository.getHolidaysInRange(
        start: DateTime(2026, 3, 1),
        end: DateTime(2026, 3, 2),
      ),
    ).thenAnswer((_) async => right({DateTime(2026, 3, 1)}));

    final result = await useCase.getHolidaysInRange(
      start: DateTime(2026, 3, 1),
      end: DateTime(2026, 3, 2),
    );

    expect(result.getOrElse((_) => {}), {DateTime(2026, 3, 1)});
  });

  test('Repository가 Left를 반환하면 그대로 전달한다', () async {
    when(
      () => mockRepository.getHolidaysInRange(
        start: DateTime(2026, 3, 1),
        end: DateTime(2026, 3, 2),
      ),
    ).thenAnswer((_) async => left(Exception('실패')));

    final result = await useCase.getHolidaysInRange(
      start: DateTime(2026, 3, 1),
      end: DateTime(2026, 3, 2),
    );

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
  /// [start] 이상 [end] 미만 범위의 공휴일 날짜 Set을 반환한다.
  Future<Either<Exception, Set<DateTime>>> getHolidaysInRange({
    required DateTime start,
    required DateTime end,
  });
}

class HolidayUseCaseImpl implements HolidayUseCase {
  final HolidayRepository _holidayRepository;

  const HolidayUseCaseImpl({required HolidayRepository holidayRepository})
      : _holidayRepository = holidayRepository;

  @override
  Future<Either<Exception, Set<DateTime>>> getHolidaysInRange({
    required DateTime start,
    required DateTime end,
  }) {
    return _holidayRepository.getHolidaysInRange(start: start, end: end);
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
- Modify: `lib/domain/use_cases/reservation_use_case.dart` (import, 필드, 생성자, `_applyCalculatedPrice`)
- Modify: `lib/domain/use_cases/reservation_use_case_provider.dart`
- Modify: `test/domain/use_cases/reservation_use_case_test.dart`

**Interfaces:**
- Consumes: `HolidayRepository.getHolidaysInRange({required DateTime start, required DateTime end}) → Future<Either<Exception, Set<DateTime>>>` (Task 2), `holidayRepositoryProvider`
- Produces: `ReservationUseCaseImpl`의 `_applyCalculatedPrice`가 예약 기간의 공휴일 Set을 조회한 뒤, 그 Set을 캡처하는 동기 콜백을 `PriceSetting.calculatePrice(isHoliday:)`에 전달 (이후 태스크에서 참조 없음 — 최종 소비 지점)

- [ ] **Step 1: 실패하는 테스트 추가**

> **참고:** #15에서 이 테스트 파일에 `auth_exceptions.dart` import와 `watchReservationsByDateRange`(#15 [I-3]) 테스트 그룹이 이미 추가되어 있다. 아래 "기존" 블록은 이번 태스크와 무관한 그 변경들은 생략하고 이번 태스크가 실제로 건드리는 import/선언부만 발췌한 것이다 — 실제 적용 시 파일 전체를 열어 정확한 현재 상태를 확인한 뒤 아래 diff의 의도(신규 import·mock·그룹 추가)만 반영할 것.

`test/domain/use_cases/reservation_use_case_test.dart`의 import 블록 교체:

```dart
// 기존
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/domain/entities/reservation.dart';
import 'package:studio_chance/common/enums/reservation_status.dart';
import 'package:studio_chance/common/enums/user_role.dart';
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
import 'package:studio_chance/common/enums/reservation_status.dart';
import 'package:studio_chance/common/enums/user_role.dart';
import 'package:studio_chance/common/enums/weekday.dart';
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

`setUpAll`/`setUp` 블록 교체 (`registerFallbackValue(DateTime(2026))`는 `getHolidaysInRange`의 named 파라미터 `any(named: 'start'/'end')` 매칭에 필요):

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
    // 기본값: 공휴일 조회 실패/미설정 시 공휴일 없음(평일)으로 취급
    when(
      () => mockHolidayRepo.getHolidaysInRange(
        start: any(named: 'start'),
        end: any(named: 'end'),
      ),
    ).thenAnswer((_) async => right(<DateTime>{}));
    useCase = ReservationUseCaseImpl(
      reservationRepository: mockReservationRepo,
      userRepository: mockUserRepo,
      storeRepository: mockStoreRepo,
      holidayRepository: mockHolidayRepo,
    );
  });
```

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

    test('예약 시작일이 공휴일 Set에 포함되면 공휴일 요금(30000원)이 적용된다', () async {
      when(
        () => mockHolidayRepo.getHolidaysInRange(
          start: any(named: 'start'),
          end: any(named: 'end'),
        ),
      ).thenAnswer((_) async => right({DateTime(2026, 3, 1)}));

      final result = await useCase.createReservation(reservation: reservation);

      expect(result.getOrElse((_) => fakeReservation).calculatedPrice, 30000);
    });

    test('공휴일 Set에 포함되지 않으면 평일 요금(10000원)이 적용된다', () async {
      when(
        () => mockHolidayRepo.getHolidaysInRange(
          start: any(named: 'start'),
          end: any(named: 'end'),
        ),
      ).thenAnswer((_) async => right(<DateTime>{}));

      final result = await useCase.createReservation(reservation: reservation);

      expect(result.getOrElse((_) => fakeReservation).calculatedPrice, 10000);
    });

    test('공휴일 조회 실패 시 평일 요금으로 폴백한다', () async {
      when(
        () => mockHolidayRepo.getHolidaysInRange(
          start: any(named: 'start'),
          end: any(named: 'end'),
        ),
      ).thenAnswer((_) async => left(Exception('네트워크 오류')));

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
  final Logger _logger = Logger();

  ReservationUseCaseImpl({
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
  final Logger _logger = Logger();

  ReservationUseCaseImpl({
    required ReservationRepository reservationRepository,
    required UserRepository userRepository,
    required StoreRepository storeRepository,
    required HolidayRepository holidayRepository,
  }) : _reservationRepository = reservationRepository,
       _userRepository = userRepository,
       _storeRepository = storeRepository,
       _holidayRepository = holidayRepository;
```

> **주의:** #15 [C-2]에서 `ReservationUseCaseImpl`의 생성자가 이미 `const`에서 일반 생성자로 바뀌고 `final Logger _logger = Logger();` 필드가 추가되어 있다. 실제 파일을 열어 정확한 현재 필드/생성자 구성을 확인한 뒤 `HolidayRepository` 필드/파라미터만 추가할 것 — 위 코드 블록은 예시이며 그대로 덮어쓰지 말 것.

`_applyCalculatedPrice` 교체 (#15 [C-1]/[C-2] 반영 후 실제 현재 형태 기준):

```dart
// 기존 (#15 반영 후 현재 코드)
  Future<Either<Exception, Reservation>> _applyCalculatedPrice(
    Reservation reservation,
  ) async {
    final storeResult = await _storeRepository.getStore(
      reservation.storeSummary.id,
    );

    return storeResult.fold(
      (error) {
        _logger.w(
          '가격 계산을 위한 Store 조회 실패 — storeId: ${reservation.storeSummary.id}',
          error: error,
        );
        return left(error);
      },
      (store) {
        if (store == null) return right(reservation);

        final priceSetting = store.priceSettingForSpace(
          reservation.spaceOptionId,
        );
        if (priceSetting == null) return right(reservation);

        final calculatedPrice = priceSetting.calculatePrice(
          start: reservation.startTime,
          end: reservation.endTime,
          headCount: reservation.headCount,
          isAllDay: reservation.isAllDay,
          isHoliday: (date) => false, // TODO: 공휴일 API 연동 후 실제 판단 로직 전달
        );

        return right(
          reservation.copyWith(
            calculatedPrice: calculatedPrice,
            totalPrice: calculatedPrice + reservation.priceAdjustment,
          ),
        );
      },
    );
  }
```

```dart
// 신규
  Future<Either<Exception, Reservation>> _applyCalculatedPrice(
    Reservation reservation,
  ) async {
    final storeResult = await _storeRepository.getStore(
      reservation.storeSummary.id,
    );

    return storeResult.fold(
      (error) {
        _logger.w(
          '가격 계산을 위한 Store 조회 실패 — storeId: ${reservation.storeSummary.id}',
          error: error,
        );
        return left(error);
      },
      (store) async {
        if (store == null) return right(reservation);

        final priceSetting = store.priceSettingForSpace(
          reservation.spaceOptionId,
        );
        if (priceSetting == null) return right(reservation);

        // 예약 기간의 공휴일 Set을 미리 비동기로 조회한 뒤, 그 Set을 캡처하는
        // 동기 콜백을 calculatePrice에 전달한다. 조회 실패 시 빈 Set(=공휴일 없음)으로
        // 조용히 폴백한다 (HolidayException.isSilentable=true, Global Constraints 참고).
        final holidaysResult = await _holidayRepository.getHolidaysInRange(
          start: reservation.startTime,
          end: reservation.endTime,
        );
        final holidays = holidaysResult.getOrElse((_) => <DateTime>{});

        final calculatedPrice = priceSetting.calculatePrice(
          start: reservation.startTime,
          end: reservation.endTime,
          headCount: reservation.headCount,
          isAllDay: reservation.isAllDay,
          isHoliday: (date) =>
              holidays.contains(DateTime(date.year, date.month, date.day)),
        );

        return right(
          reservation.copyWith(
            calculatedPrice: calculatedPrice,
            totalPrice: calculatedPrice + reservation.priceAdjustment,
          ),
        );
      },
    );
  }
```

> **주의:** `fold`의 두 번째 분기가 `async`로 바뀌면서 전체 `fold` 호출의 반환 타입이 `Future<Either<...>>`가 되므로, 첫 번째 분기(`(error) { ... return left(error); }`)도 `Future<Either<Exception, Reservation>>`을 반환하도록 `Future.value(left(error))`로 감싸야 컴파일된다 (fold의 두 콜백은 동일한 반환 타입 `C`를 가져야 함 — #15 PR의 다른 태스크에서 이미 사용한 패턴, `auth_use_case.dart`의 `delete()` 참고). 실제로 적용할 때는 첫 번째 분기도 다음과 같이 고칠 것:
> ```dart
> (error) {
>   _logger.w(...);
>   return Future.value(left(error));
> },
> ```

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

### Task 5: 프레젠테이션 계층 holidaysInRangeProvider

**Files:**
- Create: `lib/presentation/providers/holidays_in_range_provider.dart`
- Test: `test/presentation/providers/holidays_in_range_provider_test.dart`

**Interfaces:**
- Consumes: `HolidayUseCase.getHolidaysInRange({required DateTime start, required DateTime end}) → Future<Either<Exception, Set<DateTime>>>` (Task 3), `holidayUseCaseProvider`
- Produces: `@riverpod Future<Set<DateTime>> holidaysInRange(Ref ref, DateTime start, DateTime end)` → `holidaysInRangeProvider(start, end)` (Task 6, 7에서 `ref.read(holidaysInRangeProvider(start, end).future)`로 사용)

- [ ] **Step 1: 실패하는 테스트 작성**

`test/presentation/providers/holidays_in_range_provider_test.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/domain/use_cases/holiday_use_case.dart';
import 'package:studio_chance/domain/use_cases/holiday_use_case_provider.dart';
import 'package:studio_chance/presentation/providers/holidays_in_range_provider.dart';

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

  test('UseCase가 반환한 Set을 그대로 반환한다', () async {
    when(
      () => mockUseCase.getHolidaysInRange(
        start: DateTime(2026, 3, 1),
        end: DateTime(2026, 3, 2),
      ),
    ).thenAnswer((_) async => right({DateTime(2026, 3, 1)}));
    final container = createContainer();
    addTearDown(container.dispose);

    final provider = holidaysInRangeProvider(DateTime(2026, 3, 1), DateTime(2026, 3, 2));
    final sub = container.listen(provider, (_, _) {});
    addTearDown(sub.close);
    final result = await container.read(provider.future);

    expect(result, {DateTime(2026, 3, 1)});
  });

  test('UseCase가 Left를 반환하면 빈 Set으로 폴백한다', () async {
    when(
      () => mockUseCase.getHolidaysInRange(
        start: DateTime(2026, 3, 1),
        end: DateTime(2026, 3, 2),
      ),
    ).thenAnswer((_) async => left(Exception('실패')));
    final container = createContainer();
    addTearDown(container.dispose);

    final provider = holidaysInRangeProvider(DateTime(2026, 3, 1), DateTime(2026, 3, 2));
    final sub = container.listen(provider, (_, _) {});
    addTearDown(sub.close);
    final result = await container.read(provider.future);

    expect(result, isEmpty);
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `flutter test test/presentation/providers/holidays_in_range_provider_test.dart`
Expected: FAIL — `Error: Target of URI doesn't exist: 'package:studio_chance/presentation/providers/holidays_in_range_provider.dart'`

- [ ] **Step 3: holidaysInRangeProvider 구현**

`lib/presentation/providers/holidays_in_range_provider.dart`:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studio_chance/domain/use_cases/holiday_use_case_provider.dart';

part 'holidays_in_range_provider.g.dart';

/// [start] 이상 [end] 미만 범위의 공휴일 날짜 Set을 반환한다. 조회 실패 시 빈 Set으로 폴백한다.
@riverpod
Future<Set<DateTime>> holidaysInRange(
  Ref ref,
  DateTime start,
  DateTime end,
) async {
  final useCase = ref.watch(holidayUseCaseProvider);
  final result = await useCase.getHolidaysInRange(start: start, end: end);
  return result.getOrElse((_) => <DateTime>{});
}
```

- [ ] **Step 4: 코드 생성**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: `lib/presentation/providers/holidays_in_range_provider.g.dart` 생성됨

- [ ] **Step 5: 테스트 통과 확인**

Run: `flutter test test/presentation/providers/holidays_in_range_provider_test.dart`
Expected: PASS (2 tests)

- [ ] **Step 6: 커밋**

```bash
git add lib/presentation/providers/holidays_in_range_provider.dart lib/presentation/providers/holidays_in_range_provider.g.dart test/presentation/providers/holidays_in_range_provider_test.dart
git commit -m "feat: #XX - holidaysInRangeProvider 추가"
```

---

### Task 6: ReservationCreateModal 연동

**Files:**
- Modify: `lib/presentation/home/widgets/three_day_calendar/reservation_create_modal.dart` (`_recalculatePrice()`, 현재 220행 부근 — #15 이후 정확한 줄 번호는 실제 파일에서 재확인할 것)

**Interfaces:**
- Consumes: `holidaysInRangeProvider(DateTime start, DateTime end) → Future<Set<DateTime>>` (Task 5)
- Produces: 없음 (UI 최종 소비 지점, 자동화 테스트 대상 아님 — 화면 레벨 수동 검증으로 대체)

이 모달은 `ConsumerStatefulWidget`이므로 `_recalculatePrice()`는 `ref`에 접근 가능하다. 기존 코드베이스는 "State 변경이 필요한 비동기 조회"를 `async/await`로 함수 시그니처를 바꾸는 대신, 같은 파일의 `_loadReservationCount()`처럼 `.then()` 콜백 + `if (!mounted) return;` 패턴을 쓴다(`reservation_detail_modal.dart`의 유사 패턴 참고). `_recalculatePrice()`는 여러 곳에서 `await` 없이 호출되므로, 시그니처를 유지한 채 내부만 비동기로 바꾸는 이 방식이 호출부 변경을 요구하지 않아 가장 안전하다.

- [ ] **Step 1: import 추가**

`lib/presentation/home/widgets/three_day_calendar/reservation_create_modal.dart` 상단에 추가:

```dart
import 'package:studio_chance/presentation/providers/holidays_in_range_provider.dart';
```

- [ ] **Step 2: `_recalculatePrice()` 교체**

```dart
// 기존 (#15 [C-1] 반영 후 현재 코드, 232행 부근)
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
      isHoliday: (date) => false, // TODO: 공휴일 API 연동 후 실제 판단 로직 전달
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
    ref.read(holidaysInRangeProvider(start, end).future).then((holidays) {
      if (!mounted) return;
      final price = priceSetting.calculatePrice(
        start: start,
        end: end,
        headCount: headCount,
        isAllDay: isAllDay,
        isHoliday: (date) =>
            holidays.contains(DateTime(date.year, date.month, date.day)),
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
- Modify: `lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart` (`initState`, `_recalculatePrice()`, `_applyInitialPrice()` — #15 이후 정확한 줄 번호는 실제 파일에서 재확인할 것. `_recalculatePrice()`는 현재 316행, `_applyInitialPrice()`는 334행, `isHoliday: (date) => false` TODO는 328/345행 부근)

**Interfaces:**
- Consumes: `holidaysInRangeProvider(DateTime start, DateTime end) → Future<Set<DateTime>>` (Task 5)
- Produces: 없음 (UI 최종 소비 지점)

`_applyInitialPrice()`는 "initState에서 setState 호출 불가"라는 이유로 존재하는 동기 함수이므로 그대로 둔다(첫 프레임에 즉시 대략적인 가격을 보여주는 역할, `isHoliday: (date) => false` 고정은 유지). 대신 `initState` 마지막에 `_recalculatePrice()`를 추가로 호출해 마운트 직후 공휴일 여부를 반영한 값으로 자동 보정한다.

- [ ] **Step 1: import 추가**

`lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart` 상단에 추가:

```dart
import 'package:studio_chance/presentation/providers/holidays_in_range_provider.dart';
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
// 기존 (#15 [C-1] 반영 후 현재 코드, 316행 부근)
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
      isHoliday: (date) => false, // TODO: 공휴일 API 연동 후 실제 판단 로직 전달
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
    ref.read(holidaysInRangeProvider(start, end).future).then((holidays) {
      if (!mounted) return;
      final price = priceSetting.calculatePrice(
        start: start,
        end: end,
        headCount: headCount,
        isAllDay: isAllDay,
        isHoliday: (date) =>
            holidays.contains(DateTime(date.year, date.month, date.day)),
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
