/// 인증 관련 최상위 예외
abstract class AuthException implements Exception {
  /// 개발자/로그용 원본 메시지
  final String message;

  /// 개발자/로그용 원본 에러 코드
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
  AuthCancelledException({String message = 'Auth cancelled', String? code})
    : super(message, code: code);
}

class AuthRequiresRecentLoginException extends AuthException {
  AuthRequiresRecentLoginException({required String message, String? code})
    : super(message, code: code);
}

class AuthInvalidCredentialException extends AuthException {
  AuthInvalidCredentialException({required String message, String? code})
    : super(message, code: code);
}

class AuthUserDisabledException extends AuthException {
  AuthUserDisabledException({required String message, String? code})
    : super(message, code: code);
}

class AuthUserNotFoundException extends AuthException {
  AuthUserNotFoundException({required String message, String? code})
    : super(message, code: code);
}

class AuthOperationNotAllowedException extends AuthException {
  AuthOperationNotAllowedException({required String message, String? code})
    : super(message, code: code);
}

class AuthNetworkException extends AuthException {
  AuthNetworkException({required String message, String? code})
    : super(message, code: code);
}

class AuthTooManyRequestsException extends AuthException {
  AuthTooManyRequestsException({required String message, String? code})
    : super(message, code: code);
}

class AuthMethodNotSupportedException extends AuthException {
  AuthMethodNotSupportedException({
    String message = 'Method not supported',
    String? code,
  }) : super(message, code: code);
}

class AuthUnknownException extends AuthException {
  AuthUnknownException({required String message, String? code})
    : super(message, code: code);
}
