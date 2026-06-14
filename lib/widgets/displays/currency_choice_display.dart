import 'package:flutter/material.dart';

import '../../models/currency_model/currency.dart';
import '../../utils/styles/theme.dart';

class CurrencyChoiceDisplay extends StatelessWidget {
  const CurrencyChoiceDisplay({
    Key? key,
    required this.currency,
    required this.currencies,
    required this.valueSymbol,
    required this.value,
    required this.label,
    required this.isActive,
    required this.onSelected,
  }) : super(key: key);

  final Currency currency;
  final List<Currency> currencies;
  final String valueSymbol;
  final String value;
  final String label;
  final bool isActive;
  final ValueChanged<Currency> onSelected;

  @override
  Widget build(BuildContext context) {
    final calcTheme = context.calcTheme;
    final valueColor = isActive ? calcTheme.accent : calcTheme.accent2;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: isActive
            ? Border(
                bottom: BorderSide(
                  color: calcTheme.accent,
                  width: calcTheme.borderThickness,
                ),
              )
            : null,
      ),
      child: Row(
        children: [
          PopupMenuButton<Currency>(
            color: calcTheme.background,
            tooltip: 'Wybierz walute',
            onSelected: onSelected,
            itemBuilder: (context) {
              return [
                for (final item in currencies)
                  PopupMenuItem<Currency>(
                    value: item,
                    child: Row(
                      spacing: 8.0,
                      children: [
                        CurrencyFlag(currency: item),
                        Text(
                          item.codeIso,
                          style: calcTheme.settingsCardTextStyle,
                        ),
                        // const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.countryName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: calcTheme.settingsCardValueTextStyle,
                          ),
                        ),
                      ],
                    ),
                  ),
              ];
            },
            child: _CurrencyChoice(
              currency: currency,
              label: label,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  valueSymbol,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: calcTheme.displayMidTextStyle.copyWith(
                    color: valueColor,
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: calcTheme.displayMidTextStyle.copyWith(
                      color: valueColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CurrencyFlag extends StatelessWidget {
  const CurrencyFlag({
    Key? key,
    required this.currency,
    this.width = 26,
    this.height = 16,
  }) : super(key: key);

  final Currency currency;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final calcTheme = context.calcTheme;

    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.only(right: 2.0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: calcTheme.unselected,
      ),
      child: Image.asset(
        'assets/data/${currency.flagImg}',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return ColoredBox(color: calcTheme.unselected);
        },
      ),
    );
  }
}

class _CurrencyChoice extends StatelessWidget {
  const _CurrencyChoice({
    Key? key,
    required this.currency,
    required this.label,
  }) : super(key: key);

  final Currency currency;
  final String label;

  @override
  Widget build(BuildContext context) {
    final calcTheme = context.calcTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CurrencyFlag(currency: currency),
            const SizedBox(width: 5),
            Text(
              currency.codeIso,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: calcTheme.numButtonNumberTextStyle.copyWith(
                color: calcTheme.text,
              ),
            ),
            const SizedBox(width: 5),
            Icon(
              Icons.arrow_drop_down,
              color: calcTheme.text,
              size: 24,
            ),
          ],
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: calcTheme.numButtonNumberTextStyle.copyWith(
            color: calcTheme.text,
            fontSize: 10.32,
          ),
        ),
      ],
    );
  }
}
