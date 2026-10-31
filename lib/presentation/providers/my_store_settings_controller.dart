import 'package:fpdart/fpdart.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/common/enums/store_color.dart';
import 'package:studio_chance/common/exceptions/auth_exceptions.dart';
import 'package:studio_chance/domain/use_cases/user_use_case_provider.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';

part 'my_store_settings_controller.g.dart';

/// 점포 상세 '내 설정'의 점포 별명·점포 색상·점포 메모 저장을 UseCase에 위임한다.
///
/// 모두 멤버마다 따로 두는 값이라 역할과 관계없이 본인이 바꾼다 (CONTEXT.md "점포 색상").
@riverpod
class MyStoreSettingsController extends _$MyStoreSettingsController {
  final _logger = Logger();

  @override
  FutureOr<void> build() {}

  /// [alias]가 비어 있으면 점포 별명을 지운다
  Future<bool> updateAlias({required String storeId, required String alias}) {
    return _update(storeId, alias: alias);
  }

  Future<bool> updateColor({
    required String storeId,
    required StoreColor color,
  }) {
    return _update(storeId, color: color);
  }

  Future<bool> updateMemo({required String storeId, required String memo}) {
    return _update(storeId, memo: memo);
  }

  Future<bool> _update(
    String storeId, {
    String? alias,
    StoreColor? color,
    String? memo,
  }) async {
    state = const AsyncLoading();

    final uid = ref.read(currentUserProvider).value?.id;
    final Either<Exception, void> result = uid == null
        ? left(AuthUserNotFoundException(message: '로그인된 사용자가 없습니다.'))
        : await ref
              .read(userUseCaseProvider)
              .updateStoreInfo(
                uid: uid,
                storeId: storeId,
                alias: alias,
                color: color,
                memo: memo,
              );
    final stackTrace = StackTrace.current;

    return result.fold(
      (e) {
        _logger.e('내 점포 설정 저장 실패', error: e);
        state = AsyncError(e, stackTrace);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        ref.invalidate(currentUserProvider);
        return true;
      },
    );
  }
}
