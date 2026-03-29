import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:studio_chance/domain/entities/reservation.dart';

/// 예약 상세 모달 (플레이스홀더 — 실제 디자인은 별도 Phase에서 구현)
///
/// 설계: 하프 시트로 시작, 위로 드래그하면 전체 화면을 덮음.
/// iOS: [showCupertinoSheet]의 showDragHandle로 Grabber 자동 표시.
/// Android: [showModalBottomSheet] + [DraggableScrollableSheet] (초기 50%, 최대화 가능).
class ReservationDetailModal extends StatelessWidget {
  const ReservationDetailModal({
    super.key,
    required this.reservation,
    this.scrollController,
  });

  final Reservation reservation;

  /// DraggableScrollableSheet에서 전달받는 ScrollController (Android 전용).
  /// SingleChildScrollView에 연결하여 드래그 확장을 활성화.
  /// TODO(#5): 실제 콘텐츠 구현 시 내부 스크롤 뷰에 연결 필요.
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            // 플레이스홀더 내용
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                reservation.customerName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// 예약 상세 모달 표시 (플랫폼 적응형).
///
/// iOS: [showCupertinoSheet] + showDragHandle (Grabber 자동 표시)
/// Android: [showModalBottomSheet] + [DraggableScrollableSheet] (초기 50%, 최대화 가능)
Future<void> showReservationDetailModal(
    BuildContext context, Reservation reservation) {
  if (Platform.isIOS) {
    return showCupertinoSheet<void>(
      context: context,
      showDragHandle: true,
      // TODO(#5): 입력폼 Phase에서 topGap 설정 — 피그마 기준 safeArea 제외 537px
      // 옵션 A: topGap = MediaQuery.of(context).size.height
      //         - MediaQuery.of(context).padding.top - 537
      // 옵션 B: GlobalKey로 특정 입력칸 위치 동적 계산
      builder: (_) => ReservationDetailModal(reservation: reservation),
    );
  }
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.5,
      maxChildSize: 1.0,
      expand: false,
      builder: (_, controller) => ReservationDetailModal(
        reservation: reservation,
        scrollController: controller,
      ),
    ),
  );
}
