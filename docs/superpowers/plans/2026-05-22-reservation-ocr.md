# Reservation OCR Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 예약 생성/수정 모달에 스크린샷 OCR 버튼을 추가해 Gemini 2.0 Flash로 예약 정보를 자동 추출한다.

**Architecture:** `image_picker`로 갤러리 이미지를 선택하고, `firebase_ai` 패키지를 통해 Gemini 2.0 Flash API에 이미지 bytes + 프롬프트를 전달한다. 응답 JSON은 `ReservationOcrResultModel`로 역직렬화 후 `ReservationOcrResult` 도메인 엔티티로 변환해 폼에 반영한다. Clean Architecture 레이어를 준수하며 `ReservationOcrController`가 이미지 선택과 UseCase 호출을 담당한다.

**Tech Stack:** Flutter/Dart, firebase_ai 3.12.1, image_picker 1.2.2, freezed, riverpod_generator, fpdart

---

## 파일 구조

### 신규 파일

| 파일 | 역할 |
|------|------|
| `lib/common/exceptions/ocr_exceptions.dart` | OCR 관련 sealed 예외 클래스 |
| `lib/domain/entities/reservation_ocr_result.dart` | OCR 결과 엔티티 (`@freezed`, JSON 없음) |
| `lib/domain/repository_interfaces/reservation_ocr_repository.dart` | Repository 인터페이스 |
| `lib/domain/use_cases/reservation_ocr_use_case.dart` | UseCase interface + impl |
| `lib/domain/use_cases/reservation_ocr_use_case_provider.dart` | DI 배선 (`@riverpod`) |
| `lib/data/models/reservation_ocr_result_model.dart` | JSON 역직렬화 모델 (`@freezed` + `fromJson`) |
| `lib/data/data_sources/gemini_data_source.dart` | Gemini API 호출 DataSource |
| `lib/data/repositories/reservation_ocr_repository_impl.dart` | Repository 구현체 |
| `lib/presentation/providers/reservation_ocr_controller.dart` | 이미지 선택 + OCR 실행 Controller |

### 수정 파일

| 파일 | 변경 내용 |
|------|-----------|
| `pubspec.yaml` | `firebase_ai`, `image_picker` 추가 |
| `ios/Runner/Info.plist` | `NSPhotoLibraryUsageDescription` 추가 |
| `lib/presentation/home/widgets/three_day_calendar/reservation_create_modal.dart` | OCR 버튼 + `ref.listen` + `_applyOcrResult` |
| `lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart` | OCR 버튼(편집 모드) + `ref.listen` + `_applyOcrResult` |

---

## Task 1: 패키지 추가 및 플랫폼 설정

**Files:**
- Modify: `pubspec.yaml`
- Modify: `ios/Runner/Info.plist`

- [ ] **Step 1: pubspec.yaml에 패키지 추가**

`pubspec.yaml`의 `firebase_messaging: ^16.1.3` 다음 줄에 아래 두 줄을 추가한다:

```yaml
  firebase_ai: ^3.12.1
  image_picker: ^1.2.2
```

결과적으로 해당 섹션:
```yaml
  firebase_messaging: ^16.1.3
  firebase_ai: ^3.12.1
  image_picker: ^1.2.2
  intl: ^0.20.2
```

- [ ] **Step 2: flutter pub get 실행**

```bash
flutter pub get
```

Expected: `Resolving dependencies...` 후 성공 메시지. 에러 없음.

- [ ] **Step 3: iOS Info.plist에 사진 라이브러리 권한 추가**

`ios/Runner/Info.plist`의 닫는 `</dict>` 바로 앞(마지막 `UISupportedInterfaceOrientations~ipad` 배열 닫는 `</array>` 다음)에 추가:

```xml
	<key>NSPhotoLibraryUsageDescription</key>
	<string>예약 스크린샷을 불러오려면 사진 라이브러리 접근 권한이 필요합니다.</string>
```

- [ ] **Step 4: Firebase Console Vertex AI 활성화 확인 (수동)**

