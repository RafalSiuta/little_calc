import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:bixcalc/utils/styles/theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'utils/calc_logic/calculator_logic.dart';
import 'providers/calculator_settings_provider.dart';
import 'providers/calculator_memory_provider.dart';
import 'providers/currencies_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_settings_provider.dart';
import 'providers/window_layout_provider.dart';
import 'screens/main_screen.dart';
import 'utils/internationalization/app_localizations.dart';
import 'utils/routes/custom_route.dart';

Future<int> getAndroidVersion() async {
  if (Platform.isAndroid) {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.version.sdkInt;
  }

  return 0;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final int androidVersion = await getAndroidVersion();

  if (Platform.isAndroid && androidVersion >= 35) {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: null,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  } else {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [],
    );
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
  final localizations = await AppLocalizations.loadDelegate();
  final preferences = await SharedPreferences.getInstance();
  runApp(MyApp(preferences: preferences, localizations: localizations));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.preferences,
    required this.localizations,
  });

  final SharedPreferences preferences;
  final LocalizationsDelegate<AppLocalizations> localizations;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider(preferences)),
        ChangeNotifierProvider(create: (_) => CalculatorMemoryProvider()),
        ChangeNotifierProvider(
          create: (context) => CalculatorSettingsProvider(),
        ),
        ChangeNotifierProxyProvider<
          CalculatorSettingsProvider,
          CalculatorLogic
        >(
          create: (context) => CalculatorLogic(),
          update: (context, settings, logic) {
            final calculatorLogic = logic ?? CalculatorLogic();
            calculatorLogic.updateSettings(settings);
            return calculatorLogic;
          },
        ),
        ChangeNotifierProvider(create: (context) => WindowLayoutProvider()),
        ChangeNotifierProvider(create: (context) => ThemeSettingsProvider()),
        ChangeNotifierProvider(create: (context) => CurrenciesProvider()),
      ],
      child: Consumer2<ThemeSettingsProvider, LocaleProvider>(
        builder: (context, themeSettings, localeProvider, child) {
          return MaterialApp(
            title: 'bixcalc',
            debugShowCheckedModeBanner: false,
            locale: localeProvider.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: [
              localizations,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            color: Colors.transparent,
            theme: CalcTheme.themeData(themeSettings.currentTheme),
            initialRoute: '/',
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/':
                  return CustomPageRoute(
                    child: const MainScreen(),
                    settings: settings,
                  );
                default:
                  return null;
              }
            },
          );
        },
      ),
    );
  }
}
