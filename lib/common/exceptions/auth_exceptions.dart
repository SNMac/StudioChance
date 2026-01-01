/// 인증 관련 최상위 예외
abstract class AuthException implements Exception {
  /// 개발자가 볼 상세 메시지 (한글)
  final String message;
  /// 원본 에러 코드 (디버깅용)
  final String? code;

  AuthException(this.message, {this.code});

  @override
  String toString() =>
      '[$runtimeType] $message ${code != null ? '(Code: $code)' : ''}';
}

// -----------------------------------------------------------------------------
// Exception classes
// -----------------------------------------------------------------------------

class AuthCancelledException extends AuthException {
  AuthCancelledException({String? message, String? code})
    : super(message ?? '사용자에 의해 인증 과정이 취소되었습니다.', code: code);
}

class AuthRequiresRecentLoginException extends AuthException {
  AuthRequiresRecentLoginException({String? message, String? code})
    : super(message ?? '보안에 민감한 작업을 위해 재인증(로그인)이 필요합니다.', code: code);
}

class AuthInvalidCredentialException extends AuthException {
  AuthInvalidCredentialException({String? message, String? code})
    : super(message ?? '제공된 인증 정보(토큰, 비밀번호 등)가 유효하지 않습니다.', code: code);
}

class AuthUserDisabledException extends AuthException {
  AuthUserDisabledException({String? message, String? code})
    : super(message ?? '해당 계정은 비활성화(Ban) 상태입니다.', code: code);
}

class AuthUserNotFoundException extends AuthException {
  AuthUserNotFoundException({String? message, String? code})
    : super(message ?? '해당 식별자(UID/Email)를 가진 유저를 찾을 수 없습니다.', code: code);
}

class AuthOperationNotAllowedException extends AuthException {
  AuthOperationNotAllowedException({String? message, String? code})
    : super(
        message ?? 'Firebase Console에서 해당 로그인 제공업체가 활성화되지 않았습니다.',
        code: code,
      );
}

class AuthNetworkException extends AuthException {
  AuthNetworkException({String? message, String? code})
    : super(message ?? '네트워크 연결이 불안정하거나 타임아웃이 발생했습니다.', code: code);
}

class AuthTooManyRequestsException extends AuthException {
  AuthTooManyRequestsException({String? message, String? code})
    : super(message ?? '짧은 시간 내에 너무 많은 요청이 발생하여 차단되었습니다.', code: code);
}

class AuthMethodNotSupportedException extends AuthException {
  AuthMethodNotSupportedException({String? message, String? code})
    : super(message ?? '현재 기기 또는 환경에서 해당 로그인 방식을 지원하지 않습니다.', code: code);
}

class AuthUnknownException extends AuthException {
  AuthUnknownException({required String message, String? code})
    : super(message, code: code);
}
