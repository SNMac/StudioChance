# 예약 스크린샷 OCR — 구현 계획

Last Updated: 2026-05-22

## Executive Summary

예약 생성/수정 폼 최상단에 스크린샷 불러오기 버튼을 추가한다.
사용자가 네이버 예약·스페이스클라우드·야놀자 예약 스크린샷을 선택하면
`firebase_ai` 패키지를 통해 Gemini 2.5 Flash Lite API가 이미지를 분석하고,
추출된 예약 정보를 폼 필드에 자동으로 채워준다.

> **구현 완료** — 실제 구현은 `reservation-ocr-context.md` 참고. 아래 내용은 초기 계획 기록용.

관련 이슈: #10

---

## Current State Analysis

### 폼 구조

| 모달 | 파일 | 상태 관리 |
|------|------|----------|
| 예약 생성 | `reservation_create_modal.dart` | `ConsumerStatefulWidget` 내부 state |
| 예약 수정 | `reservation_detail_modal.dart` | `ConsumerStatefulWidget` 내부 state |

두 모달 모두 `_initFields(Reservation r)`로 TextEditingController에 초기값을 세팅한다.
OCR 결과를 폼에 적용하려면 이 컨트롤러들을 직접 업데이트하면 된다.

### 추출 대상 필드

| Reservation 필드 | 타입 | 추출 가능 여부 |
|-----------------|------|--------------|
| `customerName` | `String` | ✅ |
| `customerPhone` | `String` | ✅ |
| `startTime` | `DateTime` | ✅ |
| `endTime` | `DateTime` | ✅ (스크린샷에 없으면 null) |
| `isAllDay` | `bool` | ✅ |
| `headCount` | `int` | ✅ |
| `platform` | `ReservationPlatform` | ✅ (이미지로 판별) |
| `memo` | `String` | △ (요청사항 있으면 추출) |
| `paymentMethod` | `PaymentMethod` | △ (명시된 경우만) |
| `status` | `ReservationStatus` | ✅ (확정/취소 등) |

### 미설치 패키지

- `firebase_ai: ^3.12.1` — Gemini API 호출 (firebase_vertexai 후속)
- `image_picker: ^1.2.2` — 갤러리 이미지 선택

---

## Proposed Future State

### 데이터 흐름

```
사용자: 스크린샷 선택 버튼 탭
        │
        ▼
image_picker → XFile (이미지)
        │
        ▼
ReservationOcrController.extractFromImage(XFile)
        │
        ▼
ReservationOcrUseCase.execute(imageBytes)
        │
        ▼
GeminiDataSource.analyzeReservationImage(imageBytes)
  → firebase_vertexai: Gemini 2.0 Flash API 호출
  → JSON 응답 파싱 → ReservationOcrResultModel
        │
        ▼
ReservationOcrResult (Domain Entity)
        │
        ▼
state = AsyncData(result)
        │
        ▼ ref.listen (모달)
폼 필드 자동 채우기 + 미추출 필드는 기존값 유지
```

### 아키텍처 파일 구조

```
lib/
├── data/
│   ├── data_sources/
│   │   └── gemini_data_source.dart          # Gemini API 호출
│   ├── models/
│   │   └── reservation_ocr_result_model.dart # JSON 역직렬화
│   └── repositories/
│       └── reservation_ocr_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── reservation_ocr_result.dart      # OCR 결과 엔티티
│   └── use_cases/
│       ├── reservation_ocr_use_case.dart    # interface + impl
│       └── reservation_ocr_use_case_provider.dart
└── presentation/
    └── providers/
        └── reservation_ocr_controller.dart  # 이미지 선택 + OCR 실행
```

### OCR 결과 엔티티

