import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

extension I18nExtension on BuildContext {
  String tr(
    String key, {
    Map<String, String> args = const {},
    String? fallback,
  }) =>
      AppLocalizations.of(this).translate(key, args: args, fallback: fallback);
}