Firebase Console → 프로젝트 선택 → 빌드 → Vertex AI for Firebase 섹션이 활성화되어 있는지 확인한다.
활성화되어 있지 않으면 'Vertex AI for Firebase 시작하기' 버튼을 클릭해 활성화한다.

---

## Task 2: OCR 예외 클래스 생성

**Files:**
- Create: `lib/common/exceptions/ocr_exceptions.dart`

- [ ] **Step 1: ocr_exceptions.dart 생성**

```dart
import 'package:studio_chance/common/exceptions/app_exception.dart';

/// OCR 관련 최상위 예외
sealed class OcrException extends AppException {
  OcrException(super.message, {super.code});

  @override
  String get title => switch (this) {
    OcrNetworkException() => '네트워크 에러가 발생했습니다',
    OcrParsingException() => 'OCR 분석 실패',
    OcrUnknownException() => '에러가 발생했습니다',
  };

  @override
  String get content => switch (this) {
    OcrNetworkException() => '인터넷 연결 상태를 확인해주세요.',
    OcrParsingException() =>
      '스크린샷에서 예약 정보를 인식하지 못했습니다.\n수동으로 입력해 주세요.',
    OcrUnknownException() =>
      '일시적인 에러가 발생했습니다.\n잠시 후 다시 시도해 주세요.',
  };
}

class OcrNetworkException extends OcrException {
  OcrNetworkException(super.message, {super.code});
}

class OcrParsingException extends OcrException {
  OcrParsingException(super.message, {super.code});
}

class OcrUnknownException extends OcrException {
  OcrUnknownException(super.message, {super.code});
}
```

---

## Task 3: Domain Entity 생성

**Files:**
- Create: `lib/domain/entities/reservation_ocr_result.dart`

- [ ] **Step 1: reservation_ocr_result.dart 생성**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:studio_chance/domain/enums/reservation_platform.dart';

part 'reservation_ocr_result.freezed.dart';

@freezed
abstract class ReservationOcrResult with _$ReservationOcrResult {
  const factory ReservationOcrResult({
    ReservationPlatform? platform,
    String? customerName,
    String? customerPhone,
    DateTime? startTime,
    DateTime? endTime,
    bool? isAllDay,
    int? headCount,
    String? memo,
  }) = _ReservationOcrResult;
}
```

- [ ] **Step 2: build_runner 실행으로 freezed 코드 생성**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: `reservation_ocr_result.freezed.dart` 생성됨. 에러 없음.

- [ ] **Step 3: 커밋**

```bash
git add lib/domain/entities/reservation_ocr_result.dart lib/domain/entities/reservation_ocr_result.freezed.dart
git commit -m "feat: #10 - ReservationOcrResult 도메인 엔티티 추가"
```

---

## Task 4: Repository Interface + UseCase 생성

**Files:**
- Create: `lib/domain/repository_interfaces/reservation_ocr_repository.dart`
- Create: `lib/domain/use_cases/reservation_ocr_use_case.dart`

- [ ] **Step 1: reservation_ocr_repository.dart 생성**

```dart
import 'dart:typed_data';
import 'package:fpdart/fpdart.dart';
import 'package:studio_chance/domain/entities/reservation_ocr_result.dart';

abstract interface class ReservationOcrRepository {
  Future<Either<Exception, ReservationOcrResult>> analyzeReservationImage(
    Uint8List imageBytes,
  );
}
```

- [ ] **Step 2: reservation_ocr_use_case.dart 생성**

```dart
import 'dart:typed_data';
import 'package:fpdart/fpdart.dart';
import 'package:studio_chance/domain/entities/reservation_ocr_result.dart';
import 'package:studio_chance/domain/repository_interfaces/reservation_ocr_repository.dart';

abstract interface class ReservationOcrUseCase {
  Future<Either<Exception, ReservationOcrResult>> execute(Uint8List imageBytes);
}

class ReservationOcrUseCaseImpl implements ReservationOcrUseCase {
  final ReservationOcrRepository _repository;

  ReservationOcrUseCaseImpl({required ReservationOcrRepository repository})
      : _repository = repository;

