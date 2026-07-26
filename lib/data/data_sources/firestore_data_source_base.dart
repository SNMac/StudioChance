import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

/// Firestore DataSource 공통 에러 핸들링 기반 클래스
///
/// - Firebase 에러 코드 추출 / 파싱 예외 감지 / 도메인 예외 통과 로직을 단일 위치에 구현
/// - 서브클래스는 [errorLogTag], [isDomainException], [buildParsingException],
///   [mapFirebaseCode] 네 멤버를 구현하여 도메인별 Exception을 제공한다
abstract class FirestoreDataSourceBase {
  // 서브클래스에서도 직접 사용 가능 (Dart에 protected 없음)
  final Logger logger = Logger();

  /// 로그 태그 (예: 'Reservation Firestore Error')
  String get errorLogTag;

  /// [e]가 이미 도메인 예외인지 여부 (예: `e is ReservationException`)
  bool isDomainException(Object e);

  /// `TypeError` / `FormatException` 발생 시 반환할 파싱 예외
  Exception buildParsingException(String message);

  /// Firebase 에러 코드 → 도메인 예외 매핑
  ///
  /// [code]: FirebaseException.code, 또는 비-Firebase 예외의 경우 `''`
  Exception mapFirebaseCode(String code, String message);

  Exception handleFirestoreError(Object e, [StackTrace? stackTrace]) {
    logger.e(errorLogTag, error: e, stackTrace: stackTrace);

    if (isDomainException(e)) return e as Exception;

    if (e is TypeError || e is FormatException) {
      return buildParsingException('데이터 파싱에 실패했습니다.\n${e.toString()}');
    }

    if (e is FirebaseException) {
      return mapFirebaseCode(e.code, e.message ?? 'Cloud Firestore Error');
    }

    return mapFirebaseCode('', e.toString());
  }
}
