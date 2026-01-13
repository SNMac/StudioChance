/// 앱 전역에서 사용하는 모든 커스텀 예외의 최상위 클래스
abstract class AppException implements Exception {
  /// 개발자/로그용 원본 메시지
  final String message;

  /// 개발자/로그용 원본 에러 코드
  final String? code;

  AppException(this.message, {this.code});

  String get title => '오류가 발생했습니다';

  // UI에 표시할 내용
  String get content => message;

  @override
  String toString() =>
      '[$runtimeType] $message ${code != null ? '(Code: $code)' : ''}';
}
