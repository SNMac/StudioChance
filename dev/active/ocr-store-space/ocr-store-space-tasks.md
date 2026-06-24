# OCR 점포·공간 자동 선택 — 태스크

Last Updated: 2026-06-25

---

## Phase 1 — Domain + Data 레이어 (S) ✅ 완료

### ReservationOcrResult 엔티티
- [x] `lib/domain/entities/reservation_ocr_result.dart`
  - `String? storeName` 필드 추가 (기존 `memo` 뒤)
  - `String? spaceName` 필드 추가

### ReservationOcrResultModel
- [x] `lib/data/models/reservation_ocr_result_model.dart`
  - `String? storeName` 필드 추가
  - `String? spaceName` 필드 추가
  - `toEntity()` 에 `storeName: storeName, spaceName: spaceName` 추가

### GeminiDataSource 프롬프트 수정 (→ AI 기반 매칭으로 확장)
- [x] `lib/data/data_sources/gemini_data_source.dart`
  - 정적 `_prompt` → 동적 `_buildPrompt(Map<String, List<String>>? storeSpaceMap)` 메서드로 변경
  - storeSpaceMap 제공 시: 점포·공간 목록을 프롬프트에 포함, Gemini가 목록에서 정확한 이름 선택
  - storeSpaceMap 미제공 시: 기존 일반 텍스트 추출 방식으로 폴백
  - `analyzeReservationImage`에 `storeSpaceMap` 파라미터 추가

### storeSpaceMap 체인 관통
- [x] `lib/domain/repository_interfaces/reservation_ocr_repository.dart` — 파라미터 추가
- [x] `lib/data/repositories/reservation_ocr_repository_impl.dart` — 파라미터 전달
- [x] `lib/domain/use_cases/reservation_ocr_use_case.dart` — 파라미터 추가 및 전달
- [x] `lib/presentation/providers/reservation_ocr_controller.dart` — `analyzeImage`에 파라미터 추가

### 코드 생성
- [x] `dart run build_runner build --delete-conflicting-outputs`
  - `reservation_ocr_result.freezed.dart` 재생성 확인
  - `reservation_ocr_result_model.freezed.dart` 재생성 확인
  - `reservation_ocr_result_model.g.dart` 재생성 확인

---

## Phase 2 — Create Modal 수정 (M) ✅ 완료

파일: `lib/presentation/home/widgets/three_day_calendar/reservation_create_modal.dart`

### 상태 변수 추가
- [x] `String? _pendingSpaceNameFromOcr;` — 편집 상태 변수 섹션에 추가

### 헬퍼 메서드 추가 / 제거
- [x] `_showOcrUnmatchedAlert(List<String> unmatched)` 메서드 추가
- [x] `_nameMatches` 추가 후 제거 — AI가 정확한 이름 반환하므로 클라이언트 퍼지 매칭 불필요

### `_loadSpaceOptions` 수정 (via `_applySpaceOptions`)
- [x] 시그니처 변경: `void _loadSpaceOptions(String storeId, {List<String> ocrUnmatched = const []})`
- [x] `_applySpaceOptions`에 `ocrUnmatched` 파라미터 추가
- [x] `.then()` 콜백 내에서 `_pendingSpaceNameFromOcr` 정확 일치(==) 매칭
- [x] `_pendingSpaceNameFromOcr = null` 초기화
- [x] `_recalculatePrice()` 호출
- [x] `_showOcrUnmatchedAlert(unmatched)` 호출

### `_applyOcrResult` 전면 개편
- [x] 기존 필드 적용 유지 (customerName, customerPhone 등)
- [x] null 필드에 대해 `unmatched.add(...)` 추가 (예약자명, 연락처, 시작 시간)
- [x] storeName 매칭 로직: 정확 일치(==)
- [x] spaceName 처리: pending 패턴 및 즉시 매칭

### `_handleOcrButtonTap` 수정 (원계획 대비 개선)
- [x] 이미지 확정(confirm) 후 모든 점포 공간 옵션 병렬 조회
- [x] storeSpaceMap 구성 후 `analyzeImage(bytes, storeSpaceMap: ...)` 호출
  - 이미지 취소 시 조회 발생하지 않음

---

## Phase 3 — Detail Modal 수정 (M) ✅ 완료

파일: `lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart`

- [x] `_pendingSpaceNameFromOcr` 상태 변수
- [x] `_showOcrUnmatchedAlert()` 메서드
- [x] `_loadSpaceOptions()` 수정 — ocrUnmatched + 정확 일치 매칭
- [x] `_applyOcrResult()` 전면 개편
- [x] `_handleOcrButtonTap()` 수정 — 이미지 확정 후 병렬 조회

---

## Phase 4 — 빌드 및 검증

### 정적 분석
- [x] `dart analyze lib/` — No issues found

### 기능 검증 (실기기) — 미완료
- [ ] 단일 점포 환경: storeName 매칭 생략 확인 (점포 변경 없음)
- [ ] 다수 점포 환경: storeName 매칭 성공 → 점포 자동 선택 확인
- [ ] 다수 점포 환경: storeName 매칭 실패 → 기본값 유지 + "점포" alert 항목 확인
- [ ] 공간 여러 개인 점포: spaceName 매칭 성공 → 공간 자동 선택 확인
- [ ] 공간 매칭 실패 → "공간" alert 항목 확인
- [ ] 전체 필드 성공 매칭 → alert 미표시 확인
- [ ] customerName null → "예약자명" alert 항목 확인
- [ ] 점포 변경 후 공간 매칭 (비동기) 정상 동작 확인

---

## 완료 기준

- [x] `dart analyze` 에러 없음
- [x] 두 모달 모두 동일하게 동작
- [x] 미확인 항목 alert: 항목명 정확, 없으면 미표시
- [x] 점포 변경 경로에서 공간 매칭 타이밍 문제 없음
- [ ] 실기기 동작 확인
