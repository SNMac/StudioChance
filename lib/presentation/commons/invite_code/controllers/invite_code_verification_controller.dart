import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/domain/use_cases/store_use_case_provider.dart';
import 'package:studio_chance/presentation/commons/invite_code/controllers/states/invite_code_verification_state.dart';

part 'invite_code_verification_controller.g.dart';

@riverpod
class InviteCodeVerificationController
    extends _$InviteCodeVerificationController {
  @override
  InviteCodeVerificationState build() {
    return const InviteCodeVerificationState();
  }

  void onCodeChanged(String value) {
    state = state.copyWith(inviteCode: value.toUpperCase());
  }

  Future<void> verifyInviteCode() async {
    state = state.copyWith(status: const AsyncLoading());

    final storeUseCase = ref.read(storeUseCaseProvider);
    final result = await storeUseCase.getStoreByInviteCode(state.inviteCode);

    result.fold(
      (exception) => state = state.copyWith(
        status: AsyncError(exception, StackTrace.current),
      ),
      (store) => state = state.copyWith(status: AsyncData(store)),
    );
  }
}
