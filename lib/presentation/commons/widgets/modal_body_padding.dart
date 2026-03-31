import 'package:flutter/material.dart';

import 'package:studio_chance/constants/ui_constants.dart';

/// 모달 바디 영역의 표준 SafeArea + Padding 래퍼.
///
/// 모달에서 AppBar 아래 콘텐츠를 감쌀 때 사용.
/// - [SafeArea(top: false)]: 상단 SafeArea는 AppBar가 담당하므로 하단/좌우만 적용
/// - 기본 padding: 수평 [horizontalPadding](16), 상단 16, 하단 8
///
/// 사용 예:
/// ```dart
/// ModalBodyPadding(
///   child: GroupedFormContainer(children: [...]),
/// )
/// ```
class ModalBodyPadding extends StatelessWidget {
  const ModalBodyPadding({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(
      horizontalPadding,
      16,
      horizontalPadding,
      8,
    ),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(padding: padding, child: child),
    );
  }
}
