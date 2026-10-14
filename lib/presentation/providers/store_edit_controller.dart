import 'package:fpdart/fpdart.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/use_cases/store_use_case_provider.dart';

part 'store_edit_controller.g.dart';

/// 점포 수정 화면 진입 — 마이페이지와 예약 계산 내역 시트가 공유한다
@riverpod
class StoreEditController extends _$StoreEditController {
  final _logger = Logger();

  @override
  FutureOr<void> build() {}

  /// 수정 화면에 넘길 점포를 새로 조회한다.
  ///
  /// 수정 화면은 이 점포를 동시 수정 판정의 기준으로 쓰므로(D13) 캐시된
  /// `storeDetailProvider` 값을 쓰지 않는다 — 낡은 값이면 저장할 때마다 충돌이 난다.
  Future<Either<Exception, Store>> loadStoreForEdit(String storeId) async {
    final result = await ref
        .read(storeUseCaseProvider)
        .getStoreForEdit(storeId);
    return result.mapLeft((e) {
      _logger.e('수정할 점포 조회 실패', error: e);
      return e;
    });
  }
}
