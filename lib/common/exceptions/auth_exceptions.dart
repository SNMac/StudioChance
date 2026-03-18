import 'package:studio_chance/common/exceptions/app_exception.dart';

/// 인증 관련 최상위 예외
abstract class AuthException extends AppException {
  AuthException(super.message, {super.code});

  @override
  String get title => switch (this) {
    // 1. 입력/자격증명 관련
    AuthInvalidEmailException() => '이메일 형식이 올바르지 않습니다',
    AuthWrongPasswordException() => '비밀번호가 일치하지 않습니다',
    AuthInvalidCredentialException() => '로그인 정보가 만료되었습니다',

    // 2. 계정 상태/존재 여부
    AuthUserNotFoundException() => '계정을 찾을 수 없습니다',
    AuthUserDisabledException() => '계정이 정지되었습니다',
    AuthEmailAlreadyInUseException() => '이미 가입된 이메일입니다',
    AuthRequiresRecentLoginException() => '재인증이 필요합니다',

    // 3. 연동 관련
    AuthCredentialAlreadyInUseException() ||
    AuthProviderAlreadyLinkedException() => '계정 연동에 실패했습니다',

    // 4. 네트워크 및 기타
    AuthNetworkException() => '네트워크 에러가 발생했습니다',
    AuthTooManyRequestsException() => '요청 횟수가 초과되었습니다',
    AuthCancelledException() => '로그인이 취소되었습니다',
    AuthMethodNotSupportedException() => '지원하지 않는 기능입니다',
    AuthOperationNotAllowedException() => '서버 에러가 발생했습니다',

    // 5. 기본
    _ => '로그인에 실패했습니다',
  };

  @override
  String get content => switch (this) {
    // 1. 입력값 에러
    AuthInvalidEmailException() => '이메일 주소를 올바르게 입력해주세요.',
    AuthWrongPasswordException() => '비밀번호가 일치하지 않습니다.\n다시 확인해주세요.',
    AuthEmailAlreadyInUseException() => '다른 이메일로 시도해주세요.',

    // 2. 계정 연동 에러
    AuthCredentialAlreadyInUseException() => '이미 다른 사용자가 쓰고 있는 소셜 계정입니다.',
    AuthProviderAlreadyLinkedException() => '이미 현재 계정에 연결되어 있습니다.',

    // 3. 일반적인 자격 증명 에러
    AuthInvalidCredentialException() => '인증 정보가 만료되었습니다.\n다시 로그인해주세요.',

    // 4. 사용자 상태 에러
    AuthUserNotFoundException() => '가입된 정보가 없습니다.\n회원가입을 진행해주세요.',
    AuthUserDisabledException() => '운영 정책에 의해 정지된 계정입니다.\n개발자에게 문의해주세요.',
    AuthRequiresRecentLoginException() => '정보 보호를 위해 재로그인이 필요합니다.',

    // 5. 네트워크 및 기타
    AuthNetworkException() => '인터넷 연결 상태를 확인해주세요.',
    AuthTooManyRequestsException() => '잠시 후 다시 시도해주세요.',
    AuthOperationNotAllowedException() => '일시적인 에러입니다. 나중에 다시 시도해주세요.',
    AuthCancelledException() => '로그인 과정이 중단되었습니다.',
    AuthMethodNotSupportedException() => '현재 기기에서는 지원하지 않는 기능입니다.',

    _ => '일시적인 에러가 발생했습니다.\n잠시 후 다시 시도해주세요.',
  };

  @override
  bool get isSilentable => switch (this) {
    // 사용자가 스스로 취소한 경우는 에러 메시지를 띄우지 않음
    AuthCancelledException() => true,
    _ => false,
  };
}

// -----------------------------------------------------------------------------
// Exception classes
// -----------------------------------------------------------------------------

/// 사용자가 로그인/인증 과정을 도중에 취소했을 때 발생하는 예외
///
/// 예: 구글 로그인 팝업을 닫거나, Apple 로그인 프롬프트에서 취소를 누른 경우
class AuthCancelledException extends AuthException {
  AuthCancelledException({String message = 'Auth cancelled', String? code})
    : super(message, code: code);
}

/// 보안에 민감한 작업 수행 전, 재인증이 필요할 때 발생하는 예외
///
/// 예: 계정 삭제, 비밀번호 변경 등은 로그인한 지 오래된 경우 재인증을 요구합니다.
/// Firebase Code: `requires-recent-login`
class AuthRequiresRecentLoginException extends AuthException {
  AuthRequiresRecentLoginException({required String message, String? code})
    : super(message, code: code);
}

/// 계정이 정지되거나 비활성화되었을 때 발생하는 예외
///
/// 관리자에 의해 계정이 차단된 경우 발생합니다.
/// Firebase Code: `user-disabled`
class AuthUserDisabledException extends AuthException {
  AuthUserDisabledException({required String message, String? code})
    : super(message, code: code);
}

