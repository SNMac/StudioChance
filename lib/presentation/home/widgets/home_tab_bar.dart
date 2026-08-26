import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/router/router_path.dart';

/// 홈·마이페이지가 공유하는 하단 탭바
///
/// 선택 상태는 로컬 state가 아니라 현재 라우트에서 파생한다.
/// 두 화면이 같은 위젯을 쓰면서도 선택 표시가 어긋나지 않게 하기 위함이다.
class HomeTabBar extends StatelessWidget {
  const HomeTabBar({super.key});

  /// 탭 항목 정의
  static const List<_TabItem> _tabs = [
    _TabItem(
      label: '홈',
      icon: CupertinoIcons.house,
      activeIcon: CupertinoIcons.house_fill,
    ),
    _TabItem(
      label: '예약 통계',
      icon: CupertinoIcons.chart_bar,
      activeIcon: CupertinoIcons.chart_bar_fill,
    ),
    _TabItem(
      label: '마이페이지',
      icon: CupertinoIcons.person,
      activeIcon: CupertinoIcons.person_fill,
    ),
  ];

  /// 현재 라우트로부터 선택된 탭 인덱스를 구한다.
  int _selectedIndexOf(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith(SCRoute.myPage.path)) return 2;
    if (location.startsWith(SCRoute.stats.path)) return 1;
    return 0;
  }

  void _onTabTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(SCRoute.home.path);
      case 2:
        context.go(SCRoute.myPage.path);
      // TODO: 예약 통계(stats) 화면 구현 후 연결 (#19 범위 밖)
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    // 비선택 아이콘/텍스트 색상
    const Color inactiveColor = Color(0xFF999999);
    // 선택된 아이콘/텍스트 색상
    final Color activeColor = context.systemBlue;
    final int selectedIndex = _selectedIndexOf(context);

    return Container(
      height: tabBarHeight + bottomPadding,
      decoration: BoxDecoration(
        color: context.systemBackground,
        border: Border(top: BorderSide(color: context.separator, width: 0.5)),
      ),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final tab = _tabs[index];
          final bool isSelected = index == selectedIndex;
          final Color color = isSelected ? activeColor : inactiveColor;

          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _onTabTapped(context, index),
              child: Padding(
                // 하단 safe area 높이만큼 아이콘/텍스트를 위로 올림
                padding: EdgeInsets.only(bottom: bottomPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isSelected ? tab.activeIcon : tab.icon,
                      size: 24,
                      color: color,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tab.label,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: color,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// 탭 항목 데이터 모델
class _TabItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const _TabItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}
