import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'invite_code_form_state.freezed.dart';

@freezed
abstract class InviteCodeFormState with _$InviteCodeFormState {
  const InviteCodeFormState._();

  const factory InviteCodeFormState({
    @Default('') String inviteCode,
    @Default(AsyncValue.data(null)) AsyncValue<void> status,
  }) = _InviteCodeFormState;

  bool get isValid {
    final text = inviteCode.trim();
    if (text.length != 6) return false;
    final regExp = RegExp(r'^[A-Z0-9]+$');
    return regExp.hasMatch(text);
  }
}
