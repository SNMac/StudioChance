import 'package:studio_chance/common/exceptions/app_exception.dart';

/// OCR 관련 최상위 예외
sealed class OcrException extends AppException {
  OcrException(super.message, {super.code});

  @override
  String get title => switch (this) {
    OcrNetworkException() => '네트워크 에러가 발생했습니다',
    OcrParsingException() => 'OCR 분석 실패',
    OcrNotReservationException() => '예약 이미지가 아닙니다',
    OcrUnknownException() => '에러가 발생했습니다',
  };

  @override
  String get content => switch (this) {
    OcrNetworkException() => '인터넷 연결 상태를 확인해주세요.',
    OcrParsingException() =>
      '스크린샷에서 예약 정보를 인식하지 못했습니다.\n수동으로 입력해 주세요.',
    OcrNotReservationException() =>
      '공간 예약 확인 화면 스크린샷을 선택해 주세요.',
    OcrUnknownException() =>
      '일시적인 에러가 발생했습니다.\n잠시 후 다시 시도해 주세요.',
  };

  @override
  bool get isSilentable => switch (this) {
    OcrNetworkException() ||
    OcrParsingException() ||
    OcrNotReservationException() ||
    OcrUnknownException() => false,
  };
}

class OcrNetworkException extends OcrException {
  OcrNetworkException(super.message, {super.code});
}

class OcrParsingException extends OcrException {
  OcrParsingException(super.message, {super.code});
}

class OcrNotReservationException extends OcrException {
  OcrNotReservationException(super.message, {super.code});
}

class OcrUnknownException extends OcrException {
  OcrUnknownException(super.message, {super.code});
}
