import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:studio_chance/common/exceptions/app_exception.dart';
import 'package:studio_chance/presentation/commons/store_input/screens/store_form_screen.dart';
import 'package:studio_chance/presentation/commons/widgets/custom_alert_dialog.dart';
import 'package:studio_chance/presentation/providers/store_edit_controller.dart';

/// 점포를 새로 조회한 뒤 점포 수정 화면을 연다 — 마이페이지와 예약 모달이 공유한다.
///
/// CLAUDE.md '화면 전환 전 데이터 로딩 패턴'을 따른다: 조회 중에는 중복 탭을 막고,
/// 1초 넘게 걸리면 오버레이를 띄운다. 호스트는 build의 Stack 최상단에
/// `LoadingOverlay(isLoading: showStoreEditOverlay)`를 둔다.
mixin StoreEditLauncher<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  bool _isLoadingStoreForEdit = false;
  bool _showStoreEditOverlay = false;
  Timer? _storeEditOverlayTimer;

  bool get showStoreEditOverlay => _showStoreEditOverlay;

  @override
  void dispose() {
    _storeEditOverlayTimer?.cancel();
    super.dispose();
  }

  /// 수정 화면에서 저장하고 돌아왔으면 true. [spaceOptionId]는 처음 보여줄 공간이다.
  Future<bool> openStoreEdit(String storeId, {String? spaceOptionId}) async {
    if (_isLoadingStoreForEdit) return false;

    setState(() => _isLoadingStoreForEdit = true);
    _storeEditOverlayTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) setState(() => _showStoreEditOverlay = true);
    });

    final result = await ref
        .read(storeEditControllerProvider.notifier)
        .loadStoreForEdit(storeId)
        .whenComplete(() {
          _storeEditOverlayTimer?.cancel();
          _storeEditOverlayTimer = null;
          if (mounted) {
            setState(() {
              _isLoadingStoreForEdit = false;
              _showStoreEditOverlay = false;
            });
          }
        });

    if (!mounted) return false;
    return result.fold<Future<bool>>((e) async {
      _showLoadError(e);
      return false;
    }, (store) => pushStoreEdit(context, store, spaceOptionId: spaceOptionId));
  }

  void _showLoadError(Exception error) {
    final (title, content) = error is AppException
        ? (error.title, error.content)
        : ('오류', '잠시 후 다시 시도해 주세요.');
    showCustomAlertDialog(
      context: context,
      title: title,
      content: content,
      showCancel: false,
    );
  }
}
