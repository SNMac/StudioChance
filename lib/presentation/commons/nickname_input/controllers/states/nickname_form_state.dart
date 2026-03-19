import 'package:freezed_annotation/freezed_annotation.dart';

part 'nickname_form_state.freezed.dart';

@freezed
abstract class NicknameFormState with _$NicknameFormState {
  const NicknameFormState._();

  const factory NicknameFormState({@Default('') String nickname}) =
      _NicknameFormState;

  bool get isValid {
    final text = nickname.trim();
    if (text.isEmpty) return false;
    if (text.length > 10) return false;
    // 한글, 영문, 숫자만 허용 (자음/모음 단독 불가: ㄱ-ㅎ, ㅏ-ㅣ 제외)
    final regExp = RegExp(r'^[a-zA-Z0-9가-힣]+$');
    return regExp.hasMatch(text);
  }
}
