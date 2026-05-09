import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ThemeSettingsProvider extends ChangeNotifier {
  static const MethodChannel _windowChannel =
      MethodChannel('little_calc/window');

  double backgroundBlur = 0.8;
  double backgroundOpacity = 0.5;

  ThemeSettingsProvider() {
    _syncNativeBlur();
  }

  Future<void> setBackgroundBlur(bool value) async {
    backgroundBlur = value == true ? 0.8 : 0;
    notifyListeners();
    await _syncNativeBlur();
  }

  Future<void> _syncNativeBlur() async {
    if (!Platform.isWindows && !Platform.isMacOS) {
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
