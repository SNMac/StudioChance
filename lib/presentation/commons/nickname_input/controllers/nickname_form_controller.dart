import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/presentation/commons/nickname_input/controllers/states/nickname_form_state.dart';

part 'nickname_form_controller.g.dart';

@riverpod
class NicknameFormController extends _$NicknameFormController {
  @override
  NicknameFormState build(String? initialValue) {
    return NicknameFormState(nickname: initialValue ?? '');
  }

  void onNicknameChanged(String value) {
    state = state.copyWith(nickname: value);
  }
}