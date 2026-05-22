import 'package:flutter/material.dart';
import 'package:studio_chance/presentation/colors.dart';

/// 모달 하단 시트 상단에 표시되는 Grabber pill 컴포넌트.
///
/// 총 높이 14px (SizedBox), pill은 수직 중앙 정렬.
/// pill 크기: 36×5, 코너 반지름 2.5.
/// 다크 모드 자동 대응 ([modalGrabberDarkColor] / [modalGrabberColor]).
class ModalGrabber extends StatelessWidget {
  const ModalGrabber({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 14,
      child: Center(
        child: Container(
          width: 36,
          height: 5,
          decoration: BoxDecoration(
            color: isDarkMode ? modalGrabberDarkColor : modalGrabberColor,
            borderRadius: BorderRadius.circular(2.5),
          ),
        ),
      ),
    );
  }
}
