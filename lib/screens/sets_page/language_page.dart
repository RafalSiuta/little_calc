import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/locale_provider.dart';
import '../../utils/internationalization/app_localizations.dart';
import '../../utils/internationalization/i18n_extension.dart';
import '../../utils/styles/theme.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  static const _languageNames = {
    'en': 'English',
    'pl': 'Polski',
    'es': 'Español',
  };

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LocaleProvider>();
    final theme = context.calcTheme;

    return RadioGroup<String>(
      groupValue: provider.locale?.languageCode ?? '',
      onChanged: (code) => provider.setLocale(
        code == null || code.isEmpty ? null : Locale(code),
      ),
      child: ListView(
        padding: EdgeInsets.all(theme.basePadding),
        children: [
          RadioListTile<String>(
            value: '',
            title: Text(context.tr('settings.system_language')),
          ),
          for (final locale in AppLocalizations.supportedLocales)
            RadioListTile<String>(
              value: locale.languageCode,
              title: Text(_languageNames[locale.languageCode]!),
            ),
        ],
      ),
    );
  }
}
