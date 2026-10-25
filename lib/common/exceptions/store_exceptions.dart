import 'package:studio_chance/common/exceptions/app_exception.dart';

/// 점포(DB) 관련 최상위 예외
sealed class StoreException extends AppException {
  StoreException(super.message, {super.code});

  @override
  String get title => switch (this) {
    // 1. 권한/보안
    StorePermissionDeniedException() => '권한이 없습니다',

    // 2. 데이터 존재 여부
    StoreNotFoundException() => '점포를 찾을 수 없습니다',
    StoreAlreadyExistsException() => '이미 등록된 점포입니다',

    // 3. 네트워크/환경/리소스
    StoreNetworkException() => '네트워크 에러가 발생했습니다',
    StoreResourceExhaustedException() => '요청 한도가 초과되었습니다',

    // 4. 데이터 충돌/처리 실패/취소
    StoreTransactionException() => '처리에 실패했습니다',
    StoreUpdateConflictException() => '다른 관리자가 먼저 수정했습니다',
    StoreCancelledException() => '작업이 취소되었습니다',

    // 5. 앱 버전/파싱 문제
    StoreDataParsingException() => '데이터 형식이 일치하지 않습니다',

    // 7. 중복 검증
    StoreNameDuplicateException() => '이미 사용 중인 점포명입니다',
    SpaceNameDuplicateException() => '중복된 공간명이 있습니다',

    // 6. 유효성 검사 / 알 수 없는 에러
    StoreInviteCodeExpiredException() => '만료된 초대 코드입니다',
    StoreValidationException() || StoreUnknownException() => '에러가 발생했습니다',

    // 8. 관리자 1명 규칙
    StoreAdminRoleChangeException() => '관리자 역할은 위임으로만 바꿀 수 있습니다',
    StoreAdminHandoverRequiredException() => '관리자 위임 또는 점포 삭제가 필요합니다',
    StoreDelegationTargetInvalidException() => '위임할 수 없는 멤버입니다',
  };

  @override
  String get content => switch (this) {
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
    StoreUpdateConflictException() =>
      '최신 점포 정보를 다시 불러옵니다.\n수정한 내용을 다시 입력해 주세요.',
    StoreCancelledException() => '작업이 중단되었습니다.',

    // 5. 파싱 에러
    StoreDataParsingException() =>
      '스토어에서 최신 버전으로 업데이트해주세요.\n문제가 지속되면 개발자에게 문의해 주세요.',

    // 7. 중복 검증
    StoreNameDuplicateException() =>
      '이미 보유하신 다른 점포와 이름이 같습니다.\n다른 점포명으로 입력해 주세요.',
    SpaceNameDuplicateException() =>
      '같은 점포 안에서는 공간명을 중복해서 사용할 수 없습니다.\n공간명을 다르게 입력해 주세요.',

    // 6. 유효성 검사 / 알 수 없는 에러
    StoreInviteCodeExpiredException() =>
      '초대 코드의 유효 시간이 지났습니다.\n점포 관리자에게 새 코드를 요청해 주세요.',
    StoreValidationException() ||
    StoreUnknownException() => '일시적인 에러가 발생했습니다.\n잠시 후 다시 시도해 주세요.',

    // 8. 관리자 1명 규칙
    StoreAdminRoleChangeException() =>
      '점포마다 관리자는 한 명입니다.\n관리자를 바꾸려면 관리자 위임을 이용해 주세요.',
    StoreAdminHandoverRequiredException(:final storeNames) =>
      '${storeNames.map((name) => "'$name'").join(', ')} 점포의 관리자입니다.\n'
          '다른 멤버에게 관리자를 위임하거나 점포를 삭제해 주세요.',
    StoreDelegationTargetInvalidException() =>
      '점포의 스태프나 뷰어에게만 관리자를 위임할 수 있습니다.\n멤버 목록을 새로 고친 뒤 다시 시도해 주세요.',
  };

  @override
  bool get isSilentable => switch (this) {
    StoreCancelledException() => true,
    StorePermissionDeniedException() ||
    StoreNotFoundException() ||
    StoreAlreadyExistsException() ||
    StoreNetworkException() ||
    StoreResourceExhaustedException() ||
    StoreTransactionException() ||
    StoreUpdateConflictException() ||
    StoreDataParsingException() ||
    StoreValidationException() ||
    StoreInviteCodeExpiredException() ||
    StoreNameDuplicateException() ||
    SpaceNameDuplicateException() ||
    StoreAdminRoleChangeException() ||
    StoreAdminHandoverRequiredException() ||
    StoreDelegationTargetInvalidException() ||
    StoreUnknownException() => false,
  };
}

// -----------------------------------------------------------------------------
// Exception classes
// -----------------------------------------------------------------------------

/// 점포 데이터에 접근할 권한이 없을 때 발생하는 예외
///
/// 관리자 권한이 없거나, 소속되지 않은 점포의 데이터를 수정하려 할 때 발생합니다.
/// Firebase Code: `permission-denied`, `unauthenticated`
class StorePermissionDeniedException extends StoreException {
  StorePermissionDeniedException({required String message, String? code})
    : super(message, code: code);
}

/// 요청한 점포(Document)를 찾을 수 없을 때 발생하는 예외
///
/// 삭제된 점포에 접근하거나, 잘못된 점포 ID로 조회를 시도할 때 발생합니다.
/// Firebase Code: `not-found`
class StoreNotFoundException extends StoreException {
  StoreNotFoundException({required String message, String? code})
    : super(message, code: code);
}

