import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';

class TitlePopupButton<T> extends StatefulWidget {
  final String title;
  final T selectedValue;
  final List<T> items;
  final ValueChanged<T> onSelected;
  final String Function(T) itemLabelBuilder;
  final Widget Function(T)? itemLeadingBuilder;

  const TitlePopupButton({
    super.key,
    required this.title,
    required this.selectedValue,
    required this.items,
    required this.onSelected,
    required this.itemLabelBuilder,
    this.itemLeadingBuilder,
  });

  @override
  State<TitlePopupButton<T>> createState() => _TitlePopupButtonState<T>();
}

class _TitlePopupButtonState<T> extends State<TitlePopupButton<T>> {
  final GlobalKey<PopupMenuButtonState<T>> _menuKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: inputFormComponentHeight,
      child: CupertinoButton(
        padding: EdgeInsetsDirectional.zero,
        onPressed: () => _menuKey.currentState?.showButtonMenu(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(widget.title, style: textTheme.bodyLarge),

            // 큰 글자 배율이나 긴 점포명에서 폭이 모자라면 값 쪽만 말줄임한다 (#58).
            // 전체 값은 팝업 메뉴에서 볼 수 있다
            Flexible(
              child: PopupMenuButton<T>(
                key: _menuKey,
                onSelected: widget.onSelected,
                color: context.tertiarySystemGroupedBackground,
                surfaceTintColor: Colors.transparent,
                elevation: 1,
                offset: const Offset(0, 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.itemLeadingBuilder != null) ...[
                      widget.itemLeadingBuilder!(widget.selectedValue),
                      const SizedBox(width: 8),
                    ],

                    Flexible(
                      child: Text(
                        widget.itemLabelBuilder(widget.selectedValue),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.normal,
                          color: context.secondaryLabel,
                        ),
                      ),
                    ),

                    const SizedBox(width: 4),

                    Icon(
                      CupertinoIcons.chevron_up_chevron_down,
                      size: 16,
                      color: context.secondaryLabel,
                    ),
                  ],
                ),

                itemBuilder: (BuildContext context) {
                  return widget.items.map((T item) {
                    final bool isSelected = item == widget.selectedValue;
                    return PopupMenuItem<T>(
                      value: item,
                      child: SizedBox(
                        height: 44,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              child: isSelected
                                  ? const Icon(
                                      CupertinoIcons.checkmark,
                                      size: 16,
                                    )
                                  : null,
                            ),

                            if (widget.itemLeadingBuilder != null) ...[
                              widget.itemLeadingBuilder!(item),
                            ],

                            Flexible(
                              child: Text(
                                widget.itemLabelBuilder(item),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.normal),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
