import 'package:studio_chance/common/exceptions/store_exceptions.dart'; // 실제 경로에 맞게 수정

extension StoreExceptionExtension on StoreException {
  /// 사용자에게 보여줄 오류 제목
  String get title {
    return switch (this) {
      // 1. 권한/보안
      StorePermissionDeniedException() => '권한이 없습니다',

      // 2. 데이터 존재 여부
      StoreNotFoundException() => '점포를 찾을 수 없습니다',
      StoreAlreadyExistsException() => '이미 등록된 점포입니다',

      // 3. 네트워크/환경/리소스
      StoreNetworkException() => '네트워크 오류가 발생했습니다',
      StoreResourceExhaustedException() => '요청 한도가 초과되었습니다',

      // 4. 데이터 충돌/처리 실패/취소
      StoreTransactionException() => '처리에 실패했습니다',
      StoreCancelledException() => '작업이 취소되었습니다',

      // 5. 앱 버전/파싱 문제
      StoreDataParsingException() => '데이터 형식이 일치하지 않습니다',

      // 6. 기타
      StoreUnknownException() => '오류가 발생했습니다',
      _ => '오류가 발생했습니다',
    };
  }

  /// 사용자에게 보여줄 오류 내용
  String get content {
    return switch (this) {
      // 1. 권한 부족
      StorePermissionDeniedException() =>
        '이 작업을 수행할 권한이 없습니다.\n개발자에게 문의하거나 다시 로그인해 주세요.',

      // 2. 데이터 상태
      StoreNotFoundException() => '이미 삭제되었거나 존재하지 않는 점포입니다.',
      StoreAlreadyExistsException() => '이미 등록된 점포 정보입니다.',

      // 3. 네트워크 및 리소스 이슈
      StoreNetworkException() => '인터넷 연결 상태를 확인해주세요.',
      StoreResourceExhaustedException() =>
        '잠시 후 다시 시도해 주세요.\n문제가 지속되면 개발자에게 문의해 주세요.',

      // 4. 처리 과정
      StoreTransactionException() => '일시적인 충돌이 발생했습니다.\n잠시 후 다시 시도해 주세요.',
      StoreCancelledException() => '작업이 중단되었습니다.',

      // 5. 파싱 에러
      StoreDataParsingException() =>
        '스토어에서 최신 버전으로 업데이트해주세요.\n문제가 지속되면 개발자에게 문의해 주세요.',

      // 6. 알 수 없는 오류
      StoreUnknownException() => '알 수 없는 오류가 발생했습니다.\n잠시 후 다시 시도해 주세요.',
      _ => '일시적인 오류가 발생했습니다.\n잠시 후 다시 시도해 주세요.',
    };
  }

  /// UI 표시 여부
  bool get isSilentable {
    return switch (this) {
      StoreCancelledException() => true,
      _ => false,
    };
  }
}
