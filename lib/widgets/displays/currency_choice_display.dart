import 'package:flutter/material.dart';

import '../../models/currency_model/currency.dart';
import '../../utils/styles/theme.dart';

class CurrencyChoiceDisplay extends StatefulWidget {
  const CurrencyChoiceDisplay({
    Key? key,
    required this.currency,
    required this.currencies,
    required this.valueSymbol,
    required this.value,
    required this.label,
    required this.isActive,
    required this.onSelected,
    required this.onActivated,
  }) : super(key: key);

  final Currency currency;
  final List<Currency> currencies;
  final String valueSymbol;
  final String value;
  final String label;
  final bool isActive;
  final ValueChanged<Currency> onSelected;
  final VoidCallback onActivated;

  @override
  State<CurrencyChoiceDisplay> createState() => _CurrencyChoiceDisplayState();
}

class _CurrencyChoiceDisplayState extends State<CurrencyChoiceDisplay> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.calcTheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onActivated,
        onHover: (hovered) => setState(() => _isHovered = hovered),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: theme.itemSpacing, vertical: 10),
          decoration: BoxDecoration(
            color: _isHovered ? theme.accentFill : Colors.transparent,
            borderRadius: widget.isActive
                    ? null
                    : BorderRadius.circular(theme.itemSpacing),
            border: widget.isActive
                ? Border(bottom: BorderSide(color: theme.accent, width: theme.borderThickness))
                : null,
          ),
          child: Row(
            children: [
              PopupMenuButton<Currency>(
                color: theme.background,
                tooltip: 'Wybierz walutę',
                onSelected: widget.onSelected,
                itemBuilder: (context) => [
                  for (final item in widget.currencies)
                    PopupMenuItem<Currency>(
                      value: item,
                      child: Row(
                        children: [
                          CurrencyFlag(currency: item),
                          const SizedBox(width: 8),
                          Text(item.codeIso, style: theme.settingsCardTextStyle),
                          Expanded(
                            child: Text(item.countryName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.settingsCardValueTextStyle),
                          ),
                        ],
                      ),
                    ),
                ],
                child: _CurrencyChoice(currency: widget.currency, label: widget.label),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(widget.value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: theme.displayMidTextStyle.copyWith(
                            color: widget.isActive ? theme.accent : theme.text,
                          )),
                    ),
                    const SizedBox(width: 10),
                    Text(widget.valueSymbol,
                        style: theme.displayMidTextStyle.copyWith(
                          color: widget.isActive ? theme.accent : theme.text,
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CurrencyFlag extends StatelessWidget {
  const CurrencyFlag({Key? key, required this.currency, this.width = 26, this.height = 16}) : super(key: key);
  final Currency currency;
  final double width;
  final double height;
  @override
  Widget build(BuildContext context) {
    final theme = context.calcTheme;
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.only(right: 2),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: theme.unselected),
      child: Image.asset('assets/data/${currency.flagImg}', fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => ColoredBox(color: theme.unselected)),
    );
  }
}

class _CurrencyChoice extends StatelessWidget {
  const _CurrencyChoice({required this.currency, required this.label});
  final Currency currency;
  final String label;
  @override
  Widget build(BuildContext context) {
    final theme = context.calcTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          CurrencyFlag(currency: currency),
          const SizedBox(width: 5),
          Text(currency.codeIso,
              style: theme.numButtonNumberTextStyle.copyWith(color: theme.text)),
          const SizedBox(width: 5),
          Icon(Icons.arrow_drop_down, color: theme.text, size: 24),
        ]),
        Text(label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.numButtonNumberTextStyle.copyWith(color: theme.text, fontSize: 10.32)),
      ],
    );
  }
}
