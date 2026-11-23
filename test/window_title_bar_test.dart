import 'package:bixcalc/providers/window_layout_provider.dart';
import 'package:bixcalc/utils/custom_icons/bixcalc_icons.dart';
import 'package:bixcalc/utils/internationalization/app_localizations.dart';
import 'package:bixcalc/utils/styles/theme.dart';
import 'package:bixcalc/widgets/window/window_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  for (final platform in [TargetPlatform.windows, TargetPlatform.macOS]) {
    testWidgets('uses the $platform badge and window controls', (tester) async {
      const channel = MethodChannel('bixcalc/window');
      final messenger = tester.binding.defaultBinaryMessenger;
      final calls = <MethodCall>[];
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        return null;
      });
      addTearDown(() => messenger.setMockMethodCallHandler(channel, null));

      final isMacOS = platform == TargetPlatform.macOS;
      final localizations = await tester.runAsync(
        AppLocalizations.loadDelegate,
      );
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => WindowLayoutProvider(),
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: [localizations!],
            supportedLocales: AppLocalizations.supportedLocales,
            theme: CalcTheme.themeData(1).copyWith(platform: platform),
            home: const Center(
              child: SizedBox(width: 390, child: WindowTitleBar()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final bar = find.byType(WindowTitleBar);
      final badge = find.byType(Image);
      final close = find.byIcon(
        isMacOS ? BixCalcIcons.close_app_macos : BixCalcIcons.close_app_win,
      );
      final minimize = find.byIcon(
        isMacOS ? BixCalcIcons.minimize_app_macos : BixCalcIcons.minimize_app,
      );
      final expand = find.byIcon(
        isMacOS
            ? BixCalcIcons.maximize_window_macos
            : BixCalcIcons.maximize_window_win,
      );
      final collapse = find.byIcon(
        isMacOS
            ? BixCalcIcons.minimize_window_macos
            : BixCalcIcons.minimize_window_win,
      );

      final badgeAsset = tester.widget<Image>(badge).image as AssetImage;
      expect(
        badgeAsset.assetName,
        isMacOS ? 'assets/images/badge_macos.png' : 'assets/images/badge.png',
      );
      expect(close, findsOneWidget);
      expect(tester.getSize(badge), const Size(98, 24));
      expect(tester.getSize(bar), Size(390, isMacOS ? 44 : 48));
      final left = tester.getTopLeft(bar).dx;
      expect(tester.getTopLeft(badge).dx - left, isMacOS ? 276 : 16);
      expect(tester.getTopLeft(minimize).dx - left, isMacOS ? 16 : 270);
      expect(tester.getTopLeft(expand).dx - left, isMacOS ? 56 : 310);
      expect(tester.getTopLeft(close).dx - left, isMacOS ? 96 : 350);

      await tester.tap(minimize);
      await tester.tap(expand);
      await tester.pumpAndSettle();
      expect(collapse, findsOneWidget);
      expect(tester.getSize(bar), const Size(390, 44));

      await tester.tap(collapse);
      await tester.pumpAndSettle();
      expect(expand, findsOneWidget);
      await tester.tap(close);
      expect(calls.map((call) => call.method), [
        'minimize',
        'setCalculatorWidth',
        'setCalculatorWidth',
        'close',
      ]);
      expect(calls[1].arguments, {'width': 815});
      expect(calls[2].arguments, {'width': 390});
      expect(tester.takeException(), isNull);
    });
  }
}
