import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/presentation/components/nickname_input/view_models/nickname_input_form_state.dart';

part 'nickname_input_form_view_model.g.dart';

@riverpod
class NicknameInputFormViewModel extends _$NicknameInputFormViewModel {
  /// 초기값을 주입받아 상태를 생성 (수정 모드 지원)
  @override
  NicknameInputFormState build(String? initialValue) {
    return NicknameInputFormState(nickname: initialValue ?? '');
  }

  void onNicknameChanged(String value) {
    // Freezed의 copyWith를 사용하여 안전하게 상태 업데이트
    state = state.copyWith(nickname: value);
  }
}