  @override
  Future<Either<Exception, ReservationOcrResult>> execute(
    Uint8List imageBytes,
  ) {
    return _repository.analyzeReservationImage(imageBytes);
  }
}
```

- [ ] **Step 3: 커밋**

```bash
git add lib/domain/repository_interfaces/reservation_ocr_repository.dart \
        lib/domain/use_cases/reservation_ocr_use_case.dart
git commit -m "feat: #10 - ReservationOcrUseCase 및 Repository 인터페이스 추가"
```

---

## Task 5: UseCase Provider 생성

**Files:**
- Create: `lib/domain/use_cases/reservation_ocr_use_case_provider.dart`

이 파일은 data layer를 import하는 DI 배선 파일이다 (CLAUDE.md D5 결정 참조).

- [ ] **Step 1: reservation_ocr_use_case_provider.dart 생성**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studio_chance/data/repositories/reservation_ocr_repository_impl.dart';
import 'package:studio_chance/domain/use_cases/reservation_ocr_use_case.dart';

part 'reservation_ocr_use_case_provider.g.dart';

@riverpod
ReservationOcrUseCase reservationOcrUseCase(Ref ref) {
  return ReservationOcrUseCaseImpl(
    repository: ref.watch(reservationOcrRepositoryProvider),
  );
}
```

이 파일은 `reservation_ocr_repository_impl.dart`가 생성된 후 코드 생성이 완료되어야 컴파일된다. 지금은 파일만 작성하고 Task 8 완료 후 build_runner를 실행한다.

---

## Task 6: Data Model 생성

**Files:**
- Create: `lib/data/models/reservation_ocr_result_model.dart`

- [ ] **Step 1: reservation_ocr_result_model.dart 생성**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:studio_chance/domain/entities/reservation_ocr_result.dart';
import 'package:studio_chance/domain/enums/reservation_platform.dart';

part 'reservation_ocr_result_model.freezed.dart';
part 'reservation_ocr_result_model.g.dart';

DateTime? _parseDateTimeNullable(Object? value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

ReservationPlatform? _parsePlatform(Object? raw) {
  if (raw == null) return null;
  return switch ((raw as String).toUpperCase()) {
    'NAVER' => ReservationPlatform.naver,
    'SPACECLOUD' => ReservationPlatform.spaceCloud,
    'YANOLJA' => ReservationPlatform.yanolja,
    _ => ReservationPlatform.other,
  };
}

@freezed
abstract class ReservationOcrResultModel with _$ReservationOcrResultModel {
  const ReservationOcrResultModel._();

  const factory ReservationOcrResultModel({
    @JsonKey(name: 'platform', fromJson: _parsePlatform)
    ReservationPlatform? platform,
    String? customerName,
    String? customerPhone,
    @JsonKey(fromJson: _parseDateTimeNullable) DateTime? startTime,
    @JsonKey(fromJson: _parseDateTimeNullable) DateTime? endTime,
    bool? isAllDay,
    int? headCount,
    String? memo,
  }) = _ReservationOcrResultModel;

  factory ReservationOcrResultModel.fromJson(Map<String, dynamic> json) =>
      _$ReservationOcrResultModelFromJson(json);

  ReservationOcrResult toEntity() {
    return ReservationOcrResult(
      platform: platform,
      customerName: customerName,
      customerPhone: customerPhone,
      startTime: startTime,
      endTime: endTime,
      isAllDay: isAllDay,
      headCount: headCount,
      memo: memo,
    );
  }
}
```

- [ ] **Step 2: build_runner 실행**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: `reservation_ocr_result_model.freezed.dart`, `reservation_ocr_result_model.g.dart` 생성됨.

- [ ] **Step 3: 커밋**

```bash
git add lib/data/models/reservation_ocr_result_model.dart \
        lib/data/models/reservation_ocr_result_model.freezed.dart \
        lib/data/models/reservation_ocr_result_model.g.dart
git commit -m "feat: #10 - ReservationOcrResultModel 추가"
```

---

## Task 7: Gemini DataSource 생성

**Files:**
- Create: `lib/data/data_sources/gemini_data_source.dart`

- [ ] **Step 1: gemini_data_source.dart 생성**

```dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studio_chance/data/models/reservation_ocr_result_model.dart';

part 'gemini_data_source.g.dart';

abstract interface class GeminiDataSource {
  Future<ReservationOcrResultModel> analyzeReservationImage(
    Uint8List imageBytes,
  );
}

class GeminiDataSourceImpl implements GeminiDataSource {
  late final GenerativeModel _model;

  GeminiDataSourceImpl() {
    _model = FirebaseAI.vertexAI().generativeModel(
      model: 'gemini-2.0-flash',
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      ),
    );
  }

  static const _prompt = '''이 이미지는 공간 예약 플랫폼의 예약 확인 스크린샷입니다.
다음 JSON 형식으로 예약 정보를 추출하세요.
추출할 수 없는 값은 null로 반환하세요.

{
  "platform": "NAVER | SPACECLOUD | YANOLJA | OTHER",
  "customerName": "예약자 이름",
  "customerPhone": "숫자만 (예: 01012345678)",
  "startTime": "ISO 8601 (예: 2026-05-22T14:00:00)",
  "endTime": "ISO 8601 또는 null",
  "isAllDay": false,
  "headCount": 2,
  "memo": "요청사항 또는 null"
}''';

  @override
  Future<ReservationOcrResultModel> analyzeReservationImage(
    Uint8List imageBytes,
  ) async {
    final response = await _model.generateContent([
      Content.multi([
        InlineDataPart('image/jpeg', imageBytes),
        TextPart(_prompt),
      ]),
    ]);
    final jsonString = response.text ?? '{}';
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return ReservationOcrResultModel.fromJson(json);
  }
}

@Riverpod(keepAlive: true)
GeminiDataSource geminiDataSource(Ref ref) {
  return GeminiDataSourceImpl();
}
```

- [ ] **Step 2: build_runner 실행**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: `gemini_data_source.g.dart` 생성됨.

- [ ] **Step 3: 커밋**

```bash
git add lib/data/data_sources/gemini_data_source.dart \
        lib/data/data_sources/gemini_data_source.g.dart
git commit -m "feat: #10 - GeminiDataSource 추가"
```

---

## Task 8: Repository Implementation 생성

**Files:**
- Create: `lib/data/repositories/reservation_ocr_repository_impl.dart`

- [ ] **Step 1: reservation_ocr_repository_impl.dart 생성**

```dart
import 'dart:typed_data';
import 'package:fpdart/fpdart.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studio_chance/common/utils/exception_utils.dart';
import 'package:studio_chance/data/data_sources/gemini_data_source.dart';
import 'package:studio_chance/domain/entities/reservation_ocr_result.dart';
import 'package:studio_chance/domain/repository_interfaces/reservation_ocr_repository.dart';

part 'reservation_ocr_repository_impl.g.dart';

class ReservationOcrRepositoryImpl implements ReservationOcrRepository {
  final Logger _logger = Logger();
  final GeminiDataSource _geminiDataSource;

  ReservationOcrRepositoryImpl({required GeminiDataSource geminiDataSource})
      : _geminiDataSource = geminiDataSource;

  @override
  Future<Either<Exception, ReservationOcrResult>> analyzeReservationImage(
    Uint8List imageBytes,
  ) async {
    try {
      final model = await _geminiDataSource.analyzeReservationImage(imageBytes);
      return right(model.toEntity());
    } catch (e) {
      _logger.e('OCR 분석 실패', error: e);
      return left(toException(e));
    }
  }
}

@Riverpod(keepAlive: true)
ReservationOcrRepository reservationOcrRepository(Ref ref) {
  return ReservationOcrRepositoryImpl(
    geminiDataSource: ref.watch(geminiDataSourceProvider),
  );
}
```

- [ ] **Step 2: build_runner 전체 실행 (UseCase Provider 포함)**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: `reservation_ocr_repository_impl.g.dart`, `reservation_ocr_use_case_provider.g.dart` 생성됨. 에러 없음.

- [ ] **Step 3: dart analyze 실행**

```bash
dart analyze
```

Expected: 에러 없음. 경고도 없어야 한다.

- [ ] **Step 4: 커밋**

```bash
git add lib/data/repositories/reservation_ocr_repository_impl.dart \
        lib/data/repositories/reservation_ocr_repository_impl.g.dart \
        lib/domain/use_cases/reservation_ocr_use_case_provider.dart \
        lib/domain/use_cases/reservation_ocr_use_case_provider.g.dart
