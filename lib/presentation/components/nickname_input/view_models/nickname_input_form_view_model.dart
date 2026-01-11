import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'nickname_input_form_view_model.g.dart';

@riverpod
class NicknameInputFormViewModel extends _$NicknameInputFormViewModel {
  /// 초기값을 주입받아 상태를 생성 (수정 모드 지원)
  @override
  String build(String? initialValue) {
    return initialValue ?? '';
  }

  void onNicknameChanged(String value) {
    state = value;
  }

  /// 엄격한 유효성 검사 (완성된 한글/영문/숫자만 허용, 자음/모음 불가)
  /// - 버튼 활성화 여부 결정용
  bool get isValid {
    final text = state.trim();
    if (text.isEmpty) return false;
    if (text.length > 10) return false;

    // DB 저장용 Strict Regex (ㄱ-ㅎ, ㅏ-ㅣ 제외)
    final regExp = RegExp(r'^[a-zA-Z0-9가-힣]+$');
    return regExp.hasMatch(text);
  }
}
