# OCR 점포·공간 자동 선택 — 컨텍스트

Last Updated: 2026-05-24

## 구현 상태: 미구현 (설계 완료)

관련 이슈: #10  
선행 기능: `dev/active/reservation-ocr/` (완료)

---

## 핵심 파일

| 파일 | 역할 | 변경 여부 |
|------|------|-----------|
| `lib/domain/entities/reservation_ocr_result.dart` | OCR 결과 엔티티 | **수정** — `storeName`, `spaceName` 필드 추가 |
| `lib/data/models/reservation_ocr_result_model.dart` | JSON 역직렬화 모델 | **수정** — 동일 필드 추가, `toEntity()` 업데이트 |
| `lib/data/data_sources/gemini_data_source.dart` | Gemini API 호출 + 프롬프트 | **수정** — 추출 규칙 8·9 및 JSON 스키마 확장 |
| `lib/presentation/home/widgets/three_day_calendar/reservation_create_modal.dart` | 예약 생성 모달 | **수정** — `_applyOcrResult`, `_loadSpaceOptions`, 신규 메서드 |
| `lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart` | 예약 수정 모달 | **수정** — Create Modal과 동일 |

## 참조 파일 (변경 없음)

| 파일 | 참조 이유 |
|------|----------|
| `lib/domain/entities/store_summary.dart` | `StoreSummary.name` — 매칭 대상 |
| `lib/domain/entities/space_option.dart` | `SpaceOption.name` — 매칭 대상 |
| `lib/presentation/commons/widgets/custom_alert_dialog.dart` | `showCustomAlertDialog` — 미확인 항목 alert 표시 |
| `lib/domain/use_cases/reservation_ocr_use_case.dart` | 핵심 필드 null 체크 (변경 없음) |

---

## 현재 코드 상태

### `ReservationOcrResult` 엔티티 (현재)

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

### `ReservationOcrResultModel` (현재)

```dart
@freezed
abstract class ReservationOcrResultModel with _$ReservationOcrResultModel {
  const ReservationOcrResultModel._();
  const factory ReservationOcrResultModel({
    @JsonKey(name: 'platform', fromJson: _parsePlatform) ReservationPlatform? platform,
    String? customerName,
    String? customerPhone,
    @JsonKey(fromJson: _parseDateTimeNullable) DateTime? startTime,
    @JsonKey(fromJson: _parseDateTimeNullable) DateTime? endTime,
    bool? isAllDay,
    int? headCount,
    String? memo,
  }) = _ReservationOcrResultModel;
  ...
  ReservationOcrResult toEntity() { ... } // storeName/spaceName 없음
}
```

### `_applyOcrResult` (현재, 두 모달 동일 구조)

```dart
void _applyOcrResult(ReservationOcrResult result) {
  setState(() {
    if (result.customerName != null) _nameController.text = result.customerName!;
    if (result.customerPhone != null) _phoneController.text = result.customerPhone!.formattedPhone;
    if (result.headCount != null) _headCountController.text = result.headCount.toString();
    if (result.startTime != null) _startTime = result.startTime!;
    if (result.endTime != null) _endTime = result.endTime!;
    if (result.isAllDay != null) _isAllDay = result.isAllDay!;
    if (result.platform != null) _platform = result.platform!;
    if (result.memo != null) _memoController.text = result.memo!;
  });
  _recalculatePrice();
}
// storeSummary, spaceOptionId 변경 없음
```

### `_loadSpaceOptions` (현재, 두 모달 동일 구조)

```dart
void _loadSpaceOptions(String storeId) {
  ref.read(homeReservationActionsControllerProvider.notifier)
    .getStoreSpaceOptions(storeId)
    .then((spaces) {
      if (!mounted) return;
      setState(() {
        _spaceOptions = spaces;
        if (spaces != null && spaces.isNotEmpty && _spaceOptionId == null) {
          _spaceOptionId = spaces.first.id;
        }
      });
      _recalculatePrice();
    });
}
```

---

## 구현 상세 설계

### 신규 상태 변수

```dart
// 두 모달 모두에 추가
String? _pendingSpaceNameFromOcr;
```

목적: 점포 변경 후 `_loadSpaceOptions` 완료 시점까지 spaceName 보관.

### `_nameMatches` 헬퍼

```dart
bool _nameMatches(String ocrName, String actualName) {
  final ocrLower = ocrName.toLowerCase().trim();
  final actualLower = actualName.toLowerCase().trim();
  return actualLower.contains(ocrLower) || ocrLower.contains(actualLower);
}
```

### `_loadSpaceOptions` 수정 후 (타겟)

```dart
void _loadSpaceOptions(String storeId, {List<String> ocrUnmatched = const []}) {
  ref.read(homeReservationActionsControllerProvider.notifier)
    .getStoreSpaceOptions(storeId)
    .then((spaces) {
      if (!mounted) return;
      final pending = _pendingSpaceNameFromOcr;
      final unmatched = List<String>.from(ocrUnmatched);
      setState(() {
        _spaceOptions = spaces;
        if (spaces != null && spaces.isNotEmpty) {
          if (pending != null) {
            // OCR spaceName 매칭 시도
            final matched = spaces.where((s) => _nameMatches(pending, s.name)).firstOrNull;
            if (matched != null) {
              _spaceOptionId = matched.id;
            } else {
              _spaceOptionId = _spaceOptionId ?? spaces.first.id;
              unmatched.add('공간');
            }
          } else if (_spaceOptionId == null) {
            _spaceOptionId = spaces.first.id;
          }
        }
        _pendingSpaceNameFromOcr = null;
      });
      _recalculatePrice();
      _showOcrUnmatchedAlert(unmatched); // 지연 표시
    });
}
```