git commit -m "feat: #10 - ReservationOcrRepository 구현체 및 UseCase Provider 추가"
```

---

## Task 9: OCR Controller 생성

**Files:**
- Create: `lib/presentation/providers/reservation_ocr_controller.dart`

- [ ] **Step 1: reservation_ocr_controller.dart 생성**

```dart
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studio_chance/domain/entities/reservation_ocr_result.dart';
import 'package:studio_chance/domain/use_cases/reservation_ocr_use_case_provider.dart';

part 'reservation_ocr_controller.g.dart';

@riverpod
class ReservationOcrController extends _$ReservationOcrController {
  final _logger = Logger();
  final _picker = ImagePicker();

  @override
  FutureOr<ReservationOcrResult?> build() => null;

  Future<void> extractFromImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;

    state = const AsyncLoading();
    final bytes = await picked.readAsBytes();
    final result =
        await ref.read(reservationOcrUseCaseProvider).execute(bytes);
    result.fold(
      (e) {
        _logger.e('OCR 실패', error: e);
        state = AsyncError(e, StackTrace.current);
      },
      (ocrResult) => state = AsyncData(ocrResult),
    );
  }
}
```

- [ ] **Step 2: build_runner 실행**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: `reservation_ocr_controller.g.dart` 생성됨.

- [ ] **Step 3: 커밋**

```bash
git add lib/presentation/providers/reservation_ocr_controller.dart \
        lib/presentation/providers/reservation_ocr_controller.g.dart
git commit -m "feat: #10 - ReservationOcrController 추가"
```

---

## Task 10: Create Modal 수정

**Files:**
- Modify: `lib/presentation/home/widgets/three_day_calendar/reservation_create_modal.dart`

- [ ] **Step 1: import 추가**

파일 상단 import 목록 끝에 아래를 추가한다:

```dart
import 'package:studio_chance/common/exceptions/app_exception.dart';
import 'package:studio_chance/domain/entities/reservation_ocr_result.dart';
import 'package:studio_chance/presentation/commons/widgets/custom_alert_dialog.dart';
import 'package:studio_chance/presentation/providers/reservation_ocr_controller.dart';
```

- [ ] **Step 2: `_applyOcrResult` 메서드 추가**

`_ReservationCreateModalState` 클래스의 `_recalculatePrice()` 메서드 다음에 추가:

```dart
  void _applyOcrResult(ReservationOcrResult result) {
    setState(() {
      if (result.customerName != null) {
        _nameController.text = result.customerName!;
      }
      if (result.customerPhone != null) {
        _phoneController.text = result.customerPhone!;
      }
      if (result.headCount != null) {
        _headCountController.text = result.headCount.toString();
      }
      if (result.startTime != null) _startTime = result.startTime!;
      if (result.endTime != null) _endTime = result.endTime!;
      if (result.isAllDay != null) _isAllDay = result.isAllDay!;
      if (result.platform != null) _platform = result.platform!;
      if (result.memo != null) _memoController.text = result.memo!;
    });
    _recalculatePrice();
  }
```

- [ ] **Step 3: `build()` 최상단에 `ref.listen` 추가**

`build()` 메서드의 `final textTheme = ...` 줄 앞에 추가:

```dart
    ref.listen(reservationOcrControllerProvider, (_, next) {
      next.whenOrNull(
        data: (result) {
          if (result != null && mounted) _applyOcrResult(result);
        },
        error: (e, _) {
          if (!mounted) return;
          if (e is AppException && !e.isSilentable) {
            showCustomAlertDialog(
              context: context,
              title: e.title,
              content: e.content,
              showCancel: false,
            );
          } else {
            showCustomAlertDialog(
              context: context,
              title: 'OCR 오류',
              content: '스크린샷 분석에 실패했습니다.\n잠시 후 다시 시도해 주세요.',
              showCancel: false,
            );
          }
        },
      );
    });
