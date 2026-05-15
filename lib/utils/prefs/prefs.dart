import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static const String _isBlurKey = 'settings.isBlur';
  static const String _backgroundOpacityKey = 'settings.backgroundOpacity';
  static const String _themeKey = 'settings.theme';

  Future<bool?> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  Future<bool> setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setBool(key, value);
  }

  Future<double?> getDouble(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(key);
  }

  Future<bool> setDouble(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setDouble(key, value);
  }

  Future<int?> getInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  Future<bool> setInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setInt(key, value);
  }

  Future<bool?> getIsBlur() => getBool(_isBlurKey);

  Future<bool> setIsBlur(bool value) => setBool(_isBlurKey, value);

  Future<double?> getBackgroundOpacity() => getDouble(_backgroundOpacityKey);

  Future<bool> setBackgroundOpacity(double value) {
    return setDouble(_backgroundOpacityKey, value);
  }

  Future<int?> getTheme() => getInt(_themeKey);

  Future<bool> setTheme(int value) => setInt(_themeKey, value);
}
