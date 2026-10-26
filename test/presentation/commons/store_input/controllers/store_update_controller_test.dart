import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/common/enums/store_color.dart';
import 'package:studio_chance/common/exceptions/store_exceptions.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/use_cases/store_use_case_provider.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_update_controller.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';

import '../../../../helpers/fake_entities.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockStoreUseCase mockStoreUseCase;
  late ProviderContainer container;

  // fakeStore의 공간은 이름이 비어 있어 isValid를 통과하지 못한다
  final opened = fakeStore.copyWith(
    spaceOptions: [fakeStore.spaceOptions.first.copyWith(name: '기본 공간')],
  );

  setUpAll(() {
    registerFallbackValue(fakeStore);
    registerFallbackValue(StoreColor.red);
  });

  setUp(() {
    mockStoreUseCase = MockStoreUseCase();
    container = ProviderContainer(
      overrides: [
        storeUseCaseProvider.overrideWith((ref) => mockStoreUseCase),
        currentUserProvider.overrideWith((ref) async => fakeUser),
      ],
    );
  });

  tearDown(() => container.dispose());

  StoreUpdateController notifierFor(Store store) =>
      container.read(storeUpdateControllerProvider(store).notifier);

  void stubUpdate(Either<Exception, void> result) {
    when(
      () => mockStoreUseCase.updateStore(
        original: any(named: 'original'),
        store: any(named: 'store'),
        color: any(named: 'color'),
        memo: any(named: 'memo'),
      ),
    ).thenAnswer((_) async => result);
  }

  group('submit', () {
    test('폼을 연 시점의 점포를 original로 넘기고 성공하면 true를 반환한다', () async {
      stubUpdate(right(null));
      final notifier = notifierFor(opened);
      notifier.setName('바뀐 점포명');

      final succeeded = await notifier.submit();

      expect(succeeded, isTrue);
      final captured = verify(
        () => mockStoreUseCase.updateStore(
          original: captureAny(named: 'original'),
          store: captureAny(named: 'store'),
          color: any(named: 'color'),
          memo: any(named: 'memo'),
        ),
      ).captured;
      expect(captured[0], opened);
      expect((captured[1] as Store).name, '바뀐 점포명');
    });

    test('실패하면 false를 반환하고 상태에 예외를 남긴다', () async {
      stubUpdate(left(StoreUpdateConflictException(message: '충돌')));
      final notifier = notifierFor(opened);

      final succeeded = await notifier.submit();

      expect(succeeded, isFalse);
      expect(
        container.read(storeUpdateControllerProvider(opened)).status.error,
        isA<StoreUpdateConflictException>(),
      );
    });
  });

  group('reloadLatest', () {
    final latest = opened.copyWith(
      name: '다른 관리자가 바꾼 점포명',
      address: '다른 관리자가 바꾼 주소',
    );

    test('최신 점포로 폼을 다시 채우고, 이후 저장은 최신 점포를 original로 쓴다', () async {
      when(() => mockStoreUseCase.getStoreForEdit(opened.id))
          .thenAnswer((_) async => right(latest));
      stubUpdate(right(null));
      final notifier = notifierFor(opened);
      notifier.setName('내가 바꾼 점포명');

      await notifier.reloadLatest();

      final state = container.read(storeUpdateControllerProvider(opened));
      expect(state.name, latest.name);
      expect(state.address, latest.address);
      expect(state.status.hasError, isFalse);

      await notifier.submit();
      final captured = verify(
        () => mockStoreUseCase.updateStore(
          original: captureAny(named: 'original'),
          store: any(named: 'store'),
          color: any(named: 'color'),
          memo: any(named: 'memo'),
        ),
      ).captured;
      expect(captured.single, latest);
    });

    test('점포가 삭제됐으면 상태에 StoreNotFoundException을 남긴다', () async {
      when(() => mockStoreUseCase.getStoreForEdit(opened.id)).thenAnswer(
        (_) async => left(StoreNotFoundException(message: '삭제된 점포')),
      );
      final notifier = notifierFor(opened);

      await notifier.reloadLatest();

      expect(
        container.read(storeUpdateControllerProvider(opened)).status.error,
        isA<StoreNotFoundException>(),
      );
    });
  });
}
