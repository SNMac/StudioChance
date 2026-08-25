# Copilot 리뷰 지침

Firebase, Riverpod, GoRouter, Clean Architecture, MVVM 기반의 Flutter 공간대여 예약 관리 앱입니다.
프로젝트 전체 컨벤션은 저장소 루트의 `CLAUDE.md`를 참고하세요.

## 리뷰 대상

**손으로 작성한 Dart 코드만 리뷰하세요:**

- `lib/**/*.dart` (아래 제외 대상 제외)
- `test/**/*.dart`

## 리뷰 제외 대상

다음 파일은 **리뷰하지 마세요. 코멘트를 남기지 마세요.**

### 코드 생성 결과물

- `**/*.g.dart` — `json_serializable` / `riverpod_generator` 생성
- `**/*.freezed.dart` — `freezed` 생성

`dart run build_runner build --delete-conflicting-outputs`로 생성되며 사람이 편집하지 않습니다.
손으로 수정해도 다음 생성 시 덮어써지므로, 이 파일에 대한 지적은 실행할 수 없는 제안입니다.
문제가 있다면 원인은 생성 결과가 아니라 소스 애노테이션(`@freezed`, `@JsonSerializable`, `@riverpod`)에 있습니다.

> 이 파일들은 `analysis_options.yaml`에서도 정적 분석 대상에서 제외됩니다.

### 프로젝트 코드가 아닌 것

- `.claude/**` — Claude Code 스킬·설정. 대부분 서드파티 파일이며 앱과 무관합니다
- `docs/**` — 설계 문서·구현 플랜
- `ios/**`, `android/**`, `macos/**`, `linux/**`, `windows/**` — 플랫폼 스캐폴딩
- `build/**`, `.dart_tool/**` — 빌드 산출물
- `**/*.arb`, `**/*.json` — 로컬라이제이션·설정 데이터

## 리뷰 시 주의사항

### Dart 언어 버전

이 프로젝트는 **Dart SDK `^3.10.4`** 를 사용합니다. 최신 문법을 오류로 지적하지 마세요.

- **null-aware elements** (Dart 3.8+): 컬렉션 리터럴에서 `?expr`는 값이 null이면 항목 자체를 생략합니다.
  `{'key': ?maybeNull}` 는 올바른 문법입니다. 조건부 map entry로 바꾸라고 제안하지 마세요.
- 레코드, 패턴 매칭, `sealed` 클래스, switch expression 모두 사용합니다.

문법 오류를 지적하기 전에 `dart analyze`로 확인 가능한 사안인지 먼저 판단하세요.
프로젝트는 `dart analyze lib test` 클린 상태를 유지합니다.

### 아키텍처 규칙

- **계층 방향**: Presentation → Domain → Data. Domain은 Data를 import하지 않습니다.
  - 예외: `*_use_case_provider.dart`는 DI 배선 파일이라 data import를 허용합니다.
- **위젯에서 UseCase 직접 호출 금지**: 위젯은 `lib/presentation/providers/`의 Controller를 거칩니다.
- **에러 처리**: UseCase는 `fpdart`의 `Either<Exception, T>`를 반환합니다.
  `isLeft()`/`getLeft()` 명령형 스타일 대신 `fold()`를 사용합니다.
- **보안 경계는 Firestore Security Rules**입니다. UseCase 레벨 권한 검증이 없다는 지적은
  의도된 설계이므로 불필요합니다 (`CLAUDE.md` D2 참고).

### 테스트 정책

위젯 테스트는 픽셀 크기·색상 hex·폰트 스타일·레이아웃 구조를 assert하지 않습니다.
상태 전이·콜백 호출·크래시 방지 등 **동작만** 검증합니다 — UI 리팩터링 시 무관한 테스트가 깨지는 것을 막기 위함입니다.
"렌더링 결과를 더 엄밀히 검증하라"는 제안은 이 정책과 충돌합니다.

### 프로덕션 상태

정식 출시 전(2026-08 말 예정)이라 **프로덕션 데이터가 없습니다.**
Firestore 스키마 변경 시 마이그레이션 전략을 요구하지 마세요.

## 언어

리뷰 코멘트는 **한국어**로 작성하세요.
