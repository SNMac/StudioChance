import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:studio_chance/domain/entities/reservation.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/presentation/commons/extensions/phone_formatter.dart';
import 'package:studio_chance/presentation/commons/extensions/price_formatter.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/states/store_form_state.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_creation_controller.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_update_controller.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/custom_app_bar.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/grouped_form_container.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/text_action_button.dart';
import 'package:studio_chance/presentation/providers/store_detail_provider.dart';

class PaymentInstructionScreen extends ConsumerWidget {
  /// [reservation]이 null이면 미리보기 모드
  /// [previewStoreToEdit] — 수정 모드일 때 어느 폼 컨트롤러를 읽을지 결정 (null = 생성 모드)
  const PaymentInstructionScreen({super.key, this.reservation, this.previewStoreToEdit});

  final Reservation? reservation;
  final Store? previewStoreToEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    if (reservation == null) {
      final formState = previewStoreToEdit != null
          ? ref.watch(storeUpdateControllerProvider(previewStoreToEdit!))
          : ref.watch(storeCreationControllerProvider);
      return _buildScaffold(context, textTheme, _buildPreviewText(formState));
    }

    final storeAsync = ref.watch(
      storeDetailProvider(reservation!.storeSummary.id),
    );

    return Scaffold(
      appBar: const CustomAppBar(title: '입금 안내문'),
      body: SafeArea(
        child: storeAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => _buildContent(context, textTheme, null),
          data: (store) => _buildContent(context, textTheme, store),
        ),
      ),
    );
  }

  Scaffold _buildScaffold(BuildContext context, TextTheme textTheme, String text) {
    return Scaffold(
      appBar: const CustomAppBar(title: '입금 안내문'),
      body: SafeArea(child: _buildBody(context, textTheme, text)),
    );
  }

  Widget _buildContent(BuildContext context, TextTheme textTheme, Store? store) {
    return _buildBody(context, textTheme, _buildText(reservation!, store));
  }

  Widget _buildBody(BuildContext context, TextTheme textTheme, String text) {
    return Stack(
      children: [
        Positioned.fill(
          child: SingleChildScrollView(
            // 버튼 영역 높이(상단 gap 32 + 버튼 48×2 + 구분선 1 + 하단 패딩 16)만큼
            // 하단 패딩을 줘서 마지막 내용이 버튼에 가리지 않도록 함
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 145),
            child: Text(
              text,
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
            child: GroupedFormContainer(
              children: [
                TextActionButton(
                  title: '복사하기',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('복사됐습니다.')),
                    );
                  },
                ),
                TextActionButton(
                  title: '공유하기',
                  onPressed: () => SharePlus.instance.share(
                    ShareParams(text: text),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) return '$minutes분';
    final hours = minutes ~/ 60;
    final remaining = minutes % 60;
    if (remaining == 0) return '$hours시간';
    return '$hours시간 $remaining분';
  }

  String _buildPreviewText(StoreFormState formState) {
    final bankName = formState.bankName.isEmpty ? '{은행}' : formState.bankName;
    final accountNumber = formState.bankAccountNumber.isEmpty
        ? '{계좌번호}'
        : formState.bankAccountNumber;
    final accountHolder = formState.bankAccountHolder.isEmpty
        ? '{예금주}'
        : formState.bankAccountHolder;

    final deadlineLine = formState.paymentDeadlineMinutes != null
        ? '✔ 입금 마감 시간: 앱에 예약 등록한 시간 기준 ${_formatDuration(formState.paymentDeadlineMinutes!)} 이내\n'
        : '';

    return '[{점포명} 예약 입금 안내]\n'
        '안녕하세요, {점포명}입니다.\n'
        '\n'
        '아래 내용으로 예약이 진행되었으며, 입금을 완료해 주시면 예약이 확정됩니다.\n'
        '\n'
        '• 예약자명: {예약자명}\n'
        '• 예약자 전화번호: {예약자 전화번호}\n'
        '• 예약 시간: {yyyy}년 {mm}월 {dd}일 ({요일}) {hh}시 ~ {hh}시 ({n}시간)\n'
        '• 예약 인원: {예약 인원}인\n'
        '• 요금 안내: {요금}원\n'
        '\n'
        '✔ 입금 계좌: $bankName $accountNumber ($accountHolder)\n'
        '$deadlineLine'
        '\n'
        '예약자와 실제 이용자의 이름 및 전화번호가 다를 경우 미리 알려주세요.\n'
        '입금 확인 후 예약 확정 안내를 드리겠습니다.\n'
        '\n'
        '감사합니다.';
  }

  String _buildText(Reservation r, Store? store) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[r.startTime.weekday - 1];

    final String timeStr;
    if (r.isAllDay) {
      // iCal 관례: 종일 endTime = 다음날 자정(exclusive) → -1일 보정
      final displayEnd = r.endTime.subtract(const Duration(days: 1));
      final isSameDay = r.startTime.year == displayEnd.year &&
          r.startTime.month == displayEnd.month &&
          r.startTime.day == displayEnd.day;
      if (isSameDay) {
        timeStr = '${r.startTime.year}년 '
            '${r.startTime.month.toString().padLeft(2, '0')}월 '
            '${r.startTime.day.toString().padLeft(2, '0')}일 ($weekday) 하루종일';
      } else {
        final endWeekday = weekdays[displayEnd.weekday - 1];
        timeStr = '${r.startTime.year}년 '
            '${r.startTime.month.toString().padLeft(2, '0')}월 '
            '${r.startTime.day.toString().padLeft(2, '0')}일 ($weekday) ~ '
            '${displayEnd.year}년 '
            '${displayEnd.month.toString().padLeft(2, '0')}월 '
            '${displayEnd.day.toString().padLeft(2, '0')}일 ($endWeekday)';
      }
    } else {
      final durationHours = r.endTime.difference(r.startTime).inHours;
      final isSameDay = r.startTime.year == r.endTime.year &&
          r.startTime.month == r.endTime.month &&
          r.startTime.day == r.endTime.day;
      if (isSameDay) {
        timeStr = '${r.startTime.year}년 '
            '${r.startTime.month.toString().padLeft(2, '0')}월 '
            '${r.startTime.day.toString().padLeft(2, '0')}일 ($weekday) '
            '${r.startTime.hour.toString().padLeft(2, '0')}시 ~ '
            '${r.endTime.hour.toString().padLeft(2, '0')}시 '
            '($durationHours시간)';
      } else {
        final endWeekday = weekdays[r.endTime.weekday - 1];
        timeStr = '${r.startTime.year}년 '
            '${r.startTime.month.toString().padLeft(2, '0')}월 '
            '${r.startTime.day.toString().padLeft(2, '0')}일 ($weekday) '
            '${r.startTime.hour.toString().padLeft(2, '0')}시 ~ '
            '${r.endTime.year}년 '
            '${r.endTime.month.toString().padLeft(2, '0')}월 '
            '${r.endTime.day.toString().padLeft(2, '0')}일 ($endWeekday) '
            '${r.endTime.hour.toString().padLeft(2, '0')}시 '
            '($durationHours시간)';
      }
    }

    final deadlineLine = store?.paymentDeadlineMinutes != null
        ? '✔ 입금 마감 시간: 앱에 예약 등록한 시간 기준 ${_formatDuration(store!.paymentDeadlineMinutes!)} 이내\n'
        : '';

    return '[${r.storeSummary.name} 예약 입금 안내]\n'
        '안녕하세요, ${r.storeSummary.name}입니다.\n'
        '\n'
        '아래 내용으로 예약이 진행되었으며, 입금을 완료해 주시면 예약이 확정됩니다.\n'
        '\n'
        '• 예약자명: ${r.customerName}\n'
        '• 예약자 전화번호: ${r.customerPhone.formattedPhone}\n'
        '• 예약 시간: $timeStr\n'
        '• 예약 인원: ${r.headCount}인\n'
        '• 요금 안내: ${r.totalPrice.formattedAmount}원\n'
        '\n'
        '✔ 입금 계좌: ${store?.bankName ?? ''} ${store?.bankAccountNumber ?? ''} (${store?.bankAccountHolder ?? ''})\n'
        '$deadlineLine'
        '\n'
        '예약자와 실제 이용자의 이름 및 전화번호가 다를 경우 미리 알려주세요.\n'
        '입금 확인 후 예약 확정 안내를 드리겠습니다.\n'
        '\n'
        '감사합니다.';
  }
}
