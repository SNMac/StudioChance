import 'package:cloud_functions/cloud_functions.dart';
import 'package:mocktail/mocktail.dart';

import 'package:studio_chance/data/data_sources/auth_data_source.dart';
import 'package:studio_chance/data/data_sources/notification_data_source.dart';
import 'package:studio_chance/data/data_sources/reservation_data_source.dart';
import 'package:studio_chance/data/data_sources/server_clock_data_source.dart';
import 'package:studio_chance/data/data_sources/store_data_source.dart';
import 'package:studio_chance/data/data_sources/user_data_source.dart';
import 'package:studio_chance/data/models/reservation_model.dart';
import 'package:studio_chance/domain/entities/auth_info.dart';
import 'package:studio_chance/domain/entities/reservation.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/repository_interfaces/auth_repository.dart';
import 'package:studio_chance/domain/repository_interfaces/holiday_repository.dart';
import 'package:studio_chance/domain/repository_interfaces/reservation_repository.dart';
import 'package:studio_chance/domain/repository_interfaces/store_repository.dart';
import 'package:studio_chance/domain/repository_interfaces/user_repository.dart';
import 'package:studio_chance/domain/use_cases/auth_use_case.dart';
import 'package:studio_chance/domain/use_cases/holiday_use_case.dart';
import 'package:studio_chance/domain/use_cases/reservation_use_case.dart';
import 'package:studio_chance/domain/use_cases/store_use_case.dart';
import 'package:studio_chance/domain/use_cases/user_use_case.dart';

// 테스트 전용 mocktail Mock·Fake 모음.
//
// 각 테스트가 같은 선언을 따로 두면 찾기 어렵고 이름만 같은 다른 클래스가 생기기
// 쉬워 여기 한 곳에 둔다. 로직이 있는 fake(예: FakeNotificationUseCase)는 별도
// 헬퍼 파일에 둔다.

// ─── Data Source ─────────────────────────────────────────────────────────────

class MockAuthDataSource extends Mock implements AuthDataSource {}

class MockNotificationDataSource extends Mock
    implements NotificationDataSource {}

class MockReservationDataSource extends Mock implements ReservationDataSource {}

class MockServerClockDataSource extends Mock implements ServerClockDataSource {}

class MockStoreDataSource extends Mock implements StoreDataSource {}

class MockUserDataSource extends Mock implements UserDataSource {}

class MockFirebaseFunctions extends Mock implements FirebaseFunctions {}

class MockHttpsCallable extends Mock implements HttpsCallable {}

class MockHttpsCallableResult extends Mock
    implements HttpsCallableResult<dynamic> {}

// ─── Repository ──────────────────────────────────────────────────────────────

class MockAuthRepository extends Mock implements AuthRepository {}

class MockHolidayRepository extends Mock implements HolidayRepository {}

class MockReservationRepository extends Mock implements ReservationRepository {}

class MockStoreRepository extends Mock implements StoreRepository {}

class MockUserRepository extends Mock implements UserRepository {}

// ─── UseCase ─────────────────────────────────────────────────────────────────

class MockAuthUseCase extends Mock implements AuthUseCase {}

class MockHolidayUseCase extends Mock implements HolidayUseCase {}

class MockReservationUseCase extends Mock implements ReservationUseCase {}

class MockStoreUseCase extends Mock implements StoreUseCase {}

class MockUserUseCase extends Mock implements UserUseCase {}

// ─── registerFallbackValue용 Fake ────────────────────────────────────────────

class FakeAuthInfo extends Fake implements AuthInfo {}

class FakeReservation extends Fake implements Reservation {}

class FakeReservationModel extends Fake implements ReservationModel {}

class FakeStore extends Fake implements Store {}
