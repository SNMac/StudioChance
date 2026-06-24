# OCR 점포·공간 자동 선택 — 컨텍스트

Last Updated: 2026-06-25

## 구현 상태: 코드 완료, 실기기 검증 필요

관련 이슈: #17 (GitHub)
브랜치: `feat/#17-ocr-store-space-auto-select`
선행 기능: `dev/active/reservation-ocr/` (완료)

---

## 핵심 파일

| 파일 | 역할 | 변경 여부 |
|------|------|-----------|
| `lib/domain/entities/reservation_ocr_result.dart` | OCR 결과 엔티티 | **수정** — `storeName`, `spaceName` 필드 추가 |
| `lib/data/models/reservation_ocr_result_model.dart` | JSON 역직렬화 모델 | **수정** — 동일 필드 추가, `toEntity()` 업데이트 |
| `lib/data/data_sources/gemini_data_source.dart` | Gemini API 호출 + 프롬프트 | **수정** — 동적 프롬프트, storeSpaceMap 파라미터 |
| `lib/domain/repository_interfaces/reservation_ocr_repository.dart` | Repository 인터페이스 | **수정** — storeSpaceMap 파라미터 추가 |
| `lib/data/repositories/reservation_ocr_repository_impl.dart` | Repository 구현체 | **수정** — storeSpaceMap 전달 |
| `lib/domain/use_cases/reservation_ocr_use_case.dart` | UseCase | **수정** — storeSpaceMap 파라미터 추가 및 전달 |
| `lib/presentation/providers/reservation_ocr_controller.dart` | OCR Controller | **수정** — `analyzeImage`에 storeSpaceMap 파라미터 |
| `lib/presentation/home/widgets/three_day_calendar/reservation_create_modal.dart` | 예약 생성 모달 | **수정** — `_handleOcrButtonTap`, `_applyOcrResult`, `_applySpaceOptions` |
| `lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart` | 예약 수정 모달 | **수정** — Create Modal과 동일 |

## 참조 파일 (변경 없음)

| 파일 | 참조 이유 |
|------|----------|
| `lib/domain/entities/store_summary.dart` | `StoreSummary.name` — 매칭 대상 |
| `lib/domain/entities/space_option.dart` | `SpaceOption.name` — 매칭 대상 |
| `lib/presentation/commons/widgets/custom_alert_dialog.dart` | `showCustomAlertDialog` — 미확인 항목 alert 표시 |

---

## 핵심 아키텍처 결정 (이번 세션)

### D-OCR-5: AI 기반 정확 매칭 (원계획 대비 중요 변경)

원래 계획: Gemini가 점포명/공간명 텍스트를 추출 → 클라이언트 퍼지 매칭(`_nameMatches`)

**채택한 방식**: 사용자가 보유한 점포·공간 목록을 Gemini 프롬프트에 포함, Gemini가 직접 목록에서 가장 유사한 항목 선택 후 정확한 이름 그대로 반환.

```
storeSpaceMap 예시:
{
  "강남 스튜디오": ["메인 홀", "스튜디오 홀"],
  "홍대 스튜디오": ["A룸", "B룸"]
}
```

**이점**:
- 띄어쓰기 차이(`스튜디오 꿈` vs `스튜디오꿈`), 부분 명칭, 한/영 혼용 모두 AI가 처리
- 클라이언트 코드 단순화: 정확 일치(`==`)만으로 충분
- 플랫폼이 추가 텍스트를 붙여도(`강남스튜디오 홍대점`) AI가 의미적으로 판단

**클라이언트 매칭**: `_nameMatches` 헬퍼 제거, 단순 `==` 비교

### D-OCR-6: 이미지 확정 후 공간 옵션 조회

원래 계획: `_handleOcrButtonTap` 진입 시 즉시 조회 시작

**채택한 방식**: 사용자가 이미지 프리뷰에서 확정(`confirmed == true`)한 이후에 조회 시작.
취소 시 무의미한 Firestore 읽기 방지.

```dart
// 순서:
// 1. pickForPreview()
// 2. showImagePreviewPage()
// 3. confirmed 후 → Future.wait(모든 점포 공간 옵션)
// 4. storeSpaceMap 구성
// 5. analyzeImage(bytes, storeSpaceMap: ...)
```

### D-OCR-7: GeminiDataSource 프롬프트 동적 생성

`static const _prompt` → `static String _buildPrompt(Map<String, List<String>>? storeSpaceMap)` 메서드로 변경.

