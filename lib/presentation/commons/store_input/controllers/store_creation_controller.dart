import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import 'package:studio_chance/domain/entities/price_setting.dart';
import 'package:studio_chance/domain/entities/space_option.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/common/enums/store_color.dart';
import 'package:studio_chance/domain/use_cases/store_use_case_provider.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_form_controllerable.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/states/store_form_state.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';

part 'store_creation_controller.g.dart';

@riverpod
class StoreCreationController extends _$StoreCreationController
    with StoreFormMixin
    implements StoreFormControllerable {
  @override
  StoreFormState build() {
    final defaultId = const Uuid().v4();
    return StoreFormState(
      color: StoreColor.red,
      spaceOptions: [
        SpaceOption(
          id: defaultId,
          name: '기본 공간',
          priceSetting: PriceSetting.empty(),
        ),
      ],
    );
  }

  @override
  ({Store store, StoreColor color, String memo})? getFormData() {
    if (!state.isValid) return null;

    final store = Store(
      id: '',
      // 사용자가 끝에 친 공백이 그대로 저장되면 알림 문구 등에서 공백이
      // 겹친다. 중복 검사도 trim한 값으로 하므로 저장도 맞춘다.
      name: state.name.trim(),
      address: state.address,
      addressDetail: state.addressDetail,
      addressGuide: state.addressGuide,
      spaceOptions: state.spaceOptions,
      memberInfos: [],
      waitingMemberInfos: [],
      inviteInfo: null,
      bankName: state.bankName.isEmpty ? null : state.bankName,
      bankAccountNumber: state.bankAccountNumber.isEmpty
          ? null
          : state.bankAccountNumber,
      bankAccountHolder: state.bankAccountHolder.isEmpty
          ? null
          : state.bankAccountHolder,
      paymentDeadlineMinutes: state.paymentDeadlineMinutes,
      infoNotes: state.infoNotes.isEmpty ? null : state.infoNotes,
      cautionNotes: state.cautionNotes.isEmpty ? null : state.cautionNotes,
    );

    return (store: store, color: state.color, memo: state.memo);
  }

  @override
  Future<void> submit() async {
    final data = getFormData();
    if (data == null) return;

    state = state.copyWith(status: const AsyncLoading());

    try {
      final storeUseCase = ref.read(storeUseCaseProvider);

      final result = await storeUseCase.createStore(
        store: data.store,
        color: data.color,
        memo: data.memo,
      );
      final stackTrace = StackTrace.current;

      result.fold(
        (exception) =>
            state = state.copyWith(status: AsyncError(exception, stackTrace)),
        (_) {
          ref.invalidate(currentUserProvider);
          state = state.copyWith(status: const AsyncData(null));
        },
      );
    } catch (e, st) {
      state = state.copyWith(status: AsyncError(e, st));
    }
  }
}
