import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/domain/entities/reservation.dart';
import 'package:studio_chance/domain/entities/user_store_info.dart';
import 'package:studio_chance/domain/enums/store_color.dart';
import 'package:studio_chance/domain/enums/user_role.dart';
import 'package:studio_chance/domain/use_cases/reservation_use_case.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';
import 'package:studio_chance/presentation/providers/home_reservations_provider.dart';

import '../../helpers/fake_entities.dart';

class MockReservationUseCase extends Mock implements ReservationUseCase {}

void main() {
  late MockReservationUseCase mockUseCase;
  final month = DateTime(2026, 5, 1);

  setUpAll(() {
    registerFallbackValue(DateTime(2026));
  });

  setUp(() {
    mockUseCase = MockReservationUseCase();
  });

  ProviderContainer createContainer({required MockReservationUseCase useCase, dynamic user}) {
    return ProviderContainer(
      overrides: [
        currentUserProvider.overrideWith((ref) async => user),
        reservationUseCaseProvider.overrideWith((ref) => useCase),
      ],
    );
  }

  test('currentUser가 null이면 빈 목록을 반환하고 UseCase를 호출하지 않는다', () async {
    final container = createContainer(useCase: mockUseCase, user: null);
    addTearDown(container.dispose);

    final result = await container.read(homeReservationsProvider(month).future);

    expect(result, isEmpty);
    verifyNever(() => mockUseCase.getReservationsByDateRange(
          storeId: any(named: 'storeId'),
          start: any(named: 'start'),
          end: any(named: 'end'),
        ));
  });

  test('storeInfos가 비어있으면 빈 목록을 반환한다', () async {
    final userWithNoStores = fakeUser.copyWith(storeInfos: []);
    final container = createContainer(useCase: mockUseCase, user: userWithNoStores);
    addTearDown(container.dispose);

    final result = await container.read(homeReservationsProvider(month).future);

    expect(result, isEmpty);
  });

  test('단일 점포의 예약을 반환한다', () async {
    when(() => mockUseCase.getReservationsByDateRange(
          storeId: 'store-123',
          start: any(named: 'start'),
          end: any(named: 'end'),
        )).thenAnswer((_) async => right([fakeReservation]));

    final container = createContainer(useCase: mockUseCase, user: fakeUser);
    addTearDown(container.dispose);

    final result = await container.read(homeReservationsProvider(month).future);

    expect(result.length, 1);
    expect(result.first.id, fakeReservation.id);
  });

  test('조회 범위가 month의 1일부터 다음달 1일까지이다', () async {
    DateTime? capturedStart;
    DateTime? capturedEnd;

    when(() => mockUseCase.getReservationsByDateRange(
          storeId: any(named: 'storeId'),
          start: any(named: 'start'),
          end: any(named: 'end'),
        )).thenAnswer((invocation) async {
      capturedStart = invocation.namedArguments[#start] as DateTime;
      capturedEnd = invocation.namedArguments[#end] as DateTime;
      return right(<Reservation>[]);
    });

    final container = createContainer(useCase: mockUseCase, user: fakeUser);
    addTearDown(container.dispose);

    await container.read(homeReservationsProvider(month).future);

    expect(capturedStart, DateTime(2026, 5, 1));
    expect(capturedEnd, DateTime(2026, 6, 1));
  });

  test('복수 점포의 예약을 병합하여 반환한다', () async {
    final reservation1 = fakeReservation.copyWith(id: 'res-001');
    final reservation2 = fakeReservation.copyWith(id: 'res-002');

    when(() => mockUseCase.getReservationsByDateRange(
          storeId: 'store-123',
          start: any(named: 'start'),
          end: any(named: 'end'),
        )).thenAnswer((_) async => right([reservation1]));

    when(() => mockUseCase.getReservationsByDateRange(
          storeId: 'store-456',
          start: any(named: 'start'),
          end: any(named: 'end'),
        )).thenAnswer((_) async => right([reservation2]));

    final userWith2Stores = fakeUser.copyWith(storeInfos: [
      fakeUser.storeInfos.first,
      UserStoreInfo(
        id: 'store-456',
        name: '두번째점포',
        role: UserRole.admin,
        color: StoreColor.blue,
        memo: '',
      ),
    ]);

    final container = createContainer(useCase: mockUseCase, user: userWith2Stores);
    addTearDown(container.dispose);

    final result = await container.read(homeReservationsProvider(month).future);

    expect(result.length, 2);
    expect(result.map((r) => r.id), containsAll(['res-001', 'res-002']));
  });

  test('한 점포 조회 실패 시 성공한 점포 결과만 포함한다', () async {
    when(() => mockUseCase.getReservationsByDateRange(
          storeId: 'store-123',
          start: any(named: 'start'),
          end: any(named: 'end'),
        )).thenAnswer((_) async => right([fakeReservation]));

    when(() => mockUseCase.getReservationsByDateRange(
          storeId: 'store-456',
          start: any(named: 'start'),
          end: any(named: 'end'),
        )).thenAnswer((_) async => left(Exception('네트워크 오류')));

    final userWith2Stores = fakeUser.copyWith(storeInfos: [
      fakeUser.storeInfos.first,
      UserStoreInfo(
        id: 'store-456',
        name: '두번째점포',
        role: UserRole.admin,
        color: StoreColor.blue,
        memo: '',
      ),
    ]);

    final container = createContainer(useCase: mockUseCase, user: userWith2Stores);
    addTearDown(container.dispose);

    final result = await container.read(homeReservationsProvider(month).future);

    expect(result.length, 1);
    expect(result.first.id, fakeReservation.id);
  });
}
