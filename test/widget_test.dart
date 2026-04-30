import 'package:flutter_test/flutter_test.dart';

import 'package:little_calc/main.dart';

void main() {
  testWidgets('loads calculator and switches pages from options bar',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byTooltip('kalkulator'), findsOneWidget);
    expect(find.text('Historia kalkulacji'), findsNothing);

    await tester.tap(find.byTooltip('historia'));
    await tester.pumpAndSettle();

    expect(find.text('Historia kalkulacji'), findsOneWidget);
  });
}
