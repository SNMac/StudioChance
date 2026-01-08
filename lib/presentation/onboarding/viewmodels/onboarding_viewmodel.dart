import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/enums/user_role.dart';
import 'package:studio_chance/domain/usecases/auth_use_case.dart';
import 'package:studio_chance/domain/usecases/user_use_case.dart';

import 'package:studio_chance/presentation/onboarding/viewmodels/onboarding_state.dart';
import 'package:studio_chance/presentation/providers/auth_state_provider.dart';

part 'onboarding_viewmodel.g.dart';

@riverpod
class OnboardingViewModel extends _$OnboardingViewModel {
  @override
  AsyncValue<OnboardingState> build() {
    // 초기 상태: 데이터 있음 (로딩 X, 에러 X)
    return const AsyncValue.data(OnboardingState());
  }

  // ===========================================================================
  // 1. 상태 업데이트 메서드 (View 또는 하위 ViewModel에서 호출)
  // ===========================================================================

  /// 닉네임 입력 (TextField 등에서 호출)
  void setNickname(String nickname) {
    _updateState((s) => s.copyWith(nickname: nickname));
  }

  /// 역할 선택 (RoleSelectionView에서 호출)
  void setRole(UserRole role) {
    _updateState((s) => s.copyWith(selectedRole: role));
  }

  /// [Admin 전용] 하위 VM(StoreFormVM)에서 완성된 Store 객체를 받음
  void setStoreToMake(Store store) {
    _updateState((s) => s.copyWith(storeToMake: store));
  }

  /// [Staff/Viewer 전용] 하위 VM(InvitationVM)에서 검증된 Store ID를 받음
  void setInvitedStoreId(String storeId) {
    _updateState((s) => s.copyWith(invitedStoreId: storeId));
  }

  /// 내부 상태 업데이트 헬퍼
  void _updateState(OnboardingState Function(OnboardingState) update) {
    // state.value는 T? 타입이므로 null 체크 후 업데이트
    final currentState = state.value;
    if (currentState != null) {
      state = AsyncValue.data(update(currentState));
    }
  }

  /// 온보딩 취소 및 로그아웃
  Future<void> cancelOnboarding() async {
    try {
      final authUseCase = ref.read(authUseCaseProvider);
      await authUseCase.signOut();

      state = const AsyncValue.data(OnboardingState(nickname: ''));
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// 최종 제출 로직 (Submit)
  Future<void> submit() async {
    final currentState = state.value;
    if (currentState == null) return;

    // 1. 유효성 검사 (실패 시 에러 상태 전환)
    if (!currentState.canSubmit) {
      state = AsyncValue.error(
        Exception('필수 정보가 누락되었습니다.'),
        StackTrace.current,
      );
      return;
    }

    // 2. 로딩 시작
    state = const AsyncValue.loading();

    try {
      final currentUser = ref.read(authStateProvider).value;
      if (currentUser == null) throw Exception('로그인 정보를 찾을 수 없습니다.');
      final uid = currentUser.id;

      final userUseCase = ref.read(userUseCaseProvider);
      // final storeUseCase = ref.read(storeUseCaseProvider); // TODO: 추후 구현

      // -------------------------------------------------------
      // A. Store ID 확보 단계
      // -------------------------------------------------------
      String finalStoreId;

      if (currentState.selectedRole == UserRole.admin) {
        // [Admin] 가게 생성 로직
        final storeEntity = currentState.storeToMake!;

        // TODO: 실제 StoreUseCase.createStore 호출로 교체
        // final createResult = await storeUseCase.createStore(storeEntity);
        // if (createResult.isLeft()) throw createResult.getLeft().toNullable()!;
        // finalStoreId = createResult.getRight().id;

        await Future.delayed(const Duration(milliseconds: 500)); // Mock API
        finalStoreId =
            'created-store-id-${DateTime.now().millisecondsSinceEpoch}';
      } else {
        // [Staff/Viewer] 초대된 가게 ID 사용
        finalStoreId = currentState.invitedStoreId!;
      }

      // -------------------------------------------------------
      // B. 유저 프로필 업데이트 (닉네임, 역할)
      // -------------------------------------------------------
      final updateProfileResult = await userUseCase.updateUser(
        uid: uid,
        nickname: currentState.nickname,
        role: currentState.selectedRole,
      );

      if (updateProfileResult.isLeft()) {
        throw updateProfileResult.getLeft().toNullable()!;
      }

      // -------------------------------------------------------
      // C. 유저 - 가게 연결 (storeIds 추가)
      // -------------------------------------------------------
      final addStoreResult = await userUseCase.addStoreId(
        uid: uid,
        storeId: finalStoreId,
      );

      if (addStoreResult.isLeft()) {
        throw addStoreResult.getLeft().toNullable()!;
      }

      // -------------------------------------------------------
      // D. 성공 처리
      // -------------------------------------------------------
      // 성공 상태로 복구 (데이터 유지)
      state = AsyncValue.data(currentState);

      // AuthState 갱신 -> 라우터 리다이렉트(Home 이동) 트리거
      ref.invalidate(authStateProvider);
    } catch (e, stackTrace) {
      // 에러 발생 시 상태 전환 (View에서 listen하여 다이얼로그 표시)
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
