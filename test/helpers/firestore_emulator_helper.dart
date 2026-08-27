import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

/// DataSource 계층 에뮬레이터 테스트 헬퍼
///
/// [FakeFirebaseFirestore]를 사용하여 실제 Firebase 프로세스 없이
/// Firestore DataSource 로직을 검증합니다.
///
/// ### 테스트 격리 원칙
/// - setUp에서 [create]로 새 인스턴스를 생성하면 각 테스트가 빈 DB에서 시작합니다.
/// - tearDown 없이도 테스트 간 데이터 오염이 발생하지 않습니다.
///
/// ### 실제 Firebase Firestore Emulator 전환 시
/// 1. [create] 대신 setUpAll에서 `FirebaseFirestore.instance`를 반환하도록 교체
///    ```dart
///    await Firebase.initializeApp(options: ...);
///    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
///    ```
/// 2. 각 tearDown에서 테스트 생성 문서를 삭제하거나, 에뮬레이터 HTTP API로 초기화:
///    ```
///    DELETE http://localhost:8080/emulator/v1/projects/studio-chance/databases/(default)/documents
///    ```
///
/// ### fake_cloud_firestore 알려진 제한사항
/// - `FieldValue.serverTimestamp()`: 패키지 내부 clock으로 대체되어 null이 아닌 실제 Timestamp 반환
/// - `AggregateQuery.count()`: 3.x 이상에서 지원, 이하 버전은 테스트가 실패할 수 있음
/// - Firestore Security Rules: 적용되지 않음
/// - `where(field, isNull: true)`: 필드가 아예 없는 문서도 매치시킨다. 실제 Firestore는
///   필터 대상 필드가 없는 문서를 결과에서 제외하므로, 이 필터에 의존하는 쿼리는
///   테스트를 통과해도 실제 환경에서 빈 결과를 낸다 (getStoreByInviteCode에서 실제로 발생).
class FirestoreEmulatorHelper {
  static final _random = Random();

  /// 격리된 FakeFirebaseFirestore 인스턴스를 생성합니다.
  ///
  /// 각 테스트의 setUp에서 호출하여 깨끗한 상태로 시작합니다.
  static FakeFirebaseFirestore create() => FakeFirebaseFirestore();

  /// 테스트별 고유 문서 ID를 생성합니다.
  ///
  /// 실제 에뮬레이터 사용 시 다른 테스트와 문서 ID 충돌을 방지합니다.
  /// FakeFirebaseFirestore 사용 시에도 가독성을 위해 사용합니다.
  static String generateId() {
    final ms = DateTime.now().millisecondsSinceEpoch;
    final suffix = _random.nextInt(99999).toString().padLeft(5, '0');
    return '${ms}_$suffix';
  }

  /// 지정 문서 참조 목록을 일괄 삭제합니다.
  ///
  /// 실제 Firestore Emulator 사용 시 tearDown에서 호출합니다.
  /// FakeFirebaseFirestore 사용 시에는 불필요하지만, 에뮬레이터 전환을 대비해 제공합니다.
  static Future<void> tearDownDocs(List<DocumentReference> refs) async {
    for (final ref in refs) {
      try {
        await ref.delete();
      } catch (_) {}
    }
  }
}
