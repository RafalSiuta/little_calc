import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  const AppLocalizations._(this._messages, this._englishMessages);

  static const supportedLocales = [Locale('en'), Locale('pl'), Locale('es')];
  static final _placeholder = RegExp(r'\{(\w+)\}');

  final Map<String, dynamic> _messages;
  final Map<String, dynamic> _englishMessages;

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  static Future<LocalizationsDelegate<AppLocalizations>> loadDelegate() async {
    final entries = await Future.wait(
      supportedLocales.map((locale) async {
        final code = locale.languageCode;
        final asset = await rootBundle.loadString('lang/$code.json');
        return MapEntry(code, jsonDecode(asset) as Map<String, dynamic>);
      }),
    );
    return _AppLocalizationsDelegate(Map.fromEntries(entries));
  }

  String translate(
    String key, {
    Map<String, String> args = const {},
    String? fallback,
  }) {
    final path = key.split('.');
    final message =
        _lookup(_messages, path) ??
        _lookup(_englishMessages, path) ??
        fallback ??
        key;
    if (args.isEmpty) return message;
    return message.replaceAllMapped(
      _placeholder,
      (match) => args[match[1]] ?? match[0]!,
    );
  }

  static String? _lookup(Map<String, dynamic> messages, List<String> path) {
    Object? value = messages;
    for (final part in path) {
      if (value is! Map<String, dynamic>) return null;
      value = value[part];
    }
    return value is String ? value : null;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate(this._catalogs);

  final Map<String, Map<String, dynamic>> _catalogs;

  @override
  bool isSupported(Locale locale) => _catalogs.containsKey(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) => SynchronousFuture(
    AppLocalizations._(_catalogs[locale.languageCode]!, _catalogs['en']!),
  );

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => old._catalogs != _catalogs;
}
