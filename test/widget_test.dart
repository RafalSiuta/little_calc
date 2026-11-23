import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bixcalc/main.dart';
import 'package:bixcalc/utils/custom_icons/bixcalc_icons.dart';
import 'package:bixcalc/utils/internationalization/app_localizations.dart';

void main() {
  testWidgets('uses the system language and translates the unit converter', (
    tester,
  ) async {
    final app = await _prepareApp(tester);
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    expect(find.byTooltip('kalkulator'), findsOneWidget);

    await tester.tap(find.byTooltip('jednostki'));
    await tester.pumpAndSettle();

    expect(find.text('metr'), findsOneWidget);
    final areaTab = find.text('powierzchnia');
    await tester.ensureVisible(areaTab);
    await tester.pumpAndSettle();
    await tester.tap(areaTab);
    await tester.pumpAndSettle();
    expect(find.text('metr kwadratowy'), findsOneWidget);
    await tester.tap(find.byTooltip('Wybierz jednostkę').first);
    await tester.pumpAndSettle();
    expect(find.text('hektar'), findsOneWidget);
    await tester.tap(find.text('hektar'));
    await tester.pumpAndSettle();
    expect(find.text('1 ha'), findsOneWidget);
  });

  testWidgets('applies, restores and resets the selected language', (
    tester,
  ) async {
    final app = await _prepareApp(tester);
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('ustawienia'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('język'));
    await tester.pumpAndSettle();
    expect(find.byIcon(BixCalcIcons.radio_selected), findsOneWidget);
    expect(find.byIcon(BixCalcIcons.radio_unselected), findsNWidgets(3));
    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('calculadora'), findsOneWidget);
    expect(find.text('Sistema'), findsOneWidget);

    await app.preferences.reload();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    expect(find.byTooltip('calculadora'), findsOneWidget);
    await tester.tap(find.byTooltip('ajustes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('idioma'));
    await tester.pumpAndSettle();
    final spanishRadio = tester.widget<RawRadio<String>>(
      find.ancestor(
        of: find.text('Español'),
        matching: find.byType(RawRadio<String>),
      ),
    );
    expect(find.byIcon(BixCalcIcons.radio_selected), findsOneWidget);
    expect(spanishRadio.groupRegistry?.groupValue, 'es');
    spanishRadio.focusNode.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();

    expect(find.byTooltip('kalkulator'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);
    expect(app.preferences.getString('settings.locale'), isNull);
  });
}

Future<MyApp> _prepareApp(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 864);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final dispatcher = tester.binding.platformDispatcher;
  dispatcher.localesTestValue = const [Locale('pl', 'PL')];
  addTearDown(dispatcher.clearLocalesTestValue);
  SharedPreferences.setMockInitialValues({});

  final localizations = await tester.runAsync(AppLocalizations.loadDelegate);
  final preferences = await SharedPreferences.getInstance();
  return MyApp(preferences: preferences, localizations: localizations!);
}
