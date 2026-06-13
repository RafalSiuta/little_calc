import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_calc/utils/styles/theme.dart';
import 'package:little_calc/widgets/displays/equation_display.dart';

void main() {
  testWidgets('wraps, scales, and scrolls a long equation', (tester) async {
    const equation =
        '123456789+123456789+123456789+123456789+123456789+123456789';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 140,
              height: 48,
              child: EquationDisplay(
                equation: equation,
                onLongPress: _doNothing,
              ),
            ),
          ),
        ),
      ),
    );

    final context = tester.element(find.byType(EquationDisplay));
    final equationText = tester.widget<Text>(find.text(equation));
    final baseFontSize = context.calcTheme.displayMidTextStyle.fontSize!;
    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
    final scrollbar = tester.widget<Scrollbar>(find.byType(Scrollbar));

    expect(equationText.maxLines, isNull);
    expect(equationText.style!.fontSize, baseFontSize * 0.8);
    expect(scrollable.position.maxScrollExtent, greaterThan(0));
    expect(scrollbar.scrollbarOrientation, ScrollbarOrientation.left);
  });
}

void _doNothing() {}