/// 네트워크 연결이 불안정하거나 끊겼을 때 발생하는 예외
///
/// Firebase Code: `unavailable`, `deadline-exceeded`, `network-request-failed`
class StoreNetworkException extends StoreException {
  StoreNetworkException({required String message, String? code})
    : super(message, code: code);
}

/// 트랜잭션 처리 중 충돌이 발생했을 때 예외
///
/// 동시에 여러 관리자가 같은 점포 설정을 수정하여 경합이 발생했을 때 주로 나타납니다.
/// Firebase Code: `aborted`, `failed-precondition`
class StoreTransactionException extends StoreException {
  StoreTransactionException({required String message, String? code})
    : super(message, code: code);
}

/// 점포 수정 폼을 연 뒤 다른 관리자가 같은 점포의 설정을 먼저 저장했을 때 발생하는 예외
///
/// 저장 트랜잭션에서 편집 가능 필드를 폼을 연 시점의 값과 비교해 판정한다 (D13).
/// 덮어쓰면 다른 관리자의 요금표 변경이 조용히 사라지므로 최신 값을 다시 불러와야 한다.
class StoreUpdateConflictException extends StoreException {
  StoreUpdateConflictException({required String message, String? code})
    : super(message, code: code);
}

/// DB 데이터와 앱의 점포 모델(Model) 구조가 일치하지 않을 때 발생하는 예외
///
/// 점포 설정 필드가 추가/변경되었으나 앱이 구버전일 때 발생합니다.
class StoreDataParsingException extends StoreException {
  StoreDataParsingException({required String message, String? code})
    : super(message, code: code);
}

/// 알 수 없는 에러가 발생했을 때 사용하는 예외
class StoreUnknownException extends StoreException {
  StoreUnknownException({required String message, String? code})
    : super(message, code: code);
}

/// 이미 존재하는 점포를 생성하려 할 때 발생하는 예외
///
/// Firebase Code: `already-exists`
class StoreAlreadyExistsException extends StoreException {
  StoreAlreadyExistsException({required String message, String? code})
    : super(message, code: code);
}

/// 요청 한도(Quota)를 초과하거나 리소스가 부족할 때 발생하는 예외
///
/// Firebase Code: `resource-exhausted`
class StoreResourceExhaustedException extends StoreException {
  StoreResourceExhaustedException({required String message, String? code})
    : super(message, code: code);
}

/// 작업이 취소되었을 때 발생하는 예외
///
/// Firebase Code: `cancelled`
class StoreCancelledException extends StoreException {
  StoreCancelledException({
    String message = 'Operation cancelled',
    String? code,
  }) : super(message, code: code);
}

/// 점포 등록, 수정 시 형식에 맞지 않는 데이터가 있을 때 발생하는 예외
class StoreValidationException extends StoreException {
  StoreValidationException({required String message, String? code})
    : super(message, code: code);
}

/// 초대 코드의 유효 시간(`storeInviteCodeAvailableMin`)이 지났을 때 발생하는 예외
///
/// StoreValidationException과 분리한 이유: 만료는 사용자가 새 코드를 요청하면
/// 해결되는 상황인데, 같은 arm에 묶이면 '잠시 후 다시 시도해 주세요'라는
/// 틀린 안내가 나간다 (기다릴수록 만료 상태가 유지된다).
class StoreInviteCodeExpiredException extends StoreException {
  StoreInviteCodeExpiredException({required String message, String? code})
    : super(message, code: code);
}

/// 이미 보유한 다른 점포와 이름이 중복될 때 발생하는 예외
class StoreNameDuplicateException extends StoreException {
  StoreNameDuplicateException({required String message, String? code})
    : super(message, code: code);
}

/// 같은 점포 내에서 공간명이 중복될 때 발생하는 예외
class SpaceNameDuplicateException extends StoreException {
  SpaceNameDuplicateException({required String message, String? code})
    : super(message, code: code);
}

/// 관리자 위임이 아닌 경로로 관리자 역할을 주거나 빼앗으려 할 때 발생하는 예외
///
/// ADMIN 역할로 가입 신청·승인, 다른 멤버를 관리자로 올리기, 관리자 강등·추방이 해당한다.
/// 점포마다 관리자는 정확히 한 명이며 Rules도 같은 규칙을 강제한다 (ADR-0004).
class StoreAdminRoleChangeException extends StoreException {
  StoreAdminRoleChangeException({required String message, String? code})
    : super(message, code: code);
}

/// 다른 멤버가 있는 점포의 관리자가 회원 탈퇴나 점포 나가기를 하려 할 때 발생하는 예외
///
/// 관리자가 없는 점포가 남지 않도록, 관리자 위임이나 점포 삭제를 먼저 해야 한다.
/// [stores]는 막힌 점포의 id와 표시 이름이다 (화면이 위임·삭제로 안내할 때 쓴다).
class StoreAdminHandoverRequiredException extends StoreException {
  final List<({String id, String name})> stores;

  StoreAdminHandoverRequiredException({
    required this.stores,
    required String message,
    String? code,
  }) : super(message, code: code);

  List<String> get storeNames => stores.map((store) => store.name).toList();
}

/// 관리자 위임 대상이 점포의 스태프·뷰어가 아닐 때 발생하는 예외
///
/// 승인 대기자, 이미 나간 멤버, 자기 자신에게는 위임할 수 없다.
class StoreDelegationTargetInvalidException extends StoreException {
  StoreDelegationTargetInvalidException({required String message, String? code})
    : super(message, code: code);
}