```dart
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

null 필드 = 추출 실패 → 폼의 기존값 유지.

### Gemini 프롬프트 설계

```
이 이미지는 공간 예약 플랫폼의 예약 확인 스크린샷입니다.
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
}
```

`responseMimeType: "application/json"`으로 JSON 강제 출력.

---

## Implementation Phases

### Phase 1 — 패키지 추가 및 플랫폼 설정 (S)

- `pubspec.yaml`에 `firebase_ai: ^3.12.1`, `image_picker: ^1.2.2` 추가
- iOS: `Info.plist`에 `NSPhotoLibraryUsageDescription` 추가
- Android: `AndroidManifest.xml` 권한 확인 (API 33+ 불필요, 미만은 READ_EXTERNAL_STORAGE)
- Firebase Console에서 Vertex AI for Firebase 활성화 확인

### Phase 2 — Domain 레이어 (S)

파일: `lib/domain/entities/reservation_ocr_result.dart`
- `@freezed` 엔티티 (JSON 없음)
- null 허용 필드로 부분 추출 지원

파일: `lib/domain/use_cases/reservation_ocr_use_case.dart`
- `ReservationOcrUseCase` 인터페이스
- `ReservationOcrUseCaseImpl` 구현체
- 반환: `Future<Either<Exception, ReservationOcrResult>>`

파일: `lib/domain/use_cases/reservation_ocr_use_case_provider.dart`
- `@riverpod ReservationOcrUseCase reservationOcrUseCase(Ref ref)`

### Phase 3 — Data 레이어 (M)

파일: `lib/data/models/reservation_ocr_result_model.dart`
- `@freezed` + `fromJson` 모델
- `toEntity()` 변환 메서드
- 날짜 파싱: `DateTime.tryParse()` 로 안전하게 처리

파일: `lib/data/data_sources/gemini_data_source.dart`
- `firebase_vertexai`로 Gemini 2.0 Flash 호출
- 모델: `gemini-2.0-flash`
- 이미지 bytes + 프롬프트 전송
- JSON 응답 파싱 → `ReservationOcrResultModel`
- `@Riverpod(keepAlive: true)` DataSource provider

파일: `lib/data/repositories/reservation_ocr_repository_impl.dart`
- try-catch → `left(toException(e))` 패턴
- `@Riverpod(keepAlive: true)` Repository provider

### Phase 4 — Presentation 레이어 (M)

파일: `lib/presentation/providers/reservation_ocr_controller.dart`
- `FutureOr<void> build()` AsyncNotifier
- `Future<void> extractFromImage()`: image_picker → OCR UseCase 호출
- 실패 시 `state = AsyncError(e, StackTrace.current)`

파일: `reservation_create_modal.dart`, `reservation_detail_modal.dart`
- 폼 최상단에 OCR 버튼 위젯 추가 (디자인 미정 — 임시 TextButton)
- `ref.listen(reservationOcrControllerProvider, ...)`:
  - `data`: `_applyOcrResult(result)` 호출
  - `error`: `showCustomAlertDialog` 호출
- `_applyOcrResult(ReservationOcrResult)`: null이 아닌 필드만 setState로 반영

### Phase 5 — 빌드 및 검증 (S)

- `dart run build_runner build --delete-conflicting-outputs`
- `dart analyze`
- 실기기에서 스크린샷 선택 → OCR → 폼 채우기 동작 확인

---

## Risk Assessment

| 위험 | 가능성 | 대응 |
|------|--------|------|
| Gemini가 날짜를 다양한 형식으로 반환 | 중간 | 프롬프트에 ISO 8601 명시 + `DateTime.tryParse()` |
| 스크린샷 레이아웃 변경 시 정확도 저하 | 낮음 | 모델 업그레이드(2.0→2.5)로 대응 |
| Firebase Console Vertex AI 미활성화 | 낮음 | Phase 1에서 선제 확인 |
| 이미지 용량이 커서 API 응답 지연 | 낮음 | `image_picker`의 `imageQuality: 85` 옵션으로 압축 |
| `endTime` 미기재 스크린샷 | 높음 | null 허용, 폼 기존값 유지 |

---

## Success Metrics

- [ ] 갤러리에서 스크린샷 선택 가능 (iOS/Android)
- [ ] 네이버 예약 스크린샷 → 예약자명/연락처/날짜/인원 자동 입력
- [ ] 스페이스클라우드 스크린샷 → 동일
- [ ] 야놀자 스크린샷 → 동일
- [ ] 추출 실패 필드는 기존 폼 값 유지
- [ ] OCR 실패 시 에러 다이얼로그 표시
- [ ] `dart analyze` 에러 없음
