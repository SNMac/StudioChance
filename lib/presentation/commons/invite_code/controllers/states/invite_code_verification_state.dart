import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/domain/entities/store.dart';

part 'invite_code_verification_state.freezed.dart';

@freezed
abstract class InviteCodeVerificationState with _$InviteCodeVerificationState {
  const InviteCodeVerificationState._();

  const factory InviteCodeVerificationState({
    @Default('') String inviteCode,
    @Default(AsyncData(null)) AsyncValue<Store?> status,
  }) = _InviteCodeVerificationState;

  bool get isValid {
    final text = inviteCode.trim();
    if (text.length != 6) return false;
    final regExp = RegExp(r'^[A-Z0-9]+$');
    return regExp.hasMatch(text);
  }
}
