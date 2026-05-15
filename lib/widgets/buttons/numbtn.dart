import 'package:flutter/material.dart';

import '../../utils/calc_symbols/calc_symbols.dart';
import '../../utils/styles/dimensions/dimensions.dart';
import '../../utils/styles/theme.dart';

class NumBtn extends StatefulWidget {
  const NumBtn({
    Key? key,
    required this.label,
    required this.onPressed,
    this.flex = 1,
    this.type = CalcKeyType.number,
    this.isExpandedLayout = false,
  }) : super(key: key);

  final String label;
  final VoidCallback onPressed;
  final int flex;
  final CalcKeyType type;
  final bool isExpandedLayout;

  @override
  State<NumBtn> createState() => _NumBtnState();
}

class _NumBtnState extends State<NumBtn> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final calcTheme = context.calcTheme;

    return Expanded(
      flex: widget.flex,
      child: SizedBox(
        height: AppDimens.calculatorKeyHeight(
          isExpanded: widget.isExpandedLayout,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            splashColor: calcTheme.borderDark,
            highlightColor: calcTheme.borderDark,
            hoverColor: calcTheme.borderDark,
            onHighlightChanged: (isHighlighted) {
              setState(() => _isPressed = isHighlighted);
            },
            onTap: widget.onPressed,
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(
                horizontal: AppDimens.buttonHorizontalPadding(),
                vertical: AppDimens.buttonVerticalPadding(
                  isExpanded: widget.isExpandedLayout,
                ),
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: calcTheme.borderDark,
                  width: AppDimens.borderThickness,
                ),
              ),
              child: Text(
                widget.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: _textStyle(calcTheme),
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextStyle _textStyle(CalcTheme calcTheme) {
    if (_isPressed) {
      return calcTheme.numButtonPressedTextStyle;
    }

    switch (widget.type) {
      case CalcKeyType.function:
        return calcTheme.numButtonFunctionTextStyle;
      case CalcKeyType.operator:
        return calcTheme.numButtonOperatorTextStyle;
      case CalcKeyType.number:
        return calcTheme.numButtonNumberTextStyle;
    }
  }
}
