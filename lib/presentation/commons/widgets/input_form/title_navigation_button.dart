import 'dart:math' as math;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';

class TitleNavigationButton extends StatelessWidget {
  final String title;
  final String? content;
  final Widget? contentLeading;

  /// content 오른쪽, chevron 앞에 표시할 위젯 (예: 대기 인원 배지).
  /// 길이가 고정적이라 content처럼 잘리지 않아야 하는 요소에 쓴다.
  final Widget? trailing;
  final bool isChangeable;
  final VoidCallback onPressed;

  const TitleNavigationButton({
    super.key,
    required this.title,
    this.content,
    this.contentLeading,
    this.trailing,
    this.isChangeable = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: inputFormComponentHeight,
      child: CupertinoButton(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: horizontalPadding,
        ),
        onPressed: onPressed,
        child: CustomMultiChildLayout(
          delegate: _TitleNavigationLayoutDelegate(
            textDirection: Directionality.of(context),
          ),
          children: [
            LayoutId(
              id: _Slot.title,
              child: Text(
                title,
                style: textTheme.bodyLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (contentLeading != null)
              LayoutId(id: _Slot.contentLeading, child: contentLeading!),
            if (content != null)
              LayoutId(
                id: _Slot.content,
                child: Text(
                  content!,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.normal,
                    color: isChangeable
                        ? context.secondaryLabel
                        : context.label,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            if (trailing != null)
              LayoutId(id: _Slot.trailing, child: trailing!),
            LayoutId(
              id: _Slot.chevron,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 10),
                child: Icon(
                  CupertinoIcons.chevron_forward,
                  color: context.tertiaryLabel,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _Slot { title, contentLeading, content, trailing, chevron }

/// title과 content를 한 줄에 배치한다.
///
/// - 오른쪽 고정 요소(contentLeading·trailing·chevron)의 폭을 먼저 확보한다.
///   그러지 않으면 긴 점포명이 배지·수정 버튼을 행 밖으로 밀어낸다.
/// - title은 필요한 만큼만, 최대 행 폭의 2/3까지 쓴다. Row의 Flexible·Expanded로
///   나누면 비율대로 폭이 먼저 배정돼, title이 짧아도 남는 폭이 content로 가지
///   않아 이메일처럼 긴 content가 잘린다.
/// - content는 나머지 폭을 쓰고 오른쪽 요소에 붙는다.
class _TitleNavigationLayoutDelegate extends MultiChildLayoutDelegate {
  _TitleNavigationLayoutDelegate({required this.textDirection});

  final TextDirection textDirection;

  static const _leadingGap = 8.0;
  static const _trailingGap = 8.0;
  static const _chevronGap = 12.0;

  @override
  void performLayout(Size size) {
    final loose = BoxConstraints.loose(size);
    final hasLeading = hasChild(_Slot.contentLeading);
    final hasContent = hasChild(_Slot.content);
    final hasTrailing = hasChild(_Slot.trailing);

    final chevron = layoutChild(_Slot.chevron, loose);
    final leading = hasLeading
        ? layoutChild(_Slot.contentLeading, loose)
        : Size.zero;
    final trailing = hasTrailing
        ? layoutChild(_Slot.trailing, loose)
        : Size.zero;

    final fixedWidth =
        chevron.width +
        _chevronGap +
        (hasTrailing ? trailing.width + _trailingGap : 0) +
        (hasLeading ? leading.width + _leadingGap : 0);
    final textSpace = math.max(
      0.0,
      size.width - formRowTitleContentGap - fixedWidth,
    );

    final title = layoutChild(
      _Slot.title,
      BoxConstraints(
        maxWidth: math.min(
          size.width * formRowTitleMaxWidthFraction,
          textSpace,
        ),
        maxHeight: size.height,
      ),
    );
    final content = hasContent
        ? layoutChild(
            _Slot.content,
            BoxConstraints(
              maxWidth: textSpace - title.width,
              maxHeight: size.height,
            ),
          )
        : Size.zero;

    // x는 LTR 기준으로 계산하고, RTL이면 좌우를 뒤집는다.
    void place(_Slot slot, Size child, double x) {
      final dx = textDirection == TextDirection.ltr
          ? x
          : size.width - x - child.width;
      positionChild(slot, Offset(dx, (size.height - child.height) / 2));
    }

    place(_Slot.title, title, 0);

    // 오른쪽 끝(chevron)부터 왼쪽으로 붙여 나간다.
    var right = size.width - chevron.width;
    place(_Slot.chevron, chevron, right);
    right -= _chevronGap;

    if (hasTrailing) {
      right -= trailing.width;
      place(_Slot.trailing, trailing, right);
      right -= _trailingGap;
    }
    if (hasContent) {
      right -= content.width;
      place(_Slot.content, content, right);
    }
    if (hasLeading) {
      right -= _leadingGap + leading.width;
      place(_Slot.contentLeading, leading, right);
    }
  }

  @override
  bool shouldRelayout(_TitleNavigationLayoutDelegate oldDelegate) =>
      textDirection != oldDelegate.textDirection;
}
