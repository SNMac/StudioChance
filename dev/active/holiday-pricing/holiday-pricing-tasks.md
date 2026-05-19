# 공휴일 요금 적용 — Tasks

## 상태: 대기 중 (공공데이터포털 API 키 발급 필요)

## Prerequisites
- [ ] 공공데이터포털 (data.go.kr) 회원가입 및 API 키 발급
  - 서비스: 한국천문연구원 특일 정보
  - URL: https://www.data.go.kr/data/15012690/openapi.do

## 구현 Tasks

### Domain Layer
- [ ] `HolidayRepository` 인터페이스 생성 (`lib/domain/repository_interfaces/holiday_repository.dart`)
- [ ] 필요 시 `HolidayUseCase` 생성 (단순 조회면 Repository 직접 사용)

### Data Layer
- [ ] `HolidayDataSource` 구현 — 공공데이터포털 API 호출, 월별 캐시
- [ ] `HolidayRepositoryImpl` 구현 — DataSource 래핑, `Either` 반환

### DI 배선
- [ ] `holiday_repository_provider.dart` 생성 (`use_case_providers`와 동일 패턴)

### UseCase 연동
- [ ] `ReservationUseCaseImpl`에 `HolidayRepository` 주입
- [ ] `_applyCalculatedPrice` — `isHoliday: false` TODO 제거, 실제 값 전달

### UI 연동
- [ ] `isHolidayProvider(DateTime date)` 생성 (`lib/presentation/providers/`)
- [ ] `reservation_create_modal.dart` — `_recalculatePrice` async 처리, TODO 제거
- [ ] `reservation_detail_modal.dart` — `_recalculatePrice` async 처리, TODO 제거

### 설정
- [ ] `lib/constants/api_keys.dart`에 API 키 추가 (gitignore 처리 확인)
- [ ] `pubspec.yaml`에 HTTP 패키지 추가 (`dio` 권장)
