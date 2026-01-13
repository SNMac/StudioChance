import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/enums/store_color.dart';
import 'package:studio_chance/domain/use_cases/store_use_case.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';

part 'store_creation_controller.g.dart';

@riverpod
class StoreCreationController extends _$StoreCreationController {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  /// 점포 생성 제출
  /// [formData] : StoreInputFormViewModel에서 getFormData()로 만든 결과값
  Future<void> submit(({Store store, StoreColor color}) formData) async {
    state = const AsyncValue.loading();

    try {
      final storeUseCase = ref.read(storeUseCaseProvider);

      final createResult = await storeUseCase.createStore(
        store: formData.store,
        color: formData.color,
      );

      if (createResult.isLeft()) throw createResult.getLeft().toNullable()!;

      // 5. 성공 처리 (인증 상태 갱신 -> 홈으로 이동됨)
      state = const AsyncValue.data(null);

      // AuthController를 갱신하여 GoRouter가 redirect를 수행하도록 함
      ref.invalidate(appAuthControllerProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
