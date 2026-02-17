# 프로젝트: SpaceManager
> 가제: StudioChance

Firebase, Riverpod, GoRouter, Clean Architecture, MVVM을 사용하는 공간대여업 예약 관리 크로스플랫폼(iOS, Android) 앱입니다.
- Firebase 서비스: Firestore, Authentication, Crashlytics, Cloud Message, Analytics, App Check
- 소셜 로그인: Google, Apple
  - 정식 출시 후 Naver, Kakao 추가 예정

## 코드 스타일
- Flutter/Dart 사용
- Dart 컨벤션 사용
- 콘솔 출력 시 `logger` 라이브러리 사용
- 한국어로 커밋 메시지, 주석 작성

## 아키텍처
- `/lib/common`: 모든 계층에서 사용되는 로직
- `/lib/constants`: 모든 계층에서 사용되는 상수값
- `/lib/data`: Data 계층
  - `/data_sources`: DB 연결 로직
  - `/models`: Data 모델
  - `/repositories`: Data 로직 구현체
- `/lib/domain`: Domain(비즈니스 로직) 계층
  - `/entities`: Domain 엔티티
  - `/enums`: Domain 관련 enum
  - `/repository_interfaces`: Domain에서 필요로 하는 Data 로직 인터페이스
  - `/use_cases`: 비즈니스 로직 단위
- `/lib/presentation`: UI 계층
  - `/commons`: 여러 곳에서 사용되는 UI
  - `/home`: 홈 화면
  - `/my_page`: 마이페이지 화면
  - `/onboarding`: 온보딩 화면
  - `/providers`: UI 상태 관리
  - `/sign_in`: 로그인 화면
  - `/splash`: 스플래시 화면
- `/lib/router`: 화면 전환 로직

## 코드 생성
- `freezed` + `json_serializable` + `riverpod_generator` 사용
- Domain Entity: `@freezed` (JSON 없음), Data Model: `@freezed` + `fromJson`
- Provider: `@riverpod` 또는 `@Riverpod(keepAlive: true)` 어노테이션 사용
- 생성 파일(`*.g.dart`, `*.freezed.dart`)은 분석에서 제외됨
- 코드 생성 명령어: `dart run build_runner build --delete-conflicting-outputs`

## 에러 핸들링
- `fpdart`의 `Either<Exception, T>` 패턴 사용 (Use Case 반환 타입)
- `left()` = 실패, `right()` = 성공

## Git 컨벤션
- 브랜치: `feat/#<이슈번호>-<설명>`, `fix/#<이슈번호>-<설명>`
- 커밋: `<type>: #<이슈번호> - <한국어 설명>`
- 기본 브랜치: `develop` (PR 대상)

## 빌드 및 실행
- `flutter run` - 앱 실행
- `dart run build_runner build --delete-conflicting-outputs` - 코드 생성
- `dart run build_runner watch` - 코드 생성 (watch 모드)

## 폰트 및 디자인
- 기본 폰트: Pretendard (400, 500, 600, 700)
- Material 3 디자인 시스템 사용

## 중요 사항
- API Key 관련 문자열은 gitignore 처리되어있는 별도 파일로 분리하고 import하여 사용
