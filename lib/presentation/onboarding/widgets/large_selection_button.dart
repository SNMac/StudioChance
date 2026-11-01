import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

class LargeSelectionButton extends StatelessWidget {
  final String title;
  final String? description;
  final bool isSelected;
  final bool isNavigation;
  final VoidCallback? onPressed;

  const LargeSelectionButton({
    super.key,
    required this.title,
    this.description,
    this.isSelected = false,
    this.isNavigation = false,
    this.onPressed,
  });

  /// chevron 아이콘 크기. 글자가 커져도 가운데 정렬된 제목이 아이콘과 겹치지 않도록
  /// 내비게이션 버튼은 제목 좌우에 이만큼 여백을 둔다 (#58).
  static const double _chevronSize = 24;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final backgroundColor = isSelected
        ? colorScheme.primary
        : colorScheme.primaryContainer;

    final labelColor = isSelected
        ? colorScheme.onPrimary
        : colorScheme.onPrimaryContainer;

    return CupertinoButton(
      color: backgroundColor,
      onPressed: onPressed,
      child: SizedBox(
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isNavigation ? _chevronSize : 0,
              ),
              child: Column(
                spacing: 4,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: textTheme.titleLarge?.copyWith(color: labelColor),
                  ),
                  if (description != null)
                    Text(
                      description!,
                      textAlign: TextAlign.center,
                      style: textTheme.labelLarge?.copyWith(color: labelColor),
                    ),
                ],
              ),
            ),
            if (isNavigation)
              Positioned(
                right: 0,
                child: Icon(
                  CupertinoIcons.chevron_forward,
                  size: _chevronSize,
                  color: labelColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