```

- [ ] **Step 4: OCR 버튼 추가**

`_buildBody()` 메서드의 `Column`의 `children` 목록 맨 앞에 추가:

```dart
          _buildOcrButton(),
```

결과적으로:
```dart
      child: Column(
        spacing: 20,
        children: [
          _buildOcrButton(),
          _buildSection1(),
          _buildSection2(),
          _buildSection3(),
          _buildSection4(textTheme),
        ],
```

- [ ] **Step 5: `_buildOcrButton()` 메서드 추가**

`_buildBody()` 메서드 다음에 추가:

```dart
  Widget _buildOcrButton() {
    final isLoading = ref.watch(
      reservationOcrControllerProvider.select((s) => s.isLoading),
    );
    return OutlinedButton.icon(
      onPressed: isLoading
          ? null
          : () => ref
              .read(reservationOcrControllerProvider.notifier)
              .extractFromImage(),
      icon: isLoading
          ? const SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.image_outlined),
      label: Text(isLoading ? '분석 중...' : '스크린샷으로 자동 입력'),
    );
  }
```

- [ ] **Step 6: dart analyze 실행**

```bash
dart analyze lib/presentation/home/widgets/three_day_calendar/reservation_create_modal.dart
```

Expected: 에러 없음.

- [ ] **Step 7: 커밋**

```bash
git add lib/presentation/home/widgets/three_day_calendar/reservation_create_modal.dart
git commit -m "feat: #10 - 예약 생성 모달에 OCR 버튼 추가"
```

---

## Task 11: Detail Modal 수정

**Files:**
- Modify: `lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart`

- [ ] **Step 1: import 추가**

파일 상단 import 목록 끝에 아래를 추가한다:

```dart
import 'package:studio_chance/common/exceptions/app_exception.dart';
import 'package:studio_chance/domain/entities/reservation_ocr_result.dart';
import 'package:studio_chance/presentation/commons/widgets/custom_alert_dialog.dart';
import 'package:studio_chance/presentation/providers/reservation_ocr_controller.dart';
```

- [ ] **Step 2: `_applyOcrResult` 메서드 추가**

`_ReservationDetailModalState` 클래스 내 기존 메서드들(예: `_syncScrollPosition` 또는 `_initFields`) 다음에 추가:

```dart
  void _applyOcrResult(ReservationOcrResult result) {
    setState(() {
      if (result.customerName != null) {
        _nameController.text = result.customerName!;
      }
      if (result.customerPhone != null) {
        _phoneController.text = result.customerPhone!;
      }
      if (result.headCount != null) {
        _headCountController.text = result.headCount.toString();
      }
      if (result.startTime != null) _startTime = result.startTime!;
      if (result.endTime != null) _endTime = result.endTime!;
      if (result.isAllDay != null) _isAllDay = result.isAllDay!;
      if (result.platform != null) _platform = result.platform!;
      if (result.memo != null) _memoController.text = result.memo!;
    });
  }
```

- [ ] **Step 3: `build()` 최상단에 `ref.listen` 추가**

detail modal의 `build()` 메서드 최상단(첫 번째 `ref.watch` 또는 `return` 전)에 추가:

```dart
    ref.listen(reservationOcrControllerProvider, (_, next) {
      next.whenOrNull(
        data: (result) {
          if (result != null && mounted) _applyOcrResult(result);
        },
        error: (e, _) {
          if (!mounted) return;
          if (e is AppException && !e.isSilentable) {
            showCustomAlertDialog(
              context: context,
              title: e.title,
              content: e.content,
              showCancel: false,
            );
          } else {
            showCustomAlertDialog(
              context: context,
              title: 'OCR 오류',
              content: '스크린샷 분석에 실패했습니다.\n잠시 후 다시 시도해 주세요.',
              showCancel: false,
            );
          }
        },
      );
    });
