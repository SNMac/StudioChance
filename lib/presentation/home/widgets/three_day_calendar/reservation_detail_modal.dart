import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/domain/entities/reservation.dart';
import 'package:studio_chance/presentation/colors.dart';

/// 예약 상세 모달 (플레이스홀더 — 실제 디자인은 별도 Phase에서 구현)
///
/// 설계: 입력폼 특정 필드까지 보이는 높이로 시작, 위로 드래그하면 전체 화면을 덮음.
/// 현재는 플레이스홀더이므로 initialChildSize: 0.5 임시 사용.
/// 배경/shape/DragHandle은 show 함수의 showModalBottomSheet/showCupertinoSheet가 제공.
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Center(
              child: Container(
                width: 36,
                height: 5,
                decoration: BoxDecoration(
                  color: modalGrabberColor,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
          ),
          Expanded(
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
          ),
        ],
      ),
    );
  }
}

/// 예약 상세 모달 표시 (플랫폼 적응형).
///
/// iOS: [showCupertinoSheet] + showDragHandle (Grabber 자동 표시)
///   - 살짝 내리면 스프링백, 세게 내리면 dismiss (iOS 네이티브 동작)
///   - TODO(#5): topGap — 피그마 기준 safeArea 제외 537px (입력폼 특정 필드까지)
///     옵션 A: topGap = screenHeight - safeArea.top - 537 (하드코딩)
///     옵션 B: GlobalKey로 특정 입력칸 위치 동적 계산
/// Android: [showModalBottomSheet] + [DraggableScrollableSheet]
///   - snap: [0.5, 1.0] — 살짝 내리면 0.5로 스냅백, 세게 내리면 minChildSize(0.3) 도달 → dismiss
///   - TODO(#5): initialChildSize — 현재 0.5 임시, 실제 입력폼 높이 기준으로 교체
Future<void> showReservationDetailModal(
    BuildContext context, Reservation reservation) {
  if (Platform.isIOS) {
    return showCupertinoSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => ReservationDetailModal(reservation: reservation),
    );
  }
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    barrierColor: modalBarrierColor,
    clipBehavior: Clip.antiAlias,
    shape: const RoundedRectangleBorder(
      borderRadius:
          BorderRadius.vertical(top: Radius.circular(modalTopCornerRadius)),
    ),
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 1.0,
      expand: false,
      snap: true,
      snapSizes: const [0.5, 1.0],
      builder: (_, controller) => ReservationDetailModal(
        reservation: reservation,
        scrollController: controller,
      ),
    ),
  );
}
