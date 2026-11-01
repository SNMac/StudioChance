import 'package:material_ui/material_ui.dart';

import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';

class TitleTextLabel extends StatelessWidget {
  final String title;
  final String content;

  /// content 텍스트 앞에 표시할 선행 위젯 (예: 컬러 dot).
  final Widget? leading;

  /// true면 content가 폭을 넘을 때 말줄임 대신 한 줄을 유지한 채 줄어든다.
  /// 일시·금액처럼 잘리면 정보가 사라지는 고정 형식 값에 쓴다 (#58).
  /// 점포명처럼 길이가 정해지지 않은 값은 false(말줄임)로 둔다.
  final bool scaleDownToFit;

  const TitleTextLabel({
    super.key,
    required this.title,
    required this.content,
    this.leading,
    this.scaleDownToFit = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final contentStyle = textTheme.bodyLarge?.copyWith(
      fontWeight: FontWeight.normal,
      color: context.label,
    );

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: horizontalPadding,
      ),
      child: SizedBox(
        height: inputFormComponentHeight,
        // title을 Flexible로 두면 content(Expanded)와 폭을 반씩 나눠, title이 짧아도
        // 남는 폭이 content로 가지 않아 일시처럼 긴 content가 잘린다.
        // title은 필요한 만큼만(최대 2/3) 차지하고 나머지는 content가 쓴다.
        child: LayoutBuilder(
          builder: (context, constraints) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: formRowTitleContentGap,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth * formRowTitleMaxWidthFraction,
                ),
                child: Text(
                  title,
                  style: textTheme.bodyLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: 8,
                  children: [
                    ?leading,
                    Flexible(
                      child: scaleDownToFit
                          ? FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: AlignmentDirectional.centerEnd,
                              child: Text(
                                content,
                                maxLines: 1,
                                style: contentStyle,
                              ),
                            )
                          : Text(
                              content,
                              textAlign: TextAlign.end,
                              overflow: TextOverflow.ellipsis,
                              style: contentStyle,
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