```

- [ ] **Step 4: `_buildEditBody()` Column children 맨 앞에 OCR 버튼 추가**

`reservation_detail_modal.dart`의 `_buildEditBody()` 메서드(약 line 595)의 Column children 첫 번째 항목으로 `_buildOcrButton()`을 추가한다:

```dart
  Widget _buildEditBody(TextTheme textTheme) {
    return SafeAreaWithPadding(
      top: false,
      padding: const EdgeInsetsDirectional.fromSTEB(
        horizontalPadding,
        16,
        horizontalPadding,
        32,
      ),
      child: Column(
        spacing: 20,
        children: [
          _buildOcrButton(),      // 추가
          _buildSection1Edit(),
          _buildSection2Edit(),
          _buildSection3Edit(),
          _buildSection4Edit(textTheme),
          // ... (기존 나머지 children 유지)
```

- [ ] **Step 5: `_buildOcrButton()` 메서드 추가**

```dart
  Widget _buildOcrButton() {
    final isLoading = ref.watch(
      reservationOcrControllerProvider.select((s) => s.isLoading),
    );
    return OutlinedButton.icon(
      onPressed: isLoading
          ? null
          : () => ref
              .read(reservationOcrControllerProvider.notifier)
              .extractFromImage(),
      icon: isLoading
          ? const SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.image_outlined),
      label: Text(isLoading ? '분석 중...' : '스크린샷으로 자동 입력'),
    );
  }
```

- [ ] **Step 6: dart analyze 실행**

```bash
dart analyze lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart
```

Expected: 에러 없음.

- [ ] **Step 7: 커밋**

```bash
git add lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart
git commit -m "feat: #10 - 예약 수정 모달에 OCR 버튼 추가 (편집 모드)"
```

---

## Task 12: 최종 빌드 및 검증

- [ ] **Step 1: 전체 build_runner 실행**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: 에러 없음. 새로운 `.g.dart`, `.freezed.dart` 파일 생성됨.

- [ ] **Step 2: dart analyze 전체 실행**

```bash
dart analyze
```

Expected: 에러 0건.

- [ ] **Step 3: iOS 실기기 테스트 — 예약 생성 모달**

1. iOS 실기기에서 앱 실행
2. 홈 화면 → 예약 생성 모달 열기
3. '스크린샷으로 자동 입력' 버튼 탭
4. 사진 라이브러리 권한 요청 다이얼로그 → 허용
5. 네이버 예약 확인 스크린샷 선택
6. 로딩 인디케이터 표시 확인
7. 폼 필드(이름, 연락처, 날짜, 인원, 플랫폼) 자동 입력 확인
8. 추출 안 된 필드는 기존값 유지 확인

- [ ] **Step 4: iOS 실기기 테스트 — OCR 실패 케이스**

1. 예약과 무관한 이미지(예: 풍경 사진) 선택
2. 에러 다이얼로그 표시 확인 (OCR 분석 실패 메시지)

- [ ] **Step 5: iOS 실기기 테스트 — 예약 수정 모달**

1. 기존 예약 탭 → 상세 모달 열기
2. '편집' 버튼 탭 → 편집 모드 진입
3. '스크린샷으로 자동 입력' 버튼 표시 확인
4. 스크린샷 선택 → 폼 자동 입력 확인

- [ ] **Step 6: Android 실기기 테스트**

1. Android 실기기에서 앱 실행
2. 예약 생성 모달 → 스크린샷 선택 → 폼 자동 입력 확인
3. (Android API 33 미만이면 스토리지 권한 다이얼로그 확인)

- [ ] **Step 7: 최종 커밋**

```bash
git add -u
git commit -m "feat: #10 - 예약 스크린샷 OCR 기능 구현 완료"
```

---

## 검증 체크리스트

- [ ] 갤러리에서 스크린샷 선택 가능 (iOS/Android)
- [ ] 네이버 예약 스크린샷 → 예약자명/연락처/날짜/인원 자동 입력
- [ ] 스페이스클라우드 스크린샷 → 동일
- [ ] 야놀자 스크린샷 → 동일
- [ ] 추출 실패 필드는 기존 폼 값 유지 (null → 건너뜀)
- [ ] OCR 실패 시 에러 다이얼로그 표시
- [ ] OCR 처리 중 로딩 인디케이터 표시
- [ ] `dart analyze` 에러 없음
