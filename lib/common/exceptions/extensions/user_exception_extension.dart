import 'package:studio_chance/common/exceptions/user_exceptions.dart';

extension UserExceptionExtension on UserException {
  /// 사용자에게 보여줄 에러 제목 (문장형 종결, 마침표 없음)
  String get title {
    return switch (this) {
      // 1. 권한/보안
      UserPermissionDeniedException() => '권한이 없습니다',

      // 2. 데이터 존재 여부
      UserNotFoundException() => '사용자를 찾을 수 없습니다',
      UserAlreadyExistsException() => '이미 등록된 사용자입니다',

      // 3. 네트워크/환경/리소스
      UserNetworkException() => '네트워크 에러가 발생했습니다',
      UserResourceExhaustedException() => '요청 한도가 초과되었습니다',

      // 4. 데이터 충돌/처리 실패/취소
      UserTransactionException() => '처리에 실패했습니다',
      UserCancelledException() => '작업이 취소되었습니다',

      // 5. 앱 버전/파싱 문제
      UserDataParsingException() => '데이터 형식이 일치하지 않습니다',

      // 6. 기타
      UserUnknownException() => '에러가 발생했습니다',
      _ => '에러가 발생했습니다',
    };
  }

  /// 사용자에게 보여줄 에러 내용
  String get content {
    return switch (this) {
      // 1. 권한 부족
      UserPermissionDeniedException() =>
        '이 작업을 수행할 권한이 없습니다.\n문제가 지속되면 개발자에게 문의해주세요.',

      // 2. 데이터 상태 (없음 / 이미 있음)
      UserNotFoundException() => '이미 삭제되었거나 존재하지 않는 사용자입니다.',
      UserAlreadyExistsException() => '이미 서버에 등록된 사용자입니다.',

      // 3. 네트워크 및 리소스 이슈
      UserNetworkException() => '인터넷 연결 상태를 확인해주세요.',
      UserResourceExhaustedException() =>
        '잠시 후 다시 시도해주세요.\n문제가 지속되면 개발자에게 문의해주세요.',

      // 4. 처리 과정 (충돌 / 취소)
      UserTransactionException() => '일시적인 충돌이 발생했습니다.\n잠시 후 다시 시도해주세요.',
      UserCancelledException() => '작업이 중단되었습니다.',

      // 5. 파싱 에러 (업데이트 유도)
      UserDataParsingException() =>
        '스토어에서 최신 버전으로 업데이트해주세요.\n문제가 지속되면 개발자에게 문의해주세요.',

      // 6. 알 수 없는 에러
      UserUnknownException() => '알 수 없는 에러가 발생했습니다.\n잠시 후 다시 시도해주세요.',
      _ => '일시적인 에러가 발생했습니다.\n잠시 후 다시 시도해주세요.',
    };
  }

  /// UI 표시 여부
  /// - true: 사용자에게 알리지 않고(로그만 남기고) 넘어감
  /// - false: 사용자에게 다이얼로그나 스낵바로 알려야 함
  bool get isSilentable {
    return switch (this) {
      // Firestore 작업 취소(cancelled)는 에러 메시지를 띄우지 않음
      UserCancelledException() => true,
      _ => false,
    };
  }
}
