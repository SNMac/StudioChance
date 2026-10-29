import 'dart:math' as math;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';

class TitleNavigationButton extends StatelessWidget {
  final String title;
  final String? content;

  /// title 왼쪽에 표시할 위젯 (예: 마이페이지 점포 행의 점포 색상 점)
  final Widget? titleLeading;
  final Widget? contentLeading;

  /// content 오른쪽, chevron 앞에 표시할 위젯 (예: 대기 인원 배지).
  /// 길이가 고정적이라 content처럼 잘리지 않아야 하는 요소에 쓴다.
  final Widget? trailing;
  final bool isChangeable;

  /// true면 content가 필요한 만큼 먼저 쓰고 남는 폭을 title이 쓴다.
  /// 이름(title)이 길고 값(content)이 짧은 행에 쓴다 (예: 점포명 · 역할).
  /// false면 title이 먼저 쓰고 남는 폭을 content가 쓴다 (예: 주소 · 긴 값).
  final bool prioritizeContent;

  /// 탭해도 다른 화면으로 가지 않는 행은 끈다 (예: 액션시트를 여는 멤버 행)
  final bool showChevron;

  /// 생략하면 탭할 수 없는 행이 된다
  final VoidCallback? onPressed;

  const TitleNavigationButton({
    super.key,
    required this.title,
    this.content,
    this.titleLeading,
    this.contentLeading,
    this.trailing,
    this.isChangeable = false,
    this.prioritizeContent = false,
    this.showChevron = true,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final layout = CustomMultiChildLayout(
      delegate: _TitleNavigationLayoutDelegate(
        textDirection: Directionality.of(context),
        prioritizeContent: prioritizeContent,
      ),
      children: [
        if (titleLeading != null)
          LayoutId(id: _Slot.titleLeading, child: titleLeading!),
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
                color: isChangeable ? context.secondaryLabel : context.label,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        if (trailing != null) LayoutId(id: _Slot.trailing, child: trailing!),
        if (showChevron)
          LayoutId(
            id: _Slot.chevron,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 10),
              // 기본 크기(24)는 iOS 설정 앱의 chevron보다 1.35배 크게 그려진다.
              // 18이면 iOS와 같은 약 7×11.5pt가 된다
              child: Icon(
                CupertinoIcons.chevron_forward,
                size: 18,
                color: context.tertiaryLabel,
              ),
            ),
          ),
      ],
    );

    const padding = EdgeInsetsDirectional.symmetric(
      horizontal: horizontalPadding,
    );

    return SizedBox(
      height: inputFormComponentHeight,
      child: onPressed == null
          ? Padding(padding: padding, child: layout)
          : CupertinoButton(
              padding: padding,
              onPressed: onPressed,
              child: layout,
            ),
    );
  }
}

enum _Slot { titleLeading, title, contentLeading, content, trailing, chevron }

/// title과 content를 한 줄에 배치한다.
///
/// - 오른쪽 고정 요소(contentLeading·trailing·chevron)의 폭을 먼저 확보한다.
///   그러지 않으면 긴 점포명이 배지·수정 버튼을 행 밖으로 밀어낸다.
/// - 기본: title은 필요한 만큼만, 최대 행 폭의 2/3까지 쓴다. Row의 Flexible·Expanded로
///   나누면 비율대로 폭이 먼저 배정돼, title이 짧아도 남는 폭이 content로 가지
///   않아 이메일처럼 긴 content가 잘린다. content는 나머지 폭을 쓴다.
/// - [prioritizeContent]: content가 필요한 만큼 먼저 쓰고 title이 나머지를 쓴다.
/// - content는 오른쪽 요소에 붙는다.
class _TitleNavigationLayoutDelegate extends MultiChildLayoutDelegate {
  _TitleNavigationLayoutDelegate({
    required this.textDirection,
    required this.prioritizeContent,
  });

  final TextDirection textDirection;
  final bool prioritizeContent;

  static const _titleLeadingGap = 8.0;
  static const _leadingGap = 8.0;
  static const _trailingGap = 8.0;
  static const _chevronGap = 12.0;

  @override
  void performLayout(Size size) {
    final loose = BoxConstraints.loose(size);
    final hasTitleLeading = hasChild(_Slot.titleLeading);
    final hasLeading = hasChild(_Slot.contentLeading);
    final hasContent = hasChild(_Slot.content);
    final hasTrailing = hasChild(_Slot.trailing);
    final hasChevron = hasChild(_Slot.chevron);

    final titleLeading = hasTitleLeading
        ? layoutChild(_Slot.titleLeading, loose)
        : Size.zero;
    final chevron = hasChevron ? layoutChild(_Slot.chevron, loose) : Size.zero;
    final leading = hasLeading
        ? layoutChild(_Slot.contentLeading, loose)
        : Size.zero;
    final trailing = hasTrailing
        ? layoutChild(_Slot.trailing, loose)
        : Size.zero;

    final fixedWidth =
        (hasTitleLeading ? titleLeading.width + _titleLeadingGap : 0) +
        (hasChevron ? chevron.width + _chevronGap : 0) +
        (hasTrailing ? trailing.width + _trailingGap : 0) +
        (hasLeading ? leading.width + _leadingGap : 0);
    final textSpace = math.max(
      0.0,
      size.width - formRowTitleContentGap - fixedWidth,
    );

    BoxConstraints upTo(double width) =>
        BoxConstraints(maxWidth: math.max(0.0, width), maxHeight: size.height);

    final Size title;
    final Size content;
    if (prioritizeContent) {
      content = hasContent
          ? layoutChild(_Slot.content, upTo(textSpace))
          : Size.zero;
      title = layoutChild(_Slot.title, upTo(textSpace - content.width));
    } else {
      title = layoutChild(
        _Slot.title,
        upTo(math.min(size.width * formRowTitleMaxWidthFraction, textSpace)),
      );
      content = hasContent
          ? layoutChild(_Slot.content, upTo(textSpace - title.width))
          : Size.zero;
    }

    // x는 LTR 기준으로 계산하고, RTL이면 좌우를 뒤집는다.
    void place(_Slot slot, Size child, double x) {
      final dx = textDirection == TextDirection.ltr
          ? x
          : size.width - x - child.width;
      positionChild(slot, Offset(dx, (size.height - child.height) / 2));
    }

    var left = 0.0;
    if (hasTitleLeading) {
      place(_Slot.titleLeading, titleLeading, left);
      left += titleLeading.width + _titleLeadingGap;
    }
    place(_Slot.title, title, left);

    // 오른쪽 끝(chevron)부터 왼쪽으로 붙여 나간다.
    var right = size.width;
    if (hasChevron) {
      right -= chevron.width;
      place(_Slot.chevron, chevron, right);
      right -= _chevronGap;
    }

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
      textDirection != oldDelegate.textDirection ||
      prioritizeContent != oldDelegate.prioritizeContent;
}
