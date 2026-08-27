import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'package:studio_chance/constants/data_constants.dart';
import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/domain/entities/invite_info.dart';
import 'package:studio_chance/domain/entities/store_member_info.dart';
import 'package:studio_chance/presentation/colors.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/commons/widgets/custom_alert_dialog.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar/modal_app_bar.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/grouped_form_container.dart';
import 'package:studio_chance/presentation/commons/widgets/modal_grabber.dart';
import 'package:studio_chance/presentation/commons/widgets/safe_area_with_padding.dart';
import 'package:studio_chance/presentation/providers/invite_code_controller.dart';
import 'package:studio_chance/presentation/providers/pending_member_controller.dart';
import 'package:studio_chance/presentation/providers/store_detail_provider.dart';

const double _kModalInitialSize = 0.5;
const double _kModalMaxSize = 1.0;

/// 초대 코드 복사·공유·재발급 아이콘 크기. IconButton 기본값(24)은 코드 텍스트보다
/// 커 보여 시선을 뺏으므로 한 단계 줄인다.
const double _kInviteActionIconSize = 20;

/// 승인 대기 멤버 모달.
///
/// 각 항목: (닉네임) (신청 역할) (거절) (승인).
/// 승인 시 역할은 신청자가 초대 코드 단계에서 선택한 값을 그대로 사용한다.
///
/// 두 detent 시트 구조는 [StoreFilterModal]과 동일하다 (CLAUDE.md "모달 시트 패턴").
class PendingMemberModal extends ConsumerStatefulWidget {
  const PendingMemberModal({
    super.key,
    required this.storeId,
    required this.maxAvailableHeight,
  });

  final String storeId;
  final double maxAvailableHeight;

  @override
  ConsumerState<PendingMemberModal> createState() => _PendingMemberModalState();
}

