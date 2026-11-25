import 'package:flutter/material.dart';

import '../../../utils/styles/theme.dart';
import '../../animations/staggered_entrance.dart';

class CalcTabBar extends StatelessWidget implements PreferredSizeWidget {
  const CalcTabBar({
    Key? key,
    required this.tabs,
    this.trailing,
    this.controller,
    this.height = 34,
    this.itemSpacing = 0,
  }) : super(key: key);

  final List<String> tabs;
  final Widget? trailing;
  final TabController? controller;
  final double height;
  final double itemSpacing;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final calcTheme = context.calcTheme;

    return SizedBox(
      height: preferredSize.height,
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: calcTheme.basePadding),
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: TabBar(
                  controller: controller,
                  isScrollable: true,
                  tabAlignment: TabAlignment.center,
                  labelPadding: EdgeInsets.symmetric(
                    horizontal: calcTheme.paddingSmall + itemSpacing / 2,
                  ),
                  indicator: _TopTabIndicator(
                    color: calcTheme.accent,
                    height: calcTheme.menuIndicatorHeight,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: EdgeInsets.symmetric(
                    horizontal: itemSpacing / 2,
                  ),
                  dividerColor: Colors.transparent,
                  labelColor: calcTheme.accent,
                  unselectedLabelColor: calcTheme.unselected,
                  labelStyle: calcTheme.tabTextStyle,
                  unselectedLabelStyle: calcTheme.tabTextStyle,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  tabs: [
                    for (final (index, tab) in tabs.indexed)
                      Tab(
                        height: preferredSize.height,
                        child: StaggeredEntrance(
                          position: index,
                          child: Text(
                            tab,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (trailing != null) ...[
              SizedBox(width: calcTheme.itemSpacing),
              StaggeredEntrance(position: tabs.length, child: trailing!),
            ],
          ],
        ),
      ),
    );
  }
}

class _TopTabIndicator extends Decoration {
  const _TopTabIndicator({required this.color, required this.height});

  final Color color;
  final double height;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _TopTabIndicatorPainter(color: color, height: height);
  }
}

class _TopTabIndicatorPainter extends BoxPainter {
  const _TopTabIndicatorPainter({required this.color, required this.height});

  final Color color;
  final double height;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = configuration.size;
    if (size == null) {
      return;
    }

    final paint = Paint()..color = color;
    canvas.drawRect(
      Rect.fromLTWH(offset.dx, offset.dy, size.width, height),
      paint,
    );
  }
}
