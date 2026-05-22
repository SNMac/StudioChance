import 'dart:io';

import 'package:flutter/material.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/custom_app_bar.dart';

/// 모달 하단 시트 내부에서 사용하는 AppBar.
///
/// [CustomAppBar]를 기반으로, 모달에 맞게 다음을 적용:
/// - 배경 투명 (모달 시트 배경색이 투과)
/// - 하단 구분선 제거 (앱 테마의 shape.border 오버라이드)
class ModalAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ModalAppBar({
    super.key,
    required this.title,
    this.leading = const SizedBox.shrink(),
    this.actions,
  });

  final String title;
  final Widget? leading;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        appBarTheme: Theme.of(context).appBarTheme.copyWith(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: const RoundedRectangleBorder(),
        ),
      ),
      child: CustomAppBar(
        title: title,
        // TextButton은 Alignment.center로 렌더되며, leading(56px)과 action(64px)의
        // 콘텐츠 영역 차이(32 vs 40px)로 인해 왼쪽 gap이 4px 작게 보임.
        // 4px 좌측 padding + leadingWidth 60으로 양쪽 gap을 통일.
        leading: leading != null
            ? Padding(
                padding: const EdgeInsetsDirectional.only(start: 4.0),
                child: leading!,
              )
            : null,
        leadingWidth: 60.0,
        actions: actions,
      ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(Platform.isIOS ? 44.0 : kToolbarHeight);
}
