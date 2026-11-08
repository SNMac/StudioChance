import 'package:material_ui/material_ui.dart';

import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';

/// 입력 폼 행 오른쪽에 회색 캡슐로 보여주는 값 (일시, 입금 마감 기한 등).
///
/// 잘리면 안 되는 고정 형식 값이라, 큰 글자 배율에서 폭이 모자라면 말줄임 대신
/// 한 줄을 유지한 채 줄어든다 (#58). 줄어들 폭을 받도록 Row 안에서는 `Flexible`로 감싼다.
class FormValueCapsule extends StatelessWidget {
  final String text;
  final Color color;

  const FormValueCapsule({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: context.tertiarySystemFill,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(fontWeight: FontWeight.normal, color: color),
        ),
      ),
    );
  }
}
