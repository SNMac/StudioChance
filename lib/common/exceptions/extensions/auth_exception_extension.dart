import 'package:studio_chance/common/exceptions/auth_exceptions.dart';

extension AuthExceptionExtension on AuthException {
  /// 사용자에게 보여줄 에러 제목 (문장형 종결, 마침표 없음)
  String get title {
    return switch (this) {
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
  }

  /// 사용자에게 보여줄 에러 내용
  String get content {
    return switch (this) {
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
  }

  /// UI 표시 여부
  /// - true: 사용자에게 알리지 않고(로그만 남기고) 넘어감
  /// - false: 사용자에게 다이얼로그나 스낵바로 알려야 함
  bool get isSilentable {
    return switch (this) {
      // 사용자가 스스로 취소한 경우는 에러 메시지를 띄우지 않음
      AuthCancelledException() => true,

      // 그 외의 모든 에러 표시
      _ => false,
    };
  }
}
