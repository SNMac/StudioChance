import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/common/enums/store_color.dart';
import 'package:studio_chance/domain/entities/invite_store_preview.dart';

part 'invite_code_verification_state.freezed.dart';

@freezed
abstract class InviteCodeVerificationState with _$InviteCodeVerificationState {
  const InviteCodeVerificationState._();

  const factory InviteCodeVerificationState({
    @Default('') String inviteCode,
    @Default(AsyncData(null)) AsyncValue<InviteStorePreview?> status,
    @Default('') String storeAlias,
    @Default(StoreColor.red) StoreColor color,
    @Default('') String memo,
    // 초대 코드 조회(status)와 분리한다. status를 재사용하면 스택에 남아 있는
    // 초대 코드 입력 화면의 ref.listen이 제출 완료를 조회 성공으로 오인해
    // 점포 확인 화면을 한 번 더 push한다.
    @Default(AsyncData(null)) AsyncValue<void> submitStatus,
  }) = _InviteCodeVerificationState;

  bool get isValid {
    final text = inviteCode.trim();
    if (text.length != 6) return false;
    final regExp = RegExp(r'^[A-Z0-9]+$');
    return regExp.hasMatch(text);
  }

  /// 가입 신청 제출 가능 여부 (제출 중이면 false — 중복 제출 차단)
  bool get canSubmit =>
      status.value != null &&
      storeAlias.trim().isNotEmpty &&
      !submitStatus.isLoading;
}
