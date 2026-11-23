import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/locale_provider.dart';
import '../../utils/internationalization/app_localizations.dart';
import '../../utils/internationalization/i18n_extension.dart';
import '../../utils/styles/dimensions/dimensions.dart';
import '../../utils/styles/theme.dart';
import '../../widgets/buttons/radio_btn.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  static const _languageNames = {
    'pl': 'Polski',
    'en': 'English',
    'es': 'Español',
  };

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LocaleProvider>();
    final theme = context.calcTheme;
    final selectedLanguage = provider.locale?.languageCode ?? '';
    final options = {
      '': context.tr('settings.system_language'),
      ..._languageNames,
    };

    return RadioGroup<String>(
      groupValue: selectedLanguage,
      onChanged: (code) {
        provider.setLocale(
          AppLocalizations.supportedLocales
              .where((locale) => locale.languageCode == code)
              .firstOrNull,
        );
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: theme.basePadding,
          vertical: theme.basePadding + AppDimens.mobileItemSpacing,
        ),
        child: Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: Column(
              spacing: AppDimens.mobileItemSpacing,
              children: [
                for (final option in options.entries)
                  DecoratedBox(
                    decoration: theme.settingsCardDecoration,
                    child: RadioBtn<String>(
                      value: option.key,
                      padding: EdgeInsets.all(theme.basePadding),
                      label: Text(
                        option.value,
                        style: theme.settingsCardTextStyle.copyWith(
                          color: option.key == selectedLanguage
                              ? theme.text
                              : theme.unselected,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
