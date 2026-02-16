import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/presentation/commons/invite_code/controllers/states/invite_code_form_state.dart';

part 'invite_code_form_controller.g.dart';

@riverpod
class InviteCodeFormController extends _$InviteCodeFormController {
  @override
  InviteCodeFormState build() {
    return const InviteCodeFormState();
  }

  void onCodeChanged(String value) {
    state = state.copyWith(inviteCode: value.toUpperCase());
  }

  void submit() {
    state = state.copyWith(status: const AsyncLoading());
  }
}
