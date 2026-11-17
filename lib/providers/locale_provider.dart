import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/internationalization/app_localizations.dart';

class LocaleProvider extends ChangeNotifier {
  LocaleProvider(this._preferences) {
    final saved = _preferences.getString(_localeKey);
    for (final locale in AppLocalizations.supportedLocales) {
      if (locale.languageCode == saved) {
        _locale = locale;
        break;
      }
    }
  }

  static const _localeKey = 'settings.locale';
  final SharedPreferences _preferences;
  Locale? _locale;

  Locale? get locale => _locale;

  Future<void> setLocale(Locale? locale) async {
    if (locale == _locale) return;
    _locale = locale;
    notifyListeners();

    if (locale == null) {
      await _preferences.remove(_localeKey);
    } else {
      await _preferences.setString(_localeKey, locale.languageCode);
    }
  }
}
