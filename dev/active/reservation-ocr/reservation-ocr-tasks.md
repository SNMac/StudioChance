# 예약 스크린샷 OCR — 태스크

Last Updated: 2026-05-23

---

## Phase 1 — 패키지 추가 및 플랫폼 설정 (S)

- [x] `pubspec.yaml`에 `firebase_ai: ^3.12.1` 추가
- [x] `pubspec.yaml`에 `image_picker: ^1.2.2` 추가
- [x] `flutter pub get` 실행
- [x] `ios/Runner/Info.plist`에 `NSPhotoLibraryUsageDescription` 추가
- [x] `ios/Podfile` — `platform :ios, '16.0'` 주석 해제
- [x] `ios/Podfile` — `FirebaseFirestore` 태그 `12.9.0` → `12.13.0` (cloud_firestore 6.4.1 호환)
- [x] `pod install` 완료
- [ ] Firebase Console에서 App Check 디버그 토큰 등록 (시뮬레이터 테스트 전 필수)

---

## Phase 2 — Domain 레이어 (S)

### ReservationOcrResult 엔티티
- [x] `lib/domain/entities/reservation_ocr_result.dart` 생성
  - `@freezed`, nullable 필드 (platform, customerName, customerPhone, startTime, endTime, isAllDay, headCount, memo)

### ReservationOcrRepository 인터페이스
- [x] `lib/domain/repository_interfaces/reservation_ocr_repository.dart` 생성

### ReservationOcrUseCase
- [x] `lib/domain/use_cases/reservation_ocr_use_case.dart` 생성
  - `const ReservationOcrUseCaseImpl` 구현체
- [x] `lib/domain/use_cases/reservation_ocr_use_case_provider.dart` 생성

---

## Phase 3 — Data 레이어 (M)

### OcrException 계층
- [x] `lib/common/exceptions/ocr_exceptions.dart` 생성
  - `OcrNetworkException`, `OcrParsingException`, `OcrUnknownException`

### ReservationOcrResultModel
- [x] `lib/data/models/reservation_ocr_result_model.dart` 생성
  - `_parsePlatform`: `raw.toString().toUpperCase()` (unsafe `as String` 캐스트 방지)
  - `_parseDateTimeNullable`: `DateTime.tryParse()`

### GeminiDataSource
- [x] `lib/data/data_sources/gemini_data_source.dart` 생성
  - 모델: `gemini-2.5-flash-lite` (초기 `gemini-2.0-flash`에서 변경)
  - `responseMimeType: 'application/json'` — Constrained Decoding
  - `systemInstruction` — Prompt Injection 방어 (마크다운 금지 규칙은 불필요하여 제거)
  - `_detectMimeType()` — magic bytes로 JPEG/PNG 자동 감지

### ReservationOcrRepositoryImpl
- [x] `lib/data/repositories/reservation_ocr_repository_impl.dart` 생성
  - switch expression으로 `OcrException` 타입 매핑 (`toException()` 헬퍼 미사용)

---

## Phase 4 — Presentation 레이어 (M)

### ReservationOcrController
- [x] `lib/presentation/providers/reservation_ocr_controller.dart` 생성
  - `FutureOr<ReservationOcrResult?> build()` → 초기값 `null`
  - `extractFromImage()`: image_picker → bytes → UseCase 호출

### 공통 컴포넌트 수정
- [x] `lib/presentation/commons/widgets/input_form/text_action_button.dart`
  - optional `fontWeight` 파라미터 추가

### 모달 수정
- [x] `reservation_create_modal.dart`
  - `TextActionButton(fontWeight: FontWeight.normal)` OCR 버튼 추가 (폼 최상단)
  - `ref.listen(reservationOcrControllerProvider, ...)` 추가
  - `_applyOcrResult()`: `.formattedPhone` 적용, `_recalculatePrice()` 호출
- [x] `reservation_detail_modal.dart`
  - 동일 작업 (편집 모드에서만 버튼 표시)

---

## Phase 5 — 빌드 및 검증 (S)

- [x] `dart run build_runner build --delete-conflicting-outputs`
- [x] `dart analyze` — 에러 없음 확인
- [ ] App Check 디버그 토큰 Firebase Console 등록
- [ ] 실기기 iOS — 갤러리 권한 요청 → 스크린샷 선택 → 폼 채우기 동작 확인
- [ ] 실기기 Android — 동일

---

## 검증 체크리스트

- [ ] 네이버 예약 스크린샷 → 예약자명/연락처/날짜/인원 자동 입력
- [ ] 스페이스클라우드 스크린샷 → 동일
- [ ] 야놀자 스크린샷 → 동일
- [ ] 추출 실패 필드는 기존 폼 값 유지 (null → 건너뜀)
- [ ] OCR 실패 시 에러 다이얼로그 표시
- [ ] OCR 처리 중 버튼 비활성화 ('분석 중...' 텍스트)
