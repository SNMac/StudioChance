import 'package:studio_chance/common/exceptions/auth_exceptions.dart';

extension AuthExceptionExtension on AuthException {
  /// 사용자에게 보여줄 오류 제목
  String get title {
    return switch (this) {
      AuthCancelledException() => '로그인이 취소되었습니다',
      AuthRequiresRecentLoginException() => '재인증이 필요합니다',
      AuthInvalidCredentialException() => '로그인에 실패했습니다',
      AuthUserDisabledException() => '사용이 중지된 계정입니다',
      AuthUserNotFoundException() => '가입된 계정이 없습니다',
      AuthOperationNotAllowedException() => '서버에 오류가 발생했습니다',
      AuthNetworkException() => '네트워크에 오류가 발생했습니다',
      AuthTooManyRequestsException() => '요청 과다',
      AuthMethodNotSupportedException() => '지원하지 않는 환경입니다',
      _ => '로그인 중 오류가 발생했습니다',
    };
  }

  /// 사용자에게 보여줄 오류 내용
  String get content {
    return switch (this) {
      // 1. 시스템/설정 오류
      AuthOperationNotAllowedException() => '문제가 지속될 경우 개발자에게 문의해주세요.',

      // 2. 사용자/계정 이슈
      AuthMethodNotSupportedException() => '다른 기기로 시도해주세요.',
      AuthInvalidCredentialException() => '로그인 정보를 다시 확인해주세요.',
      AuthUserDisabledException() => '개발자에게 문의해주세요.',
      AuthUserNotFoundException() => '회원가입을 진행해주세요.',
      AuthRequiresRecentLoginException() => '보안을 위해 다시 로그인한 후 시도해주세요.',

      // 3. 일시적 환경 문제
      AuthNetworkException() => '네트워크 연결 상태를 확인하고 다시 시도해주세요.',
      AuthTooManyRequestsException() => '잠시 후 다시 시도해주세요.',

      // 4. 취소
      AuthCancelledException() => '작업이 취소되었습니다.',

      // 5. 기타
      _ => '잠시 후 다시 시도해주세요.',
    };
  }

  /// UI 표시 여부
  bool get isSilent {
    return switch (this) {
      AuthCancelledException() => true,
      _ => false,
    };
  }
}
