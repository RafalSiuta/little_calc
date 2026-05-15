import 'package:flutter/material.dart';

import '../../utils/styles/theme.dart';

class OptionIconButton extends StatefulWidget {
  const OptionIconButton({
    Key? key,
    required this.icon,
    required this.tooltip,
    required this.isActive,
    this.usePressedAccent = false,
    this.onPressed,
  }) : super(key: key);

  final IconData icon;
  final String tooltip;
  final bool isActive;
  final bool usePressedAccent;
  final VoidCallback? onPressed;

  @override
  State<OptionIconButton> createState() => _OptionIconButtonState();
}

class _OptionIconButtonState extends State<OptionIconButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final calcTheme = context.calcTheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() {
        _isHovered = false;
        _isPressed = false;
      }),
      child: Listener(
        onPointerDown: (_) {
          if (widget.onPressed != null) {
            setState(() => _isPressed = true);
          }
        },
        onPointerUp: (_) => setState(() => _isPressed = false),
        onPointerCancel: (_) => setState(() => _isPressed = false),
        child: IconButton(
          constraints: BoxConstraints.tightFor(
            width: calcTheme.optionIconButtonSize.width,
            height: calcTheme.optionIconButtonSize.height,
          ),
          padding: calcTheme.optionIconButtonPadding,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          tooltip: widget.tooltip,
          onPressed: widget.onPressed,
          icon: Icon(
            widget.icon,
            color: _iconColor(calcTheme),
            size: calcTheme.optionIconSize,
          ),
        ),
      ),
    );
  }

  Color _iconColor(CalcTheme calcTheme) {
    return calcTheme.optionIconColor(
      isActive: widget.isActive,
      isHovered: _isHovered,
      isPressed: _isPressed,
      usePressedAccent: widget.usePressedAccent,
    );
  }
}
