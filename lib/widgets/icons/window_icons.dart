import 'package:flutter/material.dart';

import '../../utils/styles/colors.dart';

class WindowMinimizeIcon extends StatelessWidget {
  const WindowMinimizeIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 2,
      color: AppColors.background,
    );
  }
}

class WindowMaximizeIcon extends StatelessWidget {
  const WindowMaximizeIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.background,
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
    return CustomPaint(
      size: const Size(14, 14),
      painter: _WindowCloseIconPainter(),
    );
  }
}

class _WindowCloseIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.background
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.square;
    canvas.drawLine(Offset.zero, Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
