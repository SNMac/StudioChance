import 'dart:math';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

/// DataSource 계층 테스트용 [FakeFirebaseFirestore] 헬퍼
///
/// 실제 Firebase 프로세스 없이 메모리 안에서 Firestore DataSource 로직을 검증한다.
///
/// ### 테스트 격리 원칙
/// - setUp에서 [create]로 새 인스턴스를 만들면 각 테스트가 빈 DB에서 시작한다.
/// - tearDown 없이도 테스트 간 데이터 오염이 생기지 않는다.
///
/// ### 에뮬레이터로 옮기지 않은 이유 (#43)
/// `cloud_firestore`는 플랫폼 채널로 네이티브 SDK를 부르므로 `flutter test`에서는
/// 에뮬레이터에 붙을 수 없다. 옮기려면 `integration_test`를 기기에서 돌리고 CI에
/// Android 에뮬레이터가 필요한데, 앱의 쿼리는 항상 존재하는 필드에 거는 등호·범위
/// 조건뿐이라 fake와 결과가 갈릴 여지가 작다. Rules는 `functions/src/rules/`가,
/// Functions의 쿼리는 `functions/src/queries/`가 실제 에뮬레이터에서 검증한다.
///
/// 앱에 다음 쿼리가 생기면 이 판단을 다시 한다. fake와 실제가 갈리는 곳이 주로 여기다.
/// - 없을 수 있는 필드에 거는 `where`·`orderBy` (실제 Firestore는 그 필드가 없는 문서를 뺀다)
/// - `isNull`·`isNotEqualTo`·`whereNotIn` 조건
/// - `collectionGroup` 쿼리
///
/// ### 인덱스
/// fake도 에뮬레이터도 인덱스를 검증하지 않고 유효한 쿼리를 모두 실행한다.
/// 단일 필드 인덱스는 Firestore가 필드마다 자동으로 만들므로 챙길 것이 없다.
/// 복합 인덱스가 필요한 쿼리(등호 조건과 다른 필드의 범위·정렬, 여러 필드의 범위·정렬)나
/// `collectionGroup` 쿼리를 추가하면 dev 프로젝트에서 실행해 확인한 뒤, 인덱스를
/// 저장소의 `firestore.indexes.json`에 적고 `firebase.json`의 `firestore.indexes`에
/// 그 경로를 등록해 prod에도 배포한다 (`docs/operations.md`). 콘솔이나 오류 링크로
/// dev에만 만든 인덱스는 prod에 생기지 않는다.
///
/// ### fake_cloud_firestore 알려진 제한사항
/// - `FieldValue.serverTimestamp()`: 패키지 내부 clock으로 대체되어 null이 아닌 실제 Timestamp를 반환한다
/// - `AggregateQuery.count()`: 3.x 이상에서 지원하며, 이하 버전은 테스트가 실패할 수 있다
/// - Firestore Security Rules: 적용되지 않는다
/// - `where(field, isNull: true)`: 필드가 아예 없는 문서도 매치시킨다. 실제 Firestore는
///   필터 대상 필드가 없는 문서를 결과에서 제외하므로, 이 필터에 의존하는 쿼리는
///   테스트를 통과해도 실제 환경에서 빈 결과를 낸다 (getStoreByInviteCode에서 실제로 발생.
///   이 쿼리는 지금 Functions의 lookupInviteCode로 옮겨져 에뮬레이터 테스트가 지킨다).
class FakeFirestoreHelper {
  static final _random = Random();

  /// 격리된 FakeFirebaseFirestore 인스턴스를 만든다.
  ///
  /// 각 테스트의 setUp에서 호출해 깨끗한 상태로 시작한다.
  static FakeFirebaseFirestore create() => FakeFirebaseFirestore();

  /// 테스트별 고유 문서 ID를 만든다. 테스트 데이터의 가독성을 위해 쓴다.
  static String generateId() {
    final ms = DateTime.now().millisecondsSinceEpoch;
    final suffix = _random.nextInt(99999).toString().padLeft(5, '0');
    return '${ms}_$suffix';
  }
}
