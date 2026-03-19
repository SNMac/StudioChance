/// 앱 전역에서 사용하는 모든 커스텀 예외의 최상위 클래스
abstract class AppException implements Exception {
  /// 개발자/로그용 원본 메시지
  final String message;

  /// 개발자/로그용 원본 에러 코드
  final String? code;

  AppException(this.message, {this.code});

  /// 사용자에게 보여줄 에러 제목
  String get title;

  /// 사용자에게 보여줄 에러 내용
  String get content;

  /// true: 사용자에게 알리지 않고 넘어감, false: 다이얼로그나 스낵바로 알려야 함
  bool get isSilentable => false;

  @override
  String toString() =>
      '[$runtimeType] $message ${code != null ? '(Code: $code)' : ''}';
}
