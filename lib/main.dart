import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'model/calculator_logic.dart';
import 'providers/calculator_settings_provider.dart';
import 'providers/theme_settings_provider.dart';
import 'providers/window_layout_provider.dart';
import 'screens/main_screen.dart';
import 'utils/routes/custom_route.dart';

void main() {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => CalculatorSettingsProvider(),
        ),
        ChangeNotifierProxyProvider<CalculatorSettingsProvider,
            CalculatorLogic>(
          create: (context) => CalculatorLogic(),
          update: (context, settings, logic) {
            final calculatorLogic = logic ?? CalculatorLogic();
            calculatorLogic.updateSettings(settings);
            return calculatorLogic;
          },
        ),
        ChangeNotifierProvider(
          create: (context) => WindowLayoutProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => ThemeSettingsProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'little calc',
        debugShowCheckedModeBanner: false,
        color: Colors.transparent,
        theme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: const ColorScheme.dark(
            surface: Colors.transparent,
          ),
          canvasColor: Colors.transparent,
          cardColor: Colors.transparent,
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.transparent,
        ),
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
      ),
    );
  }
}
