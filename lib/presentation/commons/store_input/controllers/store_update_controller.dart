import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/common/enums/store_color.dart';
import 'package:studio_chance/domain/use_cases/store_use_case_provider.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_form_controllerable.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/states/store_form_state.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';
import 'package:studio_chance/presentation/providers/store_detail_provider.dart';

part 'store_update_controller.g.dart';

@riverpod
class StoreUpdateController extends _$StoreUpdateController
    with StoreFormMixin
    implements StoreFormControllerable {
  /// 수정 폼을 연 시점의 점포. 저장 시 동시 수정 판정의 기준이 되며(D13),
  /// 충돌 후 [reloadLatest]하면 그때 불러온 점포로 바뀐다
  late Store _original;

  @override
  StoreFormState build(Store store) {
    _original = store;
    return _stateOf(store);
  }

  StoreFormState _stateOf(Store store) {
    final currentUser = ref.read(currentUserProvider).value;
    StoreColor color = StoreColor.red;
    String memo = '';

    if (currentUser != null) {
      final storeInfo = currentUser.storeInfos
          .where((e) => e.id == store.id)
          .firstOrNull;
      color = storeInfo?.color ?? StoreColor.red;
      memo = storeInfo?.memo ?? '';
    }

    return StoreFormState(
      name: store.name,
      address: store.address,
      addressDetail: store.addressDetail,
      addressGuide: store.addressGuide,
      memo: memo,
      color: color,
      spaceOptions: store.spaceOptions,
      bankName: store.bankName ?? '',
      bankAccountNumber: store.bankAccountNumber ?? '',
      bankAccountHolder: store.bankAccountHolder ?? '',
      paymentDeadlineMinutes: store.paymentDeadlineMinutes,
      infoNotes: store.infoNotes ?? '',
      cautionNotes: store.cautionNotes ?? '',
    );
  }

  @override
  ({Store store, StoreColor color, String memo})? getFormData() {
    if (!state.isValid) return null;

    final updatedStore = _original.copyWith(
      // 사용자가 끝에 친 공백이 그대로 저장되면 알림 문구 등에서 공백이
      // 겹친다. 중복 검사도 trim한 값으로 하므로 저장도 맞춘다.
      name: state.name.trim(),
      address: state.address,
      addressDetail: state.addressDetail,
      addressGuide: state.addressGuide,
      spaceOptions: state.spaceOptions,
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

    return (store: updatedStore, color: state.color, memo: state.memo);
  }

  @override
  Future<bool> submit() async {
    final data = getFormData();
    if (data == null) return false;

    state = state.copyWith(status: const AsyncLoading());

    try {
      final storeUseCase = ref.read(storeUseCaseProvider);
      final result = await storeUseCase.updateStore(
        original: _original,
        store: data.store,
        color: data.color,
        memo: data.memo,
      );
      final stackTrace = StackTrace.current;
      return result.fold<bool>(
        (exception) {
          state = state.copyWith(status: AsyncError(exception, stackTrace));
          return false;
        },
        (_) {
          // 점포명·색상·메모는 사용자 문서의 storeById에서 읽어 화면에 보여준다
          ref.invalidate(currentUserProvider);
          ref.invalidate(storeDetailProvider(_original.id));
          state = state.copyWith(status: const AsyncData(null));
          return true;
        },
      );
    } catch (e, st) {
      state = state.copyWith(status: AsyncError(e, st));
      return false;
    }
  }

  /// 다른 관리자가 먼저 저장해 충돌했을 때 최신 점포로 폼을 다시 채운다.
  /// 사용자가 고친 내용은 버린다 — 요금표는 중첩 구조라 병합하면 상대의 변경이 조용히 사라진다
  Future<void> reloadLatest() async {
    state = state.copyWith(status: const AsyncLoading());

    final result = await ref
        .read(storeUseCaseProvider)
        .getStoreForEdit(_original.id);
    final stackTrace = StackTrace.current;
    result.fold(
      (exception) =>
          state = state.copyWith(status: AsyncError(exception, stackTrace)),
      (latest) {
        _original = latest;
        state = _stateOf(latest);
      },
    );
  }
}
