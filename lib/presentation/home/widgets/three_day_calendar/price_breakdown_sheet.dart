import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/domain/entities/price_breakdown.dart';
import 'package:studio_chance/presentation/colors.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/commons/extensions/price_breakdown_formatter.dart';
import 'package:studio_chance/presentation/commons/extensions/price_formatter.dart';
import 'package:studio_chance/presentation/commons/extensions/time_formatter.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/app_bar_action_button.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/modal_app_bar.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/title_text_label.dart';
import 'package:studio_chance/presentation/commons/widgets/safe_area_with_padding.dart';

/// 계산 내역이 어느 요금표로 계산됐는지.
enum PriceBreakdownBasis {
  saved('예약 당시 요금 기준'),
  current('점포의 현재 요금 기준');

  const PriceBreakdownBasis(this.label);

  final String label;
}

/// 계산 내역을 보여줄 수 없는 원인.
enum PriceBreakdownUnavailableReason {
  /// 점포에 공간이 없어 적용할 요금표가 없다 — 사용자가 점포 설정에서 고칠 수 있다
  noSpacePrice('점포에 등록된 공간 요금이 없어\n계산 내역을 표시할 수 없습니다'),

  /// 공간 목록을 아직 불러오지 못했거나 실패했다
  notLoaded('요금 정보를 불러오지 못해\n계산 내역을 표시할 수 없습니다');

  const PriceBreakdownUnavailableReason(this.message);

  final String message;
}

/// 예약 모달 위에 요금 계산 내역 시트를 띄운다.
///
/// 시트 위에 띄우는 시트라 드래그 없는 단순 시트로 둔다. [breakdown]이 null이면
/// [unavailableReason]을 보여준다. [calculatedPrice]와 [adjustment]는 모달에 표시 중인 값이며,
/// 내역이 있으면 계산 요금은 [calculatedPrice] 대신 내역 합계를 쓴다.
///
/// [onOpenPriceSetting]을 주면(점포 ADMIN) 요금표가 비어 있을 때 요금 설정으로 가는 버튼을
/// 보여준다. 버튼을 누르면 시트를 닫은 뒤 호출한다 — 예약 모달은 열어 둔 채 그 위로 이동한다.
Future<void> showPriceBreakdownSheet(
  BuildContext context, {
  required PriceBreakdown? breakdown,
  PriceBreakdownBasis basis = PriceBreakdownBasis.current,
  PriceBreakdownUnavailableReason unavailableReason =
      PriceBreakdownUnavailableReason.notLoaded,
  required int calculatedPrice,
  required int adjustment,
  List<String> Function(DateTime date) holidayNamesOf = _noHolidayNames,
  VoidCallback? onOpenPriceSetting,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    barrierColor: modalBarrierColor,
    builder: (_) => PriceBreakdownSheet(
      breakdown: breakdown,
      basis: basis,
      unavailableReason: unavailableReason,
      calculatedPrice: calculatedPrice,
      adjustment: adjustment,
      holidayNamesOf: holidayNamesOf,
      onOpenPriceSetting: onOpenPriceSetting,
    ),
  );
}

List<String> _noHolidayNames(DateTime date) => const [];

class PriceBreakdownSheet extends StatelessWidget {
  const PriceBreakdownSheet({
    super.key,
    required this.breakdown,
    required this.basis,
    required this.unavailableReason,
    required this.calculatedPrice,
    required this.adjustment,
    required this.holidayNamesOf,
    this.onOpenPriceSetting,
  });

  final PriceBreakdown? breakdown;
  final PriceBreakdownBasis basis;
  final PriceBreakdownUnavailableReason unavailableReason;
  final int calculatedPrice;
  final int adjustment;
  final List<String> Function(DateTime date) holidayNamesOf;
  final VoidCallback? onOpenPriceSetting;

  /// 요금표를 채우면 해결되는 상황인지 — 불러오기 실패는 요금 설정으로 고칠 수 없다
  bool get _needsPriceSetting => switch (breakdown) {
    final breakdown? => breakdown.hasUnpricedRange,
    null => unavailableReason == PriceBreakdownUnavailableReason.noSpacePrice,
  };

