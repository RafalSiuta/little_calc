import 'package:flutter/material.dart';

import '../../utils/styles/theme.dart';

class WindowActionButton extends StatelessWidget {
  const WindowActionButton({
    Key? key,
    required this.child,
    required this.onPressed,
    required this.semanticLabel,
  }) : super(key: key);

  final Widget child;
  final VoidCallback onPressed;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final calcTheme = context.calcTheme;

    return Semantics(
      button: true,
      label: semanticLabel,
      child: SizedBox(
        width: calcTheme.windowActionButtonSize.width,
        height: calcTheme.windowActionButtonSize.height,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: calcTheme.windowActionBorderRadius,
            hoverColor: calcTheme.windowActionHoverColor,
            splashColor: calcTheme.windowActionSplashColor,
            highlightColor: calcTheme.windowActionHighlightColor,
            onTap: onPressed,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
