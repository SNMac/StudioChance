import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:studio_chance/domain/entities/reservation.dart';

/// 예약 상세 모달 (플레이스홀더 — 실제 디자인은 별도 Phase에서 구현)
///
/// 설계: 하프 시트로 시작, 위로 드래그하면 전체 화면을 덮음.
/// iOS는 SheetDetent API 미지원으로 현재 풀스크린으로 열림 (TODO(#5) 참고).
/// Android: DraggableScrollableSheet(initialChildSize: 0.5) — 하프 시트 시작.
class ReservationDetailModal extends StatelessWidget {
  const ReservationDetailModal({
    super.key,
    required this.reservation,
    this.scrollController,
  });

  final Reservation reservation;

  /// Android DraggableScrollableSheet에서 전달받는 ScrollController.
  /// TODO(#5): 실제 콘텐츠 구현 시 SingleChildScrollView/ListView에 연결 필요.
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 드래그 핸들 (pill)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              width: 36,
              height: 5,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
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
    );
  }
}

/// 예약 상세 모달 표시 (플랫폼 적응형).
///
/// iOS: [showCupertinoSheet] (드래그로 확장/축소)
/// Android: [showModalBottomSheet] + [DraggableScrollableSheet] (초기 50%)
Future<void> showReservationDetailModal(
    BuildContext context, Reservation reservation) {
  if (Platform.isIOS) {
    // TODO(#5): Flutter 3.38.5에 SheetDetent/detents 파라미터 미존재 → 풀스크린으로 열림.
    // detents: const [SheetDetent.medium, SheetDetent.large] 추가 예정.
    // iOS에서 하프 시트 동작 미지원으로 캘린더 셀 하이라이트가 뒤에 보이지 않을 수 있음.
    return showCupertinoSheet<void>(
      context: context,
      builder: (_) => ReservationDetailModal(reservation: reservation),
    );
  }
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
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
