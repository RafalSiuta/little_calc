import 'package:flutter/material.dart';

import '../../utils/styles/theme.dart';

class OptionIconButton extends StatefulWidget {
  const OptionIconButton({
    Key? key,
    required this.icon,
    required this.tooltip,
    required this.isActive,
    this.size,
    this.usePressedAccent = false,
    this.onPressed,
  }) : super(key: key);

  final IconData icon;
  final String tooltip;
  final bool isActive;
  final Size? size;
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
    final size = widget.size ?? calcTheme.optionIconButtonSize;
    final iconSize = widget.size?.shortestSide ?? calcTheme.optionIconSize;
    final iconColor = _iconColor(calcTheme);

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
          constraints: BoxConstraints.tight(size),
          style: widget.size == null
              ? null
              : const ButtonStyle(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.standard,
                ),
          padding: calcTheme.optionIconButtonPadding,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          tooltip: widget.tooltip,
          onPressed: widget.onPressed,
          icon: size.width == size.height
              ? Icon(widget.icon, color: iconColor, size: iconSize)
              : ExcludeSemantics(
                  child: Text(
                    String.fromCharCode(widget.icon.codePoint),
                    textScaler: TextScaler.noScaling,
                    style: TextStyle(
                      inherit: false,
                      fontFamily: widget.icon.fontFamily,
                      package: widget.icon.fontPackage,
                      fontSize: iconSize,
                      color: iconColor,
                      height: 1,
                      leadingDistribution: TextLeadingDistribution.even,
                    ),
                  ),
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
