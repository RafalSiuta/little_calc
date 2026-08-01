import 'package:flutter/material.dart';

import '../../utils/styles/theme.dart';

class EquationDisplay extends StatelessWidget {
  const EquationDisplay({
    Key? key,
    required this.equation,
    required this.onLongPress,
  }) : super(key: key);

  final String equation;
  final VoidCallback onLongPress;

  static const double _wrappedTextScale = 0.8;

  @override
  Widget build(BuildContext context) {
    final calcTheme = context.calcTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final baseStyle = calcTheme.displayMidTextStyle;
        final textPainter = TextPainter(
          text: TextSpan(text: equation, style: baseStyle),
          maxLines: 1,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: constraints.maxWidth);
        final isWrapped = textPainter.didExceedMaxLines;
        final fontSize = baseStyle.fontSize;
        final textStyle = isWrapped && fontSize != null
            ? baseStyle.copyWith(fontSize: fontSize * _wrappedTextScale)
            : baseStyle;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onLongPress: onLongPress,
          child: Scrollbar(
            scrollbarOrientation: ScrollbarOrientation.left,
            thumbVisibility: true,
            thickness: 3,
            radius: const Radius.circular(2),
            child: SingleChildScrollView(
              primary: true,
              reverse: true,
              padding: const EdgeInsets.only(left: 8),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      equation,
                      textAlign: TextAlign.right,
                      style: textStyle,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
