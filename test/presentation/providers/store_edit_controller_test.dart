import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/common/exceptions/store_exceptions.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/use_cases/store_use_case.dart';
import 'package:studio_chance/domain/use_cases/store_use_case_provider.dart';
import 'package:studio_chance/presentation/providers/store_edit_controller.dart';

import '../../helpers/fake_entities.dart';

class MockStoreUseCase extends Mock implements StoreUseCase {}

void main() {
  late MockStoreUseCase mockStoreUseCase;
  late ProviderContainer container;

  setUp(() {
    mockStoreUseCase = MockStoreUseCase();
    container = ProviderContainer(
      overrides: [storeUseCaseProvider.overrideWith((ref) => mockStoreUseCase)],
    );
  });

  tearDown(() => container.dispose());

  Future<Either<Exception, Store>> load() => container
      .read(storeEditControllerProvider.notifier)
      .loadStoreForEdit(fakeStore.id);

  test('점포를 새로 조회해 돌려준다', () async {
    when(
      () => mockStoreUseCase.getStore(fakeStore.id),
    ).thenAnswer((_) async => right(fakeStore));

    expect((await load()).toNullable(), fakeStore);
  });

  test('삭제된 점포면 StoreNotFoundException으로 실패한다', () async {
    when(
      () => mockStoreUseCase.getStore(fakeStore.id),
    ).thenAnswer((_) async => right(null));

    expect(
      (await load()).getLeft().toNullable(),
      isA<StoreNotFoundException>(),
    );
  });

  test('조회에 실패하면 그 예외를 그대로 돌려준다', () async {
    final error = StoreNetworkException(message: '네트워크');
    when(
      () => mockStoreUseCase.getStore(fakeStore.id),
    ).thenAnswer((_) async => left(error));

    expect((await load()).getLeft().toNullable(), error);
  });
}
