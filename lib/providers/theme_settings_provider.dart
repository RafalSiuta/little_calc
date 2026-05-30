import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../utils/prefs/prefs.dart';
import '../utils/system/system_helper.dart';

class ThemeSettingsProvider extends ChangeNotifier {
  static const MethodChannel _windowChannel =
      MethodChannel('little_calc/window');

  final Prefs _prefs = Prefs();

  double backgroundBlur = SystemHelper.isMobileSystem ? 0 : 0.8;
  double backgroundOpacity = SystemHelper.isMobileSystem ? 1 : 0.7;

  List<int> themesList = [1, 2, 3];
  int currentTheme = 1; // themesList[1];

  ThemeSettingsProvider() {
    _loadSettings();
  }

  Future<void> setBackgroundBlur(bool value) async {
    if (SystemHelper.isMobileSystem) {
      backgroundBlur = 0;
      notifyListeners();
      await _prefs.setIsBlur(false);
      return;
    }

    backgroundBlur = value == true ? 0.8 : 0;
    notifyListeners();
    await _prefs.setIsBlur(value);
    await _syncNativeBlur();
  }

  Future<void> setBackgroundOpacity(double value) async {
    if (SystemHelper.isMobileSystem) {
      backgroundOpacity = 1;
      notifyListeners();
      await _prefs.setBackgroundOpacity(backgroundOpacity);
      return;
    }

    backgroundOpacity = value.clamp(0, 1).toDouble();
    notifyListeners();
    await _prefs.setBackgroundOpacity(backgroundOpacity);
  }

  Future<void> setCurrentTheme(int themeId) async {
    if (!themesList.contains(themeId) || currentTheme == themeId) {
      return;
    }

    currentTheme = themeId;
    notifyListeners();
    await _prefs.setTheme(currentTheme);
  }

  Future<void> _loadSettings() async {
    final isBlur = await _prefs.getIsBlur();
    final opacity = await _prefs.getBackgroundOpacity();
    final theme = await _prefs.getTheme();

    if (SystemHelper.isMobileSystem) {
      backgroundBlur = 0;
      backgroundOpacity = 1;
    } else {
      if (isBlur != null) {
        backgroundBlur = isBlur ? 0.8 : 0;
      }
      if (opacity != null) {
        backgroundOpacity = opacity.clamp(0, 1).toDouble();
      }
    }

    if (theme != null && themesList.contains(theme)) {
      currentTheme = theme;
    }

    notifyListeners();
    await _syncNativeBlur();
  }

  Future<void> _syncNativeBlur() async {
    if (!SystemHelper.isDesktopSystem) {
      return;
    }

    try {
      await _windowChannel.invokeMethod<void>('setNativeBlur', {
        'enabled': backgroundBlur > 0,
        'blur': backgroundBlur,
      });
    } on PlatformException {
      // The native window channel can be unavailable during early startup.
    } on MissingPluginException {
      // Non-Windows runners do not need to implement this method yet.
    }
  }
}
