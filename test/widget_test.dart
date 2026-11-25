import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_animations/simple_animations.dart';

import 'package:bixcalc/main.dart';
import 'package:bixcalc/providers/currencies_provider.dart';
import 'package:bixcalc/providers/window_layout_provider.dart';
import 'package:bixcalc/screens/calc_page/calc_page.dart';
import 'package:bixcalc/screens/currency_page/currency_page.dart';
import 'package:bixcalc/screens/main_screen.dart';
import 'package:bixcalc/utils/calc_logic/calculator_logic.dart';
import 'package:bixcalc/utils/custom_icons/bixcalc_icons.dart';
import 'package:bixcalc/utils/internationalization/app_localizations.dart';
import 'package:bixcalc/utils/system/system_helper.dart';
import 'package:bixcalc/utils/unit_converter_logic/unit_definitions.dart';
import 'package:bixcalc/utils/unit_converter_logic/unit_converter_logic.dart';
import 'package:bixcalc/widgets/animations/calculation_completion.dart';
import 'package:bixcalc/widgets/animations/display_motion.dart';
import 'package:bixcalc/widgets/cards/currency_card.dart';
import 'package:bixcalc/widgets/displays/calculator_display.dart';
import 'package:bixcalc/widgets/displays/unit_converter_display.dart';
import 'package:bixcalc/widgets/keyboards/calculator_keyboard.dart';

