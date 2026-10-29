import 'package:material_ui/material_ui.dart';

/// 승인 대기 인원 배지.
///
/// 관리자에게 조치가 필요한 상태라 눈에 띄어야 하고, 점포명이 길어도
/// 잘리면 안 되므로 텍스트가 아닌 고정 크기 요소로 표시한다.
class PendingMemberBadge extends StatelessWidget {
  const PendingMemberBadge({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    // 앱 강조색은 my_app.dart의 ColorScheme 한 곳에서만 정의된다.
    // systemBlue를 직접 쓰면 강조색을 바꿀 때 여기만 남는다.
    final colorScheme = Theme.of(context).colorScheme;

    // 숫자를 담는 고정 크기 chrome이라 높이를 고정한다. textTheme을 쓰면
    // labelMedium의 height 1.5가 곱해져 세로로 길쭉해지고 행 높이를 넘어선다.
    return Semantics(
      label: '승인 대기 $count명',
      child: ExcludeSemantics(
        child: Container(
          height: 20,
          constraints: const BoxConstraints(minWidth: 20),
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontSize: 12,
              height: 1.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