class _PendingMemberModalState extends ConsumerState<PendingMemberModal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sheetController;
  double _grabberDragStartSize = _kModalInitialSize;
  double _grabberDragStartY = 0;

  @override
  void initState() {
    super.initState();
    _sheetController = AnimationController(
      vsync: this,
      value: _kModalInitialSize,
      lowerBound: _kModalInitialSize,
      upperBound: _kModalMaxSize,
    );
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  void _dismissModal() => Navigator.pop(context);

  void _animateTo(double target) {
    _sheetController.animateTo(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _snapToNearest() {
    const mid = (_kModalInitialSize + _kModalMaxSize) / 2;
    _animateTo(
      _sheetController.value >= mid ? _kModalMaxSize : _kModalInitialSize,
    );
  }

  String _displayName(StoreMemberInfo info) =>
      info.user.nickname ?? info.user.name;

  void _onApprove(StoreMemberInfo info) {
    showCustomAlertDialog(
      context: context,
      title: '${_displayName(info)}님을 승인할까요?',
      content: '${info.role.displayName} 역할로 점포에 참여하게 됩니다.',
      onConfirmAfterPop: () {
        ref
            .read(pendingMemberControllerProvider.notifier)
            .approve(
              storeId: widget.storeId,
              uid: info.user.id,
              role: info.role,
            );
      },
    );
  }

  void _onReject(StoreMemberInfo info) {
    showCustomAlertDialog(
      context: context,
      title: '${_displayName(info)}님의 신청을 거절할까요?',
      content: '거절한 신청은 되돌릴 수 없습니다.',
      confirmText: '거절',
      isDestructive: true,
      onConfirmAfterPop: () {
        ref
            .read(pendingMemberControllerProvider.notifier)
            .reject(storeId: widget.storeId, uid: info.user.id);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final storeAsync = ref.watch(storeDetailProvider(widget.storeId));
    final waitingInfos = storeAsync.asData?.value?.waitingMemberInfos ?? [];
    final isLoadingStore = storeAsync.isLoading;
    // storeDetailProvider는 조회 실패도 null로 흡수하므로(store_detail_provider.dart),
    // value == null && !isLoading은 "정말 대기자가 없음"과 구분되는 조회 실패/미존재 상태다.
    final hasLoadFailed = !isLoadingStore && storeAsync.asData?.value == null;
    // 승인/거절 처리 중에는 버튼을 비활성화해 같은 신청의 중복 제출을 막는다.
    final isMutating = ref.watch(pendingMemberControllerProvider).isLoading;

    return AnimatedBuilder(
      animation: _sheetController,
      builder: (ctx, child) => SizedBox(
        height: widget.maxAvailableHeight * _sheetController.value,
        child: child,
      ),
      child: Material(
        color: context.systemGroupedBackground,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(modalTopCornerRadius),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (event) {
                _grabberDragStartSize = _sheetController.value;
                _grabberDragStartY = event.position.dy;
              },
              onPointerMove: (event) {
                final delta = -event.delta.dy / widget.maxAvailableHeight;
                _sheetController.value = (_sheetController.value + delta).clamp(
                  _kModalInitialSize,
                  _kModalMaxSize,
                );
              },
              onPointerUp: (event) {
                final totalDy = event.position.dy - _grabberDragStartY;
                if (totalDy.abs() < 10) return;
                if (totalDy > 30) {
                  if (_grabberDragStartSize <= _kModalInitialSize + 0.05) {
                    _dismissModal();
                  } else {
                    _animateTo(_kModalInitialSize);
                  }
                } else if (totalDy < -30) {
                  _animateTo(_kModalMaxSize);
                } else {
                  _snapToNearest();
                }
              },
              onPointerCancel: (_) => _snapToNearest(),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ModalGrabber(),
                  ModalAppBar(title: '가입 신청'),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: SafeAreaWithPadding(
                  top: false,
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    horizontalPadding,
                    16,
                    horizontalPadding,
                    8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 24,
                    children: [
                      // 초대 코드 발급은 점포 조회 성공 여부와 무관하게 동작하므로
                      // 대기 명단의 로딩·실패 분기 바깥에 둔다.
                      _InviteCodeSection(
                        storeId: widget.storeId,
                        storeName: storeAsync.asData?.value?.name,
                        savedInvite: storeAsync.asData?.value?.inviteInfo,
                      ),
                      if (isLoadingStore)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: CircularProgressIndicator.adaptive(),
                          ),
                        )
                      else if (hasLoadFailed || waitingInfos.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Text(
                            hasLoadFailed
                                ? '가입 신청 정보를 불러오지 못했습니다'
                                : '대기 중인 가입 신청이 없습니다',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: context.secondaryLabel),
                          ),
                        )
                      else
                        GroupedFormContainer(
                          children: [
                            for (final info in waitingInfos)
                              _PendingMemberRow(
                                name: _displayName(info),
                                roleLabel: info.role.displayName,
                                disabled: isMutating,
                                onApprove: () => _onApprove(info),
                                onReject: () => _onReject(info),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 초대 코드 발급 섹션.
///
/// 발급 전에는 [발급] 버튼만 두고, 발급 후 코드와 공유·복사 버튼을 보여준다.
/// 모달을 열 때마다 발급 전 상태로 시작한다 — [InviteInfo]에 `createdAt`이 없어
/// 이미 발급된 코드의 만료 여부를 클라이언트가 판단할 수 없기 때문이다.
/// 유효 기간이 남아 있으면 Repository가 같은 코드를 되돌려주므로 발급을 눌러도
/// 코드가 바뀌지 않는다.
class _InviteCodeSection extends ConsumerStatefulWidget {
  const _InviteCodeSection({
    required this.storeId,
    required this.storeName,
    required this.savedInvite,
  });

  final String storeId;

  /// 공유 문구에 넣을 점포명. 점포 조회 실패 시 null이며, 이때는 코드만 공유한다.
  final String? storeName;

  /// 점포 문서에 이미 저장된 초대 코드. 유효 기간이 남아 있으면 모달을 열자마자
  /// 보여준다 (발급을 다시 누르지 않아도 되도록).
  final InviteInfo? savedInvite;

  @override
  ConsumerState<_InviteCodeSection> createState() => _InviteCodeSectionState();
}

class _InviteCodeSectionState extends ConsumerState<_InviteCodeSection> {
  /// 복사 완료 피드백을 스낵바가 아닌 아이콘 전환으로 보여주기 위한 플래그.
  /// [ScaffoldMessenger]의 스낵바는 뒤에 있는 Scaffold에 붙어 모달 시트에
  /// 가려지므로, 이 화면에서는 사용자에게 도달하지 않는다.
  bool _isCopied = false;
  Timer? _copiedResetTimer;

  bool _didReset = false;

  /// 남은 유효 시간 표시를 1초마다 갱신한다.
  Timer? _tickTimer;

  @override
  void initState() {
    super.initState();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // MyPageScreen이 발급 실패를 듣기 위해 컨트롤러를 계속 구독하고 있어
    // 모달이 닫혀도 autoDispose되지 않는다. 리셋하지 않으면 다시 열었을 때
    // 만료됐을 수 있는 코드가, 다른 점포의 모달에서는 남의 점포 코드가 남는다.
    //
    // initState에서는 ProviderScope를 아직 조회할 수 없어 여기서 한 번만 실행한다.
    if (_didReset) return;
    _didReset = true;
    ref.invalidate(inviteCodeControllerProvider);
  }

  @override
  void dispose() {
    _copiedResetTimer?.cancel();
    _tickTimer?.cancel();
    super.dispose();
  }

  String _shareText(String code) {
    final storeName = widget.storeName;
    final prefix = storeName == null ? '초대 코드' : '[$storeName] 초대 코드';
    return '$prefix: $code\n'
        '$storeInviteCodeAvailableMin분 이내에 입력해 주세요.';
  }

  void _onCopy(String code) {
    Clipboard.setData(ClipboardData(text: code));
    _copiedResetTimer?.cancel();
    setState(() => _isCopied = true);
    _copiedResetTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isCopied = false);
    });
  }

  /// 코드를 새로 만들어 덮어쓴다.
  ///
  /// 코드를 폐기하는 별도 경로가 없으므로, 유출된 코드를 즉시 막는 수단도
  /// 이 재발급이다. 옛 코드는 되돌릴 수 없게 되므로 확인을 한 번 받는다.
  void _onRegenerate() {
    showCustomAlertDialog(
      context: context,
      title: '초대 코드를 재발급할까요?',
      content: '기존 코드는 즉시 사용할 수 없게 됩니다.',
      confirmText: '재발급',
      isDestructive: true,
      onConfirmAfterPop: () {
        ref
            .read(inviteCodeControllerProvider.notifier)
            .issue(widget.storeId, forceRegenerate: true);
      },
    );
  }

  /// 화면에 보여줄 초대 코드.
  ///
  /// 방금 발급한 코드([issued])는 만료 전까지 그대로 쓴다. 반대로 점포 문서에
  /// 저장돼 있던 코드는 **만료 시각을 알 수 있을 때만** 쓴다 — `createdAt`이
  /// 없으면 이미 만료됐는지 판단할 수 없어, 죽은 코드를 보여주느니 숨긴다.
  InviteInfo? _visibleInvite(InviteInfo? issued) {
    final now = DateTime.now();
    if (issued != null) {
      final expiresAt = issued.expiresAt;
      return expiresAt == null || expiresAt.isAfter(now) ? issued : null;
    }

    final saved = widget.savedInvite;
    final savedExpiresAt = saved?.expiresAt;
    if (savedExpiresAt == null || !savedExpiresAt.isAfter(now)) return null;
    return saved;
  }

  /// 남은 유효 시간 안내. 만료 시각을 모르면 고정 문구로 대체한다.
  ///
  /// 기준은 로컬 시계다. 만료 판정 자체는 서버 시각으로 하므로(`StoreRepositoryImpl`)
  /// 여기의 오차는 표시에만 영향을 준다.
  String _validityLabel(InviteInfo invite) {
    final expiresAt = invite.expiresAt;
    if (expiresAt == null) return '$storeInviteCodeAvailableMin분간 유효합니다';

    final remaining = expiresAt.difference(DateTime.now());
    if (remaining <= Duration.zero) return '만료됐습니다';

    final minutes = remaining.inMinutes.toString().padLeft(2, '0');
    final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds 남음';
  }

  /// 초대 코드 행의 액션 아이콘.
  ///
  /// IconButton 기본 탭 영역(48)은 아이콘 사이를 28px 벌려 세 개가 나란히
  /// 서면 흩어져 보인다. compact로 40까지 좁힌다 — 더 줄이면 탭 영역이
  /// 손가락에 비해 작아진다.
  Widget _actionIcon({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, color: color),
      iconSize: _kInviteActionIconSize,
      visualDensity: VisualDensity.compact,
      tooltip: tooltip,
      onPressed: onPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final inviteAsync = ref.watch(inviteCodeControllerProvider);
    // 발급 실패(AsyncError)는 MyPageScreen의 ref.listen이 다이얼로그로 알리므로
    // 여기서는 발급 전과 동일하게 다시 시도할 수 있는 상태로 둔다.
    final invite = _visibleInvite(inviteAsync.value);
    final code = invite?.inviteCode;

    return GroupedFormContainer(
      footer: invite == null
          ? null
          : Padding(
              padding: const EdgeInsetsDirectional.only(
                start: horizontalPadding,
                top: 8,
              ),
              child: Text(
                _validityLabel(invite),
                style: textTheme.labelMedium?.copyWith(
                  color: context.secondaryLabel,
                ),
              ),
            ),
      children: [
        SizedBox(
          height: inputFormComponentHeight,
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: horizontalPadding,
            ),
            child: Row(
              children: [
                Expanded(child: Text('초대 코드', style: textTheme.bodyLarge)),
                if (code == null)
                  _ActionCapsule(
                    label: '발급',
                    background: colorScheme.primaryContainer,
                    foreground: colorScheme.onPrimaryContainer,
                    // 발급 중에는 비활성화해 연타로 인한 중복 발급을 막는다.
                    onPressed: inviteAsync.isLoading
                        ? null
                        : () => ref
                              .read(inviteCodeControllerProvider.notifier)
                              .issue(widget.storeId),
                  )
                else ...[
                  Text(
                    code,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      // 6자리 코드를 눈으로 받아적기 쉽도록 자간을 벌린다.
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(width: 4),
                  _actionIcon(
                    icon: _isCopied
                        ? CupertinoIcons.checkmark_alt
                        : CupertinoIcons.doc_on_doc,
                    color: colorScheme.primary,
                    tooltip: '복사',
                    onPressed: () => _onCopy(code),
                  ),
                  _actionIcon(
                    icon: CupertinoIcons.share,
                    color: colorScheme.primary,
                    tooltip: '공유',
                    onPressed: () => SharePlus.instance.share(
                      ShareParams(text: _shareText(code)),
                    ),
                  ),
                  _actionIcon(
                    icon: CupertinoIcons.arrow_counterclockwise,
                    // 옛 코드를 끊는 파괴적 동작이라 안전한 두 아이콘과 색으로 가른다.
                    color: colorScheme.error,
                    tooltip: '재발급',
                    onPressed: _onRegenerate,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 대기 멤버 한 줄: (닉네임) (신청 역할) (거절) (승인)
class _PendingMemberRow extends StatelessWidget {
  const _PendingMemberRow({
    required this.name,
    required this.roleLabel,
    required this.onApprove,
    required this.onReject,
    this.disabled = false,
  });

  final String name;
  final String roleLabel;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: inputFormComponentHeight,
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: horizontalPadding,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: textTheme.bodyLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              roleLabel,
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.normal,
                color: context.secondaryLabel,
              ),
            ),
            const SizedBox(width: 12),
            _ActionCapsule(
              label: '거절',
              background: colorScheme.errorContainer,
              foreground: colorScheme.onErrorContainer,
              onPressed: disabled ? null : onReject,
            ),
            const SizedBox(width: 8),
            _ActionCapsule(
              label: '승인',
              background: colorScheme.primaryContainer,
              foreground: colorScheme.onPrimaryContainer,
              onPressed: disabled ? null : onApprove,
            ),
          ],
        ),
      ),
    );
  }
}

/// 승인/거절 액션 버튼.
///
/// 역할 라벨과 나란히 놓이는 자리라 텍스트만으로는 버튼인지 구분되지 않는다.
/// 옅은 배경의 캡슐로 감싸 탭 가능한 요소임을 드러낸다.
class _ActionCapsule extends StatelessWidget {
  const _ActionCapsule({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onPressed,
  });

  final String label;

  /// 배경·전경 모두 ColorScheme에서 받는다. 알파를 직접 계산하면
  /// 강조색 변경이나 다크 모드 대응이 이 위젯에만 누락된다.
  final Color background;
  final Color foreground;

  /// null이면 비활성 (처리 중 중복 제출 차단)
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;

    return CupertinoButton(
      minimumSize: Size.zero,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      borderRadius: BorderRadius.circular(100),
      color: background,
      disabledColor: context.quaternarySystemFill,
      onPressed: onPressed,
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: isDisabled ? context.tertiaryLabel : foreground,
        ),
      ),
    );
  }
}

/// 승인 대기 멤버 모달 표시.
Future<void> showPendingMemberModal(BuildContext context, String storeId) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    barrierColor: modalBarrierColor,
    builder: (ctx) => LayoutBuilder(
      builder: (_, constraints) => PendingMemberModal(
        storeId: storeId,
        maxAvailableHeight: constraints.maxHeight,
      ),
    ),
  );
}
