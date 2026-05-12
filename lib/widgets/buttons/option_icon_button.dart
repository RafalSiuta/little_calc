import 'package:flutter/material.dart';

import '../../utils/styles/colors.dart';

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
          constraints: const BoxConstraints.tightFor(
            width: 24,
            height: 24,
          ),
          padding: EdgeInsets.zero,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          tooltip: widget.tooltip,
          onPressed: widget.onPressed,
          icon: Icon(
            widget.icon,
            color: _iconColor,
            size: 24,
          ),
        ),
      ),
    );
  }

  Color get _iconColor {
    if (widget.usePressedAccent && _isPressed) {
      return AppDefaultColors.accent;
    }

    if (widget.isActive) {
      return AppDefaultColors.accent;
    }

    if (_isHovered) {
      return AppDefaultColors.unselectedHover;
    }

    return AppDefaultColors.unselected;
  }
}
