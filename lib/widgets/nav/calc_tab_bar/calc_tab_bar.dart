import 'package:flutter/material.dart';

import '../../../utils/styles/theme.dart';

class CalcTabBar extends StatelessWidget implements PreferredSizeWidget {
  const CalcTabBar({
    Key? key,
    required this.tabs,
    this.trailing,
  }) : super(key: key);

  final List<String> tabs;
  final Widget? trailing;

  @override
  Size get preferredSize => const Size.fromHeight(34);

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
                  isScrollable: true,
                  tabAlignment: TabAlignment.center,
                  labelPadding: EdgeInsets.symmetric(
                    horizontal: calcTheme.paddingSmall,
                  ),
                  indicator: _TopTabIndicator(
                    color: calcTheme.accent,
                    height: calcTheme.menuIndicatorHeight,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: calcTheme.accent,
                  unselectedLabelColor: calcTheme.unselected,
                  labelStyle: calcTheme.tabTextStyle,
                  unselectedLabelStyle: calcTheme.tabTextStyle,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  tabs: [
                    for (final tab in tabs)
                      Tab(
                        height: preferredSize.height,
                        child: Text(
                          tab,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (trailing != null) ...[
              SizedBox(width: calcTheme.itemSpacing),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

class _TopTabIndicator extends Decoration {
  const _TopTabIndicator({
    required this.color,
    required this.height,
  });

  final Color color;
  final double height;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _TopTabIndicatorPainter(
      color: color,
      height: height,
    );
  }
}

class _TopTabIndicatorPainter extends BoxPainter {
  const _TopTabIndicatorPainter({
    required this.color,
    required this.height,
  });

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
