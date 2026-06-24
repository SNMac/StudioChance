# OCR 점포·공간 자동 선택 — 구현 계획

Last Updated: 2026-05-24

## Executive Summary

기존 예약 스크린샷 OCR 기능에 **점포명**·**공간명** 추출을 추가한다.  
Gemini가 스크린샷에서 점포명과 공간명을 추출하고, 모달이 보유한 `_availableStores`·`_spaceOptions`와 매칭을 시도한다.  
매칭 성공 시 해당 항목을 자동 선택하고, 실패 시 기본값을 유지하면서 **분석 완료 후 alert**로 확인 요청 목록을 보여준다.

관련 이슈: #10  
기반 기능: `dev/active/reservation-ocr/` (Phase 1–5 완료)

---

## Current State Analysis

### 현재 OCR 추출 필드

| 필드 | 타입 | 상태 |
|------|------|------|
| `platform` | `ReservationPlatform?` | ✅ 추출 중 |
| `customerName` | `String?` | ✅ 추출 중 |
| `customerPhone` | `String?` | ✅ 추출 중 |
| `startTime` | `DateTime?` | ✅ 추출 중 |
| `endTime` | `DateTime?` | ✅ 추출 중 |
| `isAllDay` | `bool?` | ✅ 추출 중 |
| `headCount` | `int?` | ✅ 추출 중 |
| `memo` | `String?` | ✅ 추출 중 |
| `storeName` | `String?` | ❌ **미구현** |
| `spaceName` | `String?` | ❌ **미구현** |

### 현재 한계

- 모달의 `_storeSummary`·`_spaceOptionId` 는 OCR 결과에 영향받지 않음
- 사용자가 점포/공간을 수동으로 선택해야 함
- OCR 완료 후 어떤 필드가 미추출됐는지 사용자에게 알려주지 않음

### 핵심 파일

| 파일 | 역할 |
|------|------|
| `lib/domain/entities/reservation_ocr_result.dart` | OCR 결과 엔티티 |
| `lib/data/models/reservation_ocr_result_model.dart` | JSON 역직렬화 모델 |
| `lib/data/data_sources/gemini_data_source.dart` | Gemini 프롬프트 + API 호출 |
| `lib/presentation/home/widgets/three_day_calendar/reservation_create_modal.dart` | 예약 생성 모달 |
| `lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart` | 예약 수정 모달 |

---

## Proposed Future State

### 추가 추출 필드

```dart
// reservation_ocr_result.dart
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
    String? storeName,   // 신규
    String? spaceName,   // 신규
  }) = _ReservationOcrResult;
}
```

### 매칭 전략

```dart
bool _nameMatches(String ocrName, String actualName) {
  final ocrLower = ocrName.toLowerCase().trim();
  final actualLower = actualName.toLowerCase().trim();
  return actualLower.contains(ocrLower) || ocrLower.contains(actualLower);
}
```

양방향 contains 매칭 — 부분 명칭도 인식 가능.

### 미확인 항목 alert

OCR 완료 후 다음 조건 중 하나라도 해당하면 alert 표시:

| 조건 | alert 항목 |
|------|-----------|
| `result.storeName != null` 이지만 매칭 실패 | "점포" |
| `result.spaceName != null` 이지만 매칭 실패 | "공간" |
| `result.customerName == null` | "예약자명" |
| `result.customerPhone == null` | "연락처" |
| `result.startTime == null` | "시작 시간" |

```
제목: "자동 입력 확인 필요"
내용: "다음 항목을 직접 확인해 주세요:\n점포, 공간, 예약자명"
버튼: "확인"
```

모든 필드가 성공적으로 적용됐다면 alert 없음.

### 점포 변경 시 공간 매칭 흐름

점포가 변경되면 공간 목록을 새로 로드해야 하므로 타이밍 문제가 발생한다.  
`_pendingSpaceNameFromOcr` 변수로 처리:

```
_applyOcrResult() 호출
  ├── storeName 매칭 성공 → _storeSummary 변경
  │   ├── _pendingSpaceNameFromOcr = result.spaceName
  │   ├── _loadSpaceOptions(newStoreId) 호출
  │   │   └── .then() 콜백에서:
  │   │       ├── _pendingSpaceNameFromOcr으로 spaceName 매칭 시도
  │   │       ├── _pendingSpaceNameFromOcr = null (초기화)
  │   │       └── _showOcrUnmatchedAlert(unmatched) 호출
  │   └── (alert는 콜백에서 지연 표시)
  │
  └── storeName 매칭 실패 / 1개 점포 → 기본값 유지
      ├── 즉시 _spaceOptions에서 spaceName 매칭 시도
      └── _showOcrUnmatchedAlert(unmatched) 즉시 표시
```

---

## Implementation Phases

### Phase 1 — Domain + Data 레이어 (S)

1. `ReservationOcrResult` 엔티티에 `storeName`, `spaceName` 필드 추가
2. `ReservationOcrResultModel`에 동일 필드 추가 + `toEntity()` 업데이트
3. `GeminiDataSource` 프롬프트 수정
4. `dart run build_runner build --delete-conflicting-outputs` 실행

### Phase 2 — Create Modal 수정 (M)

1. `_pendingSpaceNameFromOcr` 상태 변수 추가
2. `_nameMatches()` 헬퍼 메서드 추가
3. `_loadSpaceOptions()` 수정 — `_pendingSpaceNameFromOcr` 처리 + alert 지연 표시
4. `_applyOcrResult()` 전면 개편 — 점포/공간 매칭 로직 추가
5. `_showOcrUnmatchedAlert()` 메서드 추가

### Phase 3 — Detail Modal 수정 (M)

Create Modal과 동일한 변경 (Phase 2 완료 후 복사·적용)

### Phase 4 — 빌드 및 검증 (S)

- `dart analyze` — 에러 없음 확인
- 실기기에서 동작 확인 (점포 매칭 / 공간 매칭 / alert)

---

## Gemini 프롬프트 수정 상세

### 추가할 추출 규칙

```
8. storeName: 이 공간을 운영하는 업체(점포) 이름. 예약 확인 화면 상단에 표시되는 경우가 많음. 없으면 null.
9. spaceName: 예약된 공간 이름 (예: A룸, 스튜디오1, B홀). 공간 구분이 없으면 null.
```

### 추가할 JSON 스키마

```json
{
  ...(기존 필드)...,
  "storeName": string | null,
  "spaceName": string | null
}
```

---

## Risk Assessment

| 위험 | 가능성 | 대응 |
|------|--------|------|
| Gemini가 점포명/공간명 대신 플랫폼명 추출 | 중간 | 프롬프트에 "예약 플랫폼명 아닌 업체명" 명시 |
| 매칭 실패로 기본값 유지 → alert 표시 | 정상 동작 | 사용자가 alert 보고 수동 선택 |
| 점포 변경 중 모달 unmount | 낮음 | `.then()` 콜백에서 `!mounted` guard |
| `_spaceOptions`가 아직 null일 때 공간 매칭 시도 | 낮음 | `_pendingSpaceNameFromOcr` 패턴으로 방어 |

---

## Success Metrics

- [ ] OCR 결과에 `storeName`·`spaceName` 필드 포함
- [ ] 다수 점포 환경에서 점포 자동 선택 동작 확인
- [ ] 공간이 여러 개인 점포에서 공간 자동 선택 동작 확인
- [ ] 매칭 실패 시 기본값 유지 확인
- [ ] 미확인 항목 alert 표시 확인 (항목명 정확 여부)
- [ ] 전체 성공 시 alert 미표시 확인
- [ ] `dart analyze` 에러 없음