- storeSpaceMap 있음: 목록 포함 프롬프트 (Gemini가 목록에서 선택)
- storeSpaceMap 없음: 기존 일반 텍스트 추출 방식으로 폴백 (안전망)

---

## 현재 코드 상태

### `GeminiDataSource.analyzeReservationImage` (현재)

```dart
Future<ReservationOcrResultModel> analyzeReservationImage(
  Uint8List imageBytes, {
  Map<String, List<String>>? storeSpaceMap,  // 신규
}) async {
  final response = await _model.generateContent([
    Content.multi([
      InlineDataPart(_detectMimeType(imageBytes), imageBytes),
      TextPart(_buildPrompt(storeSpaceMap)),  // 동적 프롬프트
    ]),
  ]);
  ...
}
```

### `_handleOcrButtonTap` (두 모달 동일, 현재)

```dart
Future<void> _handleOcrButtonTap() async {
  final bytes = await ref.read(...).pickForPreview();
  if (bytes == null || !mounted) return;
  final confirmed = await showImagePreviewPage(context, bytes);
  if (!confirmed || !mounted) return;

  // 이미지 확정 후 모든 점포 공간 옵션 병렬 조회
  final notifier = ref.read(homeReservationActionsControllerProvider.notifier);
  final allSpaceOptions = await Future.wait(
    _availableStores.map((s) => notifier.getStoreSpaceOptions(s.id)),
  );
  if (!mounted) return;

  final storeSpaceMap = <String, List<String>>{};
  for (var i = 0; i < _availableStores.length; i++) {
    final spaces = allSpaceOptions[i];
    if (spaces != null && spaces.isNotEmpty) {
      storeSpaceMap[_availableStores[i].name] = spaces.map((s) => s.name).toList();
    }
  }

  ref.read(reservationOcrControllerProvider.notifier).analyzeImage(
    bytes,
    storeSpaceMap: storeSpaceMap.isNotEmpty ? storeSpaceMap : null,
  );
}
```

### `_applyOcrResult` 요약 (두 모달 동일 구조, 현재)

- 기존 필드(customerName 등) 적용 + null 시 `unmatched.add(...)`
- storeName: `_availableStores.where((s) => s.name == result.storeName).firstOrNull` (정확 일치)
  - `_availableStores.length > 1` 조건 유지 (D-OCR-2)
  - 매칭 성공 → setState로 _storeSummary 변경, _pendingSpaceNameFromOcr 설정, _loadSpaceOptions 호출
  - 매칭 실패 → unmatched.add('점포')
- spaceName: 점포 변경 없는 경우 `_spaceOptions.where((s) => s.name == ocrSpaceName).firstOrNull`

### `_applySpaceOptions` (Create Modal) / `_loadSpaceOptions` (Detail Modal) 요약

공간 옵션 로드 완료 시:
- `_pendingSpaceNameFromOcr`로 정확 일치 매칭
- 매칭 성공 → `_spaceOptionId = matched.id`
- 매칭 실패 → `_spaceOptionId ??= spaces.first.id`, `unmatched.add('공간')`
- `_pendingSpaceNameFromOcr = null` 초기화
- `_showOcrUnmatchedAlert(unmatched)` 호출

---

## 기존 계획 대비 변경 사항

| 항목 | 원계획 | 실제 구현 |
|------|--------|-----------|
| 매칭 방식 | 클라이언트 퍼지 매칭(`_nameMatches`) | AI 기반 정확 매칭 (목록 제공 → 정확 이름 반환) |
| 공간 옵션 조회 시점 | 미정 | 이미지 확정 후 (취소 시 조회 안 함) |
| 클라이언트 비교 | `_nameMatches` (contains) | `==` (정확 일치) |
| GeminiDataSource 시그니처 | `analyzeReservationImage(bytes)` | `analyzeReservationImage(bytes, {storeSpaceMap})` |
| storeSpaceMap 체인 | 없음 | Repository → UseCase → Controller 전체 관통 |

---

## 남은 작업

1. **실기기 검증** (Phase 4 기능 검증 항목 참조)
   - 다수 점포 환경이 필요한 항목은 테스트 환경 구성 필요
2. **PR 생성** — `feat/#22-ocr-store-space-auto-select` → `develop`

## 커밋 이력 (이번 세션)

- `b6574f8` feat: #17 - OCR 결과에서 점포명·공간명 추출 및 자동 선택 구현
- `7347c1c` feat: #17 - Gemini에 점포·공간 목록 전달하여 AI 기반 정확 매칭으로 개선
