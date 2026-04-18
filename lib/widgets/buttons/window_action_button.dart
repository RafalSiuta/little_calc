import 'package:flutter/material.dart';

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
    return Semantics(
      button: true,
      label: semanticLabel,
      child: SizedBox(
        width: 24,
        height: 24,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(4),
            hoverColor: Colors.white.withOpacity(0.08),
            splashColor: Colors.white.withOpacity(0.12),
            highlightColor: Colors.white.withOpacity(0.08),
            onTap: onPressed,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
