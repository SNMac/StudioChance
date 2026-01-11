import 'package:freezed_annotation/freezed_annotation.dart';

part 'nickname_input_form_state.freezed.dart';

@freezed
abstract class NicknameInputFormState with _$NicknameInputFormState {
  const NicknameInputFormState._();

  const factory NicknameInputFormState({@Default('') String nickname}) =
      _NicknameInputFormState;

  bool get isValid {
    final text = nickname.trim();

    if (text.isEmpty) return false;
    if (text.length > 10) return false;

    final regExp = RegExp(r'^[a-zA-Z0-9가-힣]+$');
    return regExp.hasMatch(text);
  }
}
