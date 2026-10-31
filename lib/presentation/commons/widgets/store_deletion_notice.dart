import 'package:material_ui/material_ui.dart';

import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';

/// 삭제 예정 점포 안내 카드 — 남은 기간과 그동안 할 수 없는 일 (ADR-0007).
/// 점포 상세와 예약 상세 맨 위에 둔다
class StoreDeletionNotice extends StatelessWidget {
  const StoreDeletionNotice({
    super.key,
    required this.title,
    required this.message,
  });

  /// 남은 기간 (예: "3일 후 삭제됩니다")
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.secondarySystemGroupedBackground,
        borderRadius: BorderRadius.circular(formBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            Text(
              title,
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.systemRed,
              ),
            ),
            Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color: context.secondaryLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
