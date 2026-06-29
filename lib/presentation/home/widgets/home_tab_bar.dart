import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';

/// 홈 화면 하단 탭바
class HomeTabBar extends StatefulWidget {
  const HomeTabBar({super.key});

  @override
  State<HomeTabBar> createState() => _HomeTabBarState();
}

class _HomeTabBarState extends State<HomeTabBar> {
  /// 현재 선택된 탭 인덱스 (초기값: 0번 탭 - 홈)
  int _selectedIndex = 0;

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

  /// 탭 선택 시 상태 업데이트
  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    // 비선택 아이콘/텍스트 색상
    const Color inactiveColor = Color(0xFF999999);
    // 선택된 아이콘/텍스트 색상
    final Color activeColor = context.systemBlue;

    return Container(
      height: tabBarHeight + bottomPadding,
      decoration: BoxDecoration(
        color: context.systemBackground,
        border: Border(
          top: BorderSide(
            color: context.separator,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final tab = _tabs[index];
          final bool isSelected = index == _selectedIndex;
          final Color color = isSelected ? activeColor : inactiveColor;

          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _onTabTapped(index),
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