### `_applyOcrResult` 수정 후 (타겟)

```dart
void _applyOcrResult(ReservationOcrResult result) {
  final unmatched = <String>[];

  // 기존 필드 적용 (변경 없음)
  setState(() {
    if (result.customerName != null) _nameController.text = result.customerName!;
    else unmatched.add('예약자명');
    if (result.customerPhone != null) _phoneController.text = result.customerPhone!.formattedPhone;
    else unmatched.add('연락처');
    if (result.headCount != null) _headCountController.text = result.headCount.toString();
    if (result.startTime != null) _startTime = result.startTime!;
    else unmatched.add('시작 시간');
    if (result.endTime != null) _endTime = result.endTime!;
    if (result.isAllDay != null) _isAllDay = result.isAllDay!;
    if (result.platform != null) _platform = result.platform!;
    if (result.memo != null) _memoController.text = result.memo!;
  });

  // 점포 매칭
  final ocrStoreName = result.storeName;
  StoreSummary? matchedStore;
  if (ocrStoreName != null && _availableStores.length > 1) {
    matchedStore = _availableStores
        .where((s) => _nameMatches(ocrStoreName, s.name))
        .firstOrNull;
    if (matchedStore != null) {
      setState(() {
        _storeSummary = matchedStore!;
        _spaceOptions = null;
        _spaceOptionId = null;
      });
    } else {
      unmatched.add('점포');
    }
  }

  if (matchedStore != null) {
    // 점포 변경 → spaceName 보관 후 loadSpaceOptions에서 처리
    _pendingSpaceNameFromOcr = result.spaceName;
    _loadSpaceOptions(matchedStore.id, ocrUnmatched: unmatched);
    // alert는 _loadSpaceOptions 콜백 내에서 지연 표시
  } else {
    // 점포 변경 없음 → 즉시 공간 매칭
    final ocrSpaceName = result.spaceName;
    if (ocrSpaceName != null) {
      final spaces = _spaceOptions;
      if (spaces != null && spaces.isNotEmpty) {
        final matched = spaces.where((s) => _nameMatches(ocrSpaceName, s.name)).firstOrNull;
        if (matched != null) {
          setState(() => _spaceOptionId = matched.id);
        } else {
          unmatched.add('공간');
        }
      }
      // spaces가 아직 null이면 매칭 불가 → 무시 (기본값 유지)
    }
    _recalculatePrice();
    _showOcrUnmatchedAlert(unmatched); // 즉시 표시
  }
}
```

### `_showOcrUnmatchedAlert` (신규 메서드)

```dart
void _showOcrUnmatchedAlert(List<String> unmatched) {
  if (unmatched.isEmpty || !mounted) return;
  showCustomAlertDialog(
    context: context,
    title: '자동 입력 확인 필요',
    content: '다음 항목을 직접 확인해 주세요:\n${unmatched.join(', ')}',
  );
}
```

---

## Gemini 프롬프트 수정

### 현재 `_prompt` 마지막 규칙 (line 47)

```
7. memo: '요청사항', '사용목적' 또는 특이사항 문구를 추출하되, 없을 경우 null로 반환하세요. ...
```

### 추가할 내용 (7번 뒤에 삽입)

```
8. storeName: 이 공간을 운영하는 업체(점포) 이름. 예약 확인 화면에 표시되는 공간 운영 업체명. 예약 플랫폼(네이버, 스페이스클라우드 등) 이름은 여기에 포함하지 마십시오. 없으면 null.
9. spaceName: 예약된 특정 공간 이름 (예: A룸, 스튜디오1, B홀). 공간 구분이 없거나 명시되지 않으면 null.
```

### 현재 JSON 스키마 (line 49–59)

```
{
  "platform": "NAVER" | "SPACECLOUD" | "YANOLJA" | "OTHER",
  ...
  "memo": string | null
}
```

### 수정 후 스키마

```
{
  "platform": "NAVER" | "SPACECLOUD" | "YANOLJA" | "OTHER",
  "customerName": string,
  "customerPhone": string,
  "startTime": string,
  "endTime": string | null,
  "isAllDay": boolean,
  "headCount": integer,
  "memo": string | null,
  "storeName": string | null,
  "spaceName": string | null
}
```

---

## 아키텍처 결정

### D-OCR-1: `_pendingSpaceNameFromOcr` 타이밍 패턴
점포 변경 시 `_loadSpaceOptions`가 비동기 완료된 후에야 공간 목록을 알 수 있다.  
중간 값을 상태 변수에 보관하는 패턴으로 타이밍 문제 해결.  
`_loadSpaceOptions` 콜백에서 값을 소비 후 즉시 `null`로 초기화.

### D-OCR-2: 점포가 1개일 때 storeName 매칭 생략
`_availableStores.length == 1`이면 매칭할 필요 없음.  
OCR에서 다른 점포명이 나와도 유일한 점포를 변경하지 않음.  
`storeName != null && _availableStores.length > 1` 조건부 처리.

### D-OCR-3: `_spaceOptions`가 null일 때 공간 매칭 생략
점포 미변경 경로에서 `_spaceOptions`가 아직 null이면 공간 매칭 불가.  
이 경우 매칭 시도 없이 넘어감 (기본값 유지). alert에도 포함 안 함.  
— 초기 로드 중인 상태이므로 자동 선택이 의미 없음.

### D-OCR-4: alert 항목 범위
핵심 필드만 포함: `예약자명`, `연락처`, `시작 시간`, `점포`, `공간`.  
`endTime`, `headCount`, `platform`, `memo`는 선택 항목이라 alert 제외.  
— 너무 많은 항목 표시 시 사용자 부담 증가.