  Widget? _priceSettingShortcut(BuildContext context) {
    final onOpen = onOpenPriceSetting;
    if (onOpen == null || !_needsPriceSetting) return null;
    return _PriceSettingShortcut(
      // 공간이 없을 때는 위의 원인 문구가 이미 설명한다
      hint: breakdown == null ? null : '요금이 설정되지 않은 시간이 있습니다',
      onPressed: () {
        Navigator.of(context).pop();
        onOpen();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final breakdown = this.breakdown;
    // 시트 안에서는 항목 합과 계산 요금이 항상 같아야 한다 — 모달이 공간 목록을 불러오기 전이면
    // 저장된 요금을 넘길 수 있으므로 내역이 있으면 그 합계를 쓴다
    final calculated = breakdown?.total ?? calculatedPrice;
    final shortcut = _priceSettingShortcut(context);

    return Material(
      color: context.systemGroupedBackground,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(modalTopCornerRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ModalAppBar(
            title: '요금 계산 내역',
            leading: AppBarActionButton(
              label: '닫기',
              isRegularWeight: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              child: SafeAreaWithPadding(
                top: false,
                padding: const EdgeInsetsDirectional.fromSTEB(
                  horizontalPadding,
                  8,
                  horizontalPadding,
                  8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: breakdown == null
                      ? [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Text(
                              unavailableReason.message,
                              textAlign: TextAlign.center,
                              style: textTheme.bodyLarge?.copyWith(
                                color: context.secondaryLabel,
                              ),
                            ),
                          ),
                          ?shortcut,
                          _Card(children: _summaryRows(calculated)),
                        ]
                      : [
                          Padding(
                            padding: const EdgeInsetsDirectional.only(
                              start: horizontalPadding,
                              bottom: 8,
                            ),
                            child: Text(
                              basis.label,
                              style: textTheme.labelMedium?.copyWith(
                                color: context.secondaryLabel,
                              ),
                            ),
                          ),
                          _Card(
                            children: [
                              for (final (i, day)
                                  in breakdown.days.indexed) ...[
                                if (i > 0) const _Separator(),
                                _DayHeader(
                                  day: day,
                                  holidayNames: holidayNamesOf(day.date),
                                ),
                                for (final item in day.items)
                                  _ItemRow(item: item),
                              ],
                              const SizedBox(height: 8),
                              const _Separator(indent: 0, thickness: 1),
                              ..._summaryRows(calculated),
                            ],
                          ),
                          ?shortcut,
                        ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _summaryRows(int calculated) => [
    TitleTextLabel(title: '계산 요금', content: calculated.formattedPrice),
    const _Separator(),
    TitleTextLabel(title: '추가 요금/할인', content: adjustment.formattedPrice),
    const _Separator(),
    TitleTextLabel(
      title: '최종 요금',
      content: (calculated + adjustment).formattedPrice,
    ),
  ];
}

/// 요금 설정 화면으로 가는 버튼과 그 이유
class _PriceSettingShortcut extends StatelessWidget {
  const _PriceSettingShortcut({required this.hint, required this.onPressed});

  final String? hint;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        spacing: 4,
        children: [
          if (hint != null)
            Text(
              hint!,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: context.secondaryLabel,
              ),
            ),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            minimumSize: Size.zero,
            onPressed: onPressed,
            child: Text(
              '요금 설정',
              style: textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// [GroupedFormContainer]와 같은 카드지만 행 사이 구분선을 직접 둔다 — 한 날짜의 항목끼리는
/// 구분선 없이 붙여 명세서처럼 읽히게 하기 위함.
class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.secondarySystemGroupedBackground,
        borderRadius: BorderRadius.circular(formBorderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _Separator extends StatelessWidget {
  const _Separator({this.indent = horizontalPadding, this.thickness = 0.5});

  final double indent;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: indent),
      child: Divider(
        height: thickness,
        thickness: thickness,
        color: context.separator,
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.day, required this.holidayNames});

  final PricedDay day;
  final List<String> holidayNames;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final date = day.date;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        horizontalPadding,
        12,
        horizontalPadding,
        2,
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            '${date.month}월 ${date.day}일 (${date.weekdayLabel})',
            style: textTheme.bodySmall?.copyWith(color: context.secondaryLabel),
          ),
          if (day.holidayRateApplied)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: context.systemRed.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                // 이름은 현재 공휴일 달력에서 찾으므로 공휴일 스냅샷에만 남은 날짜는 이름이 없을 수 있다
                holidayNames.isEmpty
                    ? '공휴일 요금'
                    : '공휴일 요금 · ${holidayNames.join(', ')}',
                style: textTheme.labelSmall?.copyWith(
                  color: context.systemRed,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});

  final PriceItem item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: horizontalPadding,
        vertical: 4,
      ),
      child: Row(
        spacing: 12,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: textTheme.bodyMedium),
                Text(
                  item.formula,
                  style: textTheme.labelMedium?.copyWith(
                    // 요금 설정이 없어 0원이 된 구간은 사용자가 알아채도록 강조한다
                    color: item is UnpricedRange
                        ? context.systemRed
                        : context.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
          Text(
            item.amount.formattedPrice,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.normal,
              color: context.label,
            ),
          ),
        ],
      ),
    );
  }
}
