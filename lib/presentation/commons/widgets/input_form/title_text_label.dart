import 'package:flutter/material.dart';

import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';

class TitleTextLabel extends StatelessWidget {
  final String title;
  final String content;

  /// content 텍스트 앞에 표시할 선행 위젯 (예: 컬러 dot).
  final Widget? leading;

  const TitleTextLabel({
    super.key,
    required this.title,
    required this.content,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: horizontalPadding,
      ),
      child: SizedBox(
        height: inputFormComponentHeight,
        // title을 Flexible로 두면 content(Expanded)와 폭을 반씩 나눠, title이 짧아도
        // 남는 폭이 content로 가지 않아 일시처럼 긴 content가 잘린다.
        // title은 필요한 만큼만(최대 절반) 차지하고 나머지는 content가 쓴다.
        child: LayoutBuilder(
          builder: (context, constraints) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 8,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: constraints.maxWidth / 2),
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
                      child: Text(
                        content,
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.normal,
                          color: context.label,
                        ),
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
