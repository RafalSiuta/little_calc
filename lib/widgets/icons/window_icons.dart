import 'package:flutter/material.dart';

import '../../utils/styles/theme.dart';

class WindowMinimizeIcon extends StatelessWidget {
  const WindowMinimizeIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 2,
      color: context.calcTheme.unselected,
    );
  }
}

class WindowMaximizeIcon extends StatelessWidget {
  const WindowMaximizeIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final calcTheme = context.calcTheme;

    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        border: Border.all(
          color: calcTheme.unselected,
          width: 2,
        ),
      ),
    );
  }
}

class WindowCloseIcon extends StatelessWidget {
  const WindowCloseIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final calcTheme = context.calcTheme;

    return CustomPaint(
      size: const Size(14, 14),
      painter: _WindowCloseIconPainter(color: calcTheme.unselected),
    );
  }
}

class _WindowCloseIconPainter extends CustomPainter {
  const _WindowCloseIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.square;
    canvas.drawLine(Offset.zero, Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _WindowCloseIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