/// 해당 정보와 일치하는 사용자를 찾을 수 없을 때 발생하는 예외
///
/// 주로 이메일 로그인 시 가입되지 않은 이메일을 입력했을 때 발생합니다.
/// Firebase Code: `user-not-found`
class AuthUserNotFoundException extends AuthException {
  AuthUserNotFoundException({required String message, String? code})
    : super(message, code: code);
}

/// 해당 인증 제공업체(Provider)가 활성화되지 않았을 때 발생하는 예외
///
/// Firebase Console > Auth > Sign-in method 탭에서 해당 로그인을 활성화해야 합니다.
/// Firebase Code: `operation-not-allowed`
class AuthOperationNotAllowedException extends AuthException {
  AuthOperationNotAllowedException({required String message, String? code})
    : super(message, code: code);
}

/// 네트워크 연결이 불안정하거나 끊겼을 때 발생하는 예외
///
/// Firebase Code: `network-request-failed`
class AuthNetworkException extends AuthException {
  AuthNetworkException({required String message, String? code})
    : super(message, code: code);
}

/// 짧은 시간 동안 너무 많은 요청을 보냈을 때 발생하는 예외
///
/// 기기를 보호하기 위해 서버에서 일시적으로 요청을 차단한 상태입니다.
/// Firebase Code: `too-many-requests`
class AuthTooManyRequestsException extends AuthException {
  AuthTooManyRequestsException({required String message, String? code})
    : super(message, code: code);
}

/// 알 수 없는 에러가 발생했을 때 사용하는 예외
///
/// 정의되지 않은 에러 코드나 시스템 내부 에러 등을 포괄합니다.
class AuthUnknownException extends AuthException {
  AuthUnknownException({required String message, String? code})
    : super(message, code: code);
}

/// 현재 환경에서 지원하지 않는 인증 방식을 시도했을 때 발생하는 예외
///
/// 예: 시뮬레이터에서 지원하지 않는 기능 호출 등
class AuthMethodNotSupportedException extends AuthException {
  AuthMethodNotSupportedException({
    String message = 'Method not supported',
    String? code,
  }) : super(message, code: code);
}

// -----------------------------------------------------------------------------
// 로그인/회원가입 입력값 관련 Exception
// -----------------------------------------------------------------------------

/// 이메일 형식이 올바르지 않을 때 발생하는 예외
///
/// Firebase Code: `invalid-email`
class AuthInvalidEmailException extends AuthException {
  AuthInvalidEmailException({required String message, String? code})
    : super(message, code: code);
}

/// 비밀번호가 일치하지 않을 때 발생하는 예외
///
/// Firebase Code: `wrong-password`
class AuthWrongPasswordException extends AuthException {
  AuthWrongPasswordException({required String message, String? code})
    : super(message, code: code);
}

/// 이미 가입된 이메일로 회원가입을 시도했을 때 발생하는 예외
///
/// Firebase Code: `email-already-in-use`
class AuthEmailAlreadyInUseException extends AuthException {
  AuthEmailAlreadyInUseException({required String message, String? code})
    : super(message, code: code);
}

// -----------------------------------------------------------------------------
// 자격 증명 및 연동 관련 Exception
// -----------------------------------------------------------------------------

/// 자격 증명(Credential) 자체가 유효하지 않을 때 발생하는 예외
///
/// 토큰이 만료되었거나, 변조되었거나, 인증 정보가 불일치할 때 발생합니다.
/// Firebase Code: `invalid-credential`, `user-mismatch`, `no-such-provider` 등
class AuthInvalidCredentialException extends AuthException {
  AuthInvalidCredentialException({required String message, String? code})
    : super(message, code: code);
}

/// 연동하려는 소셜 계정이 이미 '다른' 사용자 계정에 연결되어 있을 때 발생하는 예외
///
/// 예: 내 계정에 구글을 연동하려는데, 그 구글 계정이 이미 다른 사람 아이디로 가입되어 있음.
/// Firebase Code: `credential-already-in-use`, `account-exists-with-different-credential`
class AuthCredentialAlreadyInUseException extends AuthException {
  AuthCredentialAlreadyInUseException({required String message, String? code})
    : super(message, code: code);
}

/// 연동하려는 제공업체가 이미 '현재' 사용자 계정에 연결되어 있을 때 발생하는 예외
///
/// 예: 이미 구글 연동이 된 상태에서 다시 구글 연동을 시도함.
/// Firebase Code: `provider-already-linked`
class AuthProviderAlreadyLinkedException extends AuthException {
  AuthProviderAlreadyLinkedException({required String message, String? code})
    : super(message, code: code);
}