void main() {
  testWidgets('equals fades the equation and scales the result independently', (
    tester,
  ) async {
    final app = await _prepareApp(tester);
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    final screen = tester.element(find.byType(MainScreen));
    await _loadCurrencies(tester, screen);
    final keyboard = find.byType(CalculatorKeyboard);
    Finder key(String label) =>
        find.descendant(of: keyboard, matching: find.text(label));
    final equationFade = find.descendant(
      of: find.byType(EquationAfterEquals),
      matching: find.byType(FadeTransition),
    );
    final resultScale = find.descendant(
      of: find.byType(ResultAfterEquals),
      matching: find.byType(ScaleTransition),
    );
    double scale() => tester.widget<ScaleTransition>(resultScale).scale.value;

    for (final page in ['kalkulator', 'jednostki', 'waluty']) {
      await tester.tap(find.byTooltip(page));
      await tester.pumpAndSettle();
      await tester.tap(key('2'));
      await tester.tap(key('+'));
      await tester.tap(key('3'));
      await tester.pumpAndSettle();
      expect(equationFade, findsOneWidget);
      expect(scale(), 1);

      await tester.tap(key('='));
      await tester.pump();
      expect(tester.widget<FadeTransition>(equationFade).opacity.value, 1);
      expect(scale(), closeTo(0.9, 0.001));
      await tester.pump(const Duration(milliseconds: 80));
      expect(
        tester.widget<FadeTransition>(equationFade).opacity.value,
        inExclusiveRange(0, 1),
      );
      expect(scale(), inExclusiveRange(0.9, 1));

      await tester.pumpAndSettle();
      expect(equationFade, findsNothing);
      expect(scale(), 1);
    }
  });

  testWidgets('locks the shared keypad and recalls into the settled page', (
    tester,
  ) async {
    final app = await _prepareApp(tester);
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    final screen = tester.element(find.byType(MainScreen));
    final calculator = screen.read<CalculatorLogic>();
    final units = screen.read<UnitConverterLogic>();
    final keyboard = find.byType(CalculatorKeyboard);
    Finder key(String label) =>
        find.descendant(of: keyboard, matching: find.text(label));

    await tester.tap(key('7'));
    await tester.tap(key('M+'));

    final keyboardElement = tester.element(keyboard);
    final keyboardPosition = tester.getTopLeft(keyboard);
    await tester.tap(find.byTooltip('jednostki'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 75));
    expect(tester.element(keyboard), same(keyboardElement));
    expect(tester.getTopLeft(keyboard), keyboardPosition);
    expect(key('MR').hitTestable(), findsNothing);
    await tester.tap(key('MR'), warnIfMissed: false);
    expect(units.sourceValue, '1');

    await tester.tap(find.byTooltip('historia'));
    await tester.tap(find.byTooltip('kalkulator'));
    await tester.pump(const Duration(milliseconds: 120));
    expect(key('MR').hitTestable(), findsNothing);
    await tester.pumpAndSettle();
    expect(find.byType(CalcPage), findsOneWidget);
    expect(calculator.memoryValue, 7);
    expect(units.sourceValue, '1');

    await tester.tap(find.byTooltip('jednostki'));
    await tester.pumpAndSettle();
    await tester.tap(key('MR'));
    expect(units.sourceValue, '7');
    await tester.tap(key('4'));
    expect(units.sourceValue, '4');
    expect(calculator.memoryValue, 7);

    await tester.tap(find.byTooltip('historia'));
    await tester.pumpAndSettle();
    expect(keyboard, findsNothing);
    await tester.tap(find.byTooltip('jednostki'));
    await tester.pumpAndSettle();
    expect(units.sourceValue, '4');
    expect(keyboard, findsOneWidget);
  });

  testWidgets('staggers converter displays and reveals an equation once', (
    tester,
  ) async {
    final app = await _prepareApp(tester);
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    double scaleOf(Finder display) => tester
        .widget<ScaleTransition>(
          find.ancestor(of: display, matching: find.byType(ScaleTransition)),
        )
        .scale
        .value;

    await tester.tap(find.byTooltip('jednostki'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));
    final unitDisplays = find.byType(UnitConverterDisplay);
    expect(
      scaleOf(unitDisplays.first),
      greaterThan(scaleOf(unitDisplays.last)),
    );
    expect(scaleOf(find.byType(CalculatorDisplay)), inExclusiveRange(0.8, 1));
    await tester.pumpAndSettle();
    expect(scaleOf(unitDisplays.first), 1);
    expect(scaleOf(unitDisplays.last), 1);

    final reveal = find.descendant(
      of: find.byType(EquationAppearance),
      matching: find.byType(PlayAnimationBuilder<double>),
    );
    expect(reveal, findsNothing);
    final keyboard = find.byType(CalculatorKeyboard);
    Finder key(String label) =>
        find.descendant(of: keyboard, matching: find.text(label));
    await tester.tap(key('+'));
    await tester.pumpAndSettle();
    final revealElement = tester.element(reveal);
    await tester.tap(key('3'));
    await tester.pump();
    expect(tester.element(reveal), same(revealElement));
  });

  testWidgets('routes currency recall and hides the keypad on other tabs', (
    tester,
  ) async {
    final app = await _prepareApp(tester);
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    final screen = tester.element(find.byType(MainScreen));
    final currencies = await _loadCurrencies(tester, screen);
    expect(currencies.currencies, isNotEmpty);

    final keyboard = find.byType(CalculatorKeyboard);
    Finder key(String label) =>
        find.descendant(of: keyboard, matching: find.text(label));

    await tester.tap(key('5'));
    await tester.tap(key('M+'));
    await tester.tap(find.byTooltip('waluty'));
    await tester.pumpAndSettle();
    await tester.tap(key('MR'));
    expect(currencies.currencyLogic.activeInputDisplay, '5');

    await tester.tap(find.text('surowce'));
    await tester.pumpAndSettle();
    expect(keyboard, findsNothing);

    final tabs = find.descendant(
      of: find.byType(CurrencyPage),
      matching: find.byType(TabBarView),
    );
    await tester.drag(tabs, const Offset(300, 0));
    await tester.pumpAndSettle();
    expect(keyboard, findsOneWidget);

    if (SystemHelper.isDesktopSystem) {
      const channel = MethodChannel('bixcalc/window');
      final messenger = tester.binding.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(channel, (_) async => null);
      addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
      tester.view.physicalSize = const Size(815, 864);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Pokaż listę walut'));
      await tester.pumpAndSettle();
      expect(screen.read<WindowLayoutProvider>().isExpanded, isTrue);
      expect(tester.getTopLeft(keyboard).dx, closeTo(815 / 2, 0.1));
      final list = find.ancestor(
        of: find.byType(CurrencyCard).first,
        matching: find.byType(ListView),
      );
      expect(
        tester.getBottomRight(list).dy,
        greaterThan(tester.getTopLeft(keyboard).dy),
      );
    }
  });

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
    final sourceDisplay = find.byType(UnitConverterDisplay).first;
    expect(
      find.descendant(of: sourceDisplay, matching: find.text('1')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: sourceDisplay, matching: find.text('ha')),
      findsOneWidget,
    );
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

  testWidgets('limits converter digits and shows the full unit symbol', (
    tester,
  ) async {
    final localizations = await tester.runAsync(AppLocalizations.loadDelegate);
    final units = UnitDefinitions.byCategory[UnitCategory.area]!;
    final unit = units.firstWhere((unit) => unit.id == 'square_kilometer');

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: [localizations!],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Center(
          child: SizedBox(
            width: 110,
            child: UnitConverterDisplay(
              unit: unit,
              units: units,
              value: '-1234567890.123456789e-12',
              isActive: true,
              onSelected: () {},
              onUnitSelected: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final display = find.byType(UnitConverterDisplay);
    final value = find.text('-1234567890.123…e-12');
    final symbol = find.text(unit.symbol);
    expect(value, findsOneWidget);
    expect(symbol, findsOneWidget);
    expect(
      tester.getTopLeft(value).dx,
      greaterThanOrEqualTo(tester.getTopLeft(display).dx),
    );
    expect(
      tester.getTopRight(symbol).dx,
      closeTo(tester.getTopRight(display).dx, 0.01),
    );
  });
}

Future<CurrenciesProvider> _loadCurrencies(
  WidgetTester tester,
  BuildContext context,
) async {
  final currencies = await tester.runAsync(() async {
    final provider = context.read<CurrenciesProvider>();
    await provider.loadCurrencies();
    return provider;
  });
  return currencies!;
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
