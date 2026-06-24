# OCR 점포·공간 자동 선택 — 태스크

Last Updated: 2026-05-24

---

## Phase 1 — Domain + Data 레이어 (S)

### ReservationOcrResult 엔티티
- [ ] `lib/domain/entities/reservation_ocr_result.dart`
  - `String? storeName` 필드 추가 (기존 `memo` 뒤)
  - `String? spaceName` 필드 추가

### ReservationOcrResultModel
- [ ] `lib/data/models/reservation_ocr_result_model.dart`
  - `String? storeName` 필드 추가
  - `String? spaceName` 필드 추가
  - `toEntity()` 에 `storeName: storeName, spaceName: spaceName` 추가

### GeminiDataSource 프롬프트 수정
- [ ] `lib/data/data_sources/gemini_data_source.dart`
  - `_prompt` 문자열 내 규칙 7 뒤에 규칙 8·9 삽입
    - 8: `storeName` — 운영 업체명, 예약 플랫폼명 제외, 없으면 null
    - 9: `spaceName` — 예약된 공간 이름, 없으면 null
  - `[출력 포맷 스키마]` 에 `"storeName": string | null`, `"spaceName": string | null` 추가

### 코드 생성
- [ ] `dart run build_runner build --delete-conflicting-outputs`
  - `reservation_ocr_result.freezed.dart` 재생성 확인
  - `reservation_ocr_result_model.freezed.dart` 재생성 확인
  - `reservation_ocr_result_model.g.dart` 재생성 확인

---

## Phase 2 — Create Modal 수정 (M)

파일: `lib/presentation/home/widgets/three_day_calendar/reservation_create_modal.dart`

### 상태 변수 추가
- [ ] `String? _pendingSpaceNameFromOcr;` — 편집 상태 변수 섹션에 추가

### 헬퍼 메서드 추가
- [ ] `bool _nameMatches(String ocrName, String actualName)` 메서드 추가
  - lowercase trim 후 양방향 contains 비교

### `_showOcrUnmatchedAlert` 추가
- [ ] `void _showOcrUnmatchedAlert(List<String> unmatched)` 메서드 추가
  - unmatched 비어있거나 !mounted 이면 return
  - `showCustomAlertDialog(title: '자동 입력 확인 필요', content: '...')`

### `_loadSpaceOptions` 수정
- [ ] 시그니처 변경: `void _loadSpaceOptions(String storeId, {List<String> ocrUnmatched = const []})`
- [ ] `.then()` 콜백 내에서:
  - `_pendingSpaceNameFromOcr` 값 읽기
  - pending != null 이면 매칭 시도:
    - 성공 → `_spaceOptionId = matched.id`
    - 실패 → `unmatched.add('공간')`
  - `_pendingSpaceNameFromOcr = null` 초기화
  - `_recalculatePrice()` 호출
  - `_showOcrUnmatchedAlert(unmatched)` 호출
- [ ] 기존 자동 선택 로직(`_spaceOptionId == null` 조건) 유지

### `_applyOcrResult` 전면 개편
- [ ] 기존 필드 적용 유지 (customerName, customerPhone 등)
- [ ] null 필드에 대해 `unmatched.add(...)` 추가 (예약자명, 연락처, 시작 시간)
- [ ] storeName 매칭 로직 추가:
  - `_availableStores.length > 1` 이고 `result.storeName != null` 일 때만
  - 매칭 성공 → setState로 `_storeSummary` 변경, `_spaceOptions/Id` null 리셋
  - 매칭 실패 → `unmatched.add('점포')`
- [ ] spaceName 처리:
  - 점포 변경된 경우 → `_pendingSpaceNameFromOcr = result.spaceName`, `_loadSpaceOptions(newId, ocrUnmatched: unmatched)` 호출
  - 점포 미변경인 경우 → 즉시 `_spaceOptions` 매칭, `_showOcrUnmatchedAlert` 즉시 호출

---

## Phase 3 — Detail Modal 수정 (M)

파일: `lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart`

- [ ] Phase 2와 동일한 변경 적용
  - `_pendingSpaceNameFromOcr` 상태 변수
  - `_nameMatches()` 헬퍼
  - `_showOcrUnmatchedAlert()` 메서드
  - `_loadSpaceOptions()` 수정
  - `_applyOcrResult()` 전면 개편

> 주의: detail modal의 `_loadSpaceOptions`는 `_recalculatePrice()` 호출 위치가 create modal과 약간 다름. 코드 구조 확인 후 적용.

---

## Phase 4 — 빌드 및 검증 (S)

### 정적 분석
- [ ] `dart analyze` — 에러 없음 확인

### 기능 검증 (실기기)
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

- `dart analyze` 에러 없음
- 두 모달 모두 동일하게 동작
- 미확인 항목 alert: 항목명 정확, 없으면 미표시
- 점포 변경 경로에서 공간 매칭 타이밍 문제 없음
