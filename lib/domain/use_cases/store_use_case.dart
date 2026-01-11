import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studio_chance/common/exceptions/auth_exceptions.dart';

import 'package:studio_chance/data/repositories/store_repository_impl.dart';
import 'package:studio_chance/domain/entities/invite_info.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/enums/user_role.dart';
import 'package:studio_chance/domain/repository_interfaces/store_repository.dart';
import 'package:studio_chance/domain/repository_interfaces/user_repository.dart';
import 'package:studio_chance/data/repositories/user_repository_impl.dart';

part 'store_use_case.g.dart';

abstract interface class StoreUseCase {
  /// 점포 생성 (생성 요청자를 Admin으로 자동 등록)
  Future<Either<Exception, Store>> createStore(Store store);

  /// 점포 조회
  Future<Either<Exception, Store?>> getStore(String storeId);

  /// 초대 코드로 점포 조회 (입장 전 확인용)
  Future<Either<Exception, Store?>> getStoreByInviteCode(String inviteCode);

  /// 점포 입장 (초대 수락)
  /// - 현재 로그인된 유저를 해당 점포의 멤버로 추가
  Future<Either<Exception, void>> joinStore({
    required String storeId,
    required UserRole role,
  });

  /// 초대 코드 생성/재생성
  Future<Either<Exception, InviteInfo>> createInviteCode(
    String storeId, {
    bool forceRegenerate = false,
  });
}

class StoreUseCaseImpl implements StoreUseCase {
  final StoreRepository _storeRepository;
  final UserRepository _userRepository;

  const StoreUseCaseImpl({
    required StoreRepository storeRepository,
    required UserRepository userRepository,
  }) : _storeRepository = storeRepository,
       _userRepository = userRepository;

  @override
  Future<Either<Exception, Store>> createStore(Store store) async {
    final userResult = await _userRepository.getCurrentUser();

    return userResult.fold((error) => left(error), (currentUser) async {
      if (currentUser == null) {
        return left(AuthUserNotFoundException(message: '로그인 정보를 찾을 수 없습니다.'));
      }

      final adminUser = currentUser.copyWith(role: UserRole.admin);
      final storeWithAdmin = store.copyWith(members: [adminUser]);

      return _storeRepository.createStore(storeWithAdmin);
    });
  }

  @override
  Future<Either<Exception, Store?>> getStore(String storeId) {
    return _storeRepository.getStore(storeId);
  }

  @override
  Future<Either<Exception, Store?>> getStoreByInviteCode(String inviteCode) {
    return _storeRepository.getStoreByInviteCode(inviteCode);
  }

  @override
  Future<Either<Exception, void>> joinStore({
    required String storeId,
    required UserRole role,
  }) async {
    final userResult = await _userRepository.getCurrentUser();

    return userResult.fold((error) => left(error), (currentUser) async {
      if (currentUser == null) {
        return left(AuthUserNotFoundException(message: '로그인 정보를 찾을 수 없습니다.'));
      }

      return _storeRepository.requestJoinStore(
        storeId: storeId,
        uid: currentUser.id,
        role: role,
      );
    });
  }

  @override
  Future<Either<Exception, InviteInfo>> createInviteCode(
    String storeId, {
    bool forceRegenerate = false,
  }) {
    return _storeRepository.createInviteCode(
      storeId,
      forceRegenerate: forceRegenerate,
    );
  }
}

@riverpod
StoreUseCase storeUseCase(Ref ref) {
  final storeRepository = ref.watch(storeRepositoryProvider);
  final userRepository = ref.watch(userRepositoryProvider);

  return StoreUseCaseImpl(
    storeRepository: storeRepository,
    userRepository: userRepository,
  );
}
