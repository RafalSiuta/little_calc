import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ThemeSettingsProvider extends ChangeNotifier {
  static const MethodChannel _windowChannel =
      MethodChannel('little_calc/window');

  double backgroundBlur = 0.5;
  double backgroundOpacity = 0.7;

  ThemeSettingsProvider() {
    _syncNativeBlur();
  }

  Future<void> setBackgroundBlur(double value) async {
    backgroundBlur = value;
    notifyListeners();
    await _syncNativeBlur();
  }

  Future<void> _syncNativeBlur() async {
    if (!Platform.isWindows) {
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
