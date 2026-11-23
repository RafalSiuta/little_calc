import 'package:flutter/material.dart';

import '../../utils/internationalization/i18n_extension.dart';
import '../../utils/styles/dimensions/dimensions.dart';
import '../../utils/styles/theme.dart';
import '../../utils/unit_converter_logic/unit_definitions.dart';

class UnitConverterDisplay extends StatefulWidget {
  const UnitConverterDisplay({
    Key? key,
    required this.unit,
    required this.units,
    required this.value,
    required this.isActive,
    required this.onSelected,
    required this.onUnitSelected,
  }) : super(key: key);

  final UnitDefinition unit;
  final List<UnitDefinition> units;
  final String value;
  final bool isActive;
  final VoidCallback onSelected;
  final ValueChanged<UnitDefinition> onUnitSelected;

  @override
  State<UnitConverterDisplay> createState() => _UnitConverterDisplayState();
}

class _UnitConverterDisplayState extends State<UnitConverterDisplay> {
  static const _maxDigits = 15;
  static final _digit = RegExp(r'[0-9]');
  static final _exponentMarker = RegExp(r'[eE](?=[+-]?[0-9]{1,3}$)');

  bool _isHovered = false;

  String get _displayValue {
    final value = widget.value;
    final exponentStart = value.indexOf(_exponentMarker);
    final mantissa = exponentStart == -1
        ? value
        : value.substring(0, exponentStart);
    final exponent = exponentStart == -1 ? '' : value.substring(exponentStart);
    final digitLimit = _maxDigits - _digit.allMatches(exponent).length;
    final digits = _digit.allMatches(mantissa).take(digitLimit + 1).toList();
    if (digits.length <= digitLimit) {
      return value;
    }
    return '${mantissa.substring(0, digits[digitLimit - 1].end)}…$exponent';
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.calcTheme;
    final unitName = Text(
      context.tr('units.names.${widget.unit.id}'),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.displaySmallTextStyle.copyWith(color: theme.text),
    );
    final valueStyle = theme.numButtonNumberTextStyle.copyWith(
      color: widget.isActive ? theme.accent : theme.text,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onSelected,
        onHover: (hovered) => setState(() => _isHovered = hovered),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: AppDimens.mobileItemSpacing,
          ),
          decoration: BoxDecoration(
            color: _isHovered ? theme.accentFill : Colors.transparent,
            border: widget.isActive
                ? Border(
                    bottom: BorderSide(
                      color: theme.accent,
                      width: theme.borderThickness,
                    ),
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isActive)
                PopupMenuButton<UnitDefinition>(
                  color: theme.background,
                  tooltip: context.tr('actions.choose_unit'),
                  onSelected: widget.onUnitSelected,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(child: unitName),
                      Icon(
                        Icons.arrow_drop_down,
                        size: AppDimens.baseIconSize,
                        color: theme.text,
                      ),
                    ],
                  ),
                  itemBuilder: (context) => [
                    for (final item in widget.units)
                      PopupMenuItem<UnitDefinition>(
                        value: item,
                        child: Row(
                          children: [
                            Text(
                              item.symbol,
                              style: theme.settingsCardTextStyle,
                            ),
                            SizedBox(width: theme.paddingSmall),
                            Flexible(
                              child: Text(
                                context.tr('units.names.${item.id}'),
                                style: theme.settingsCardValueTextStyle,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                )
              else
                unitName,
              SizedBox(
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: AppDimens.mobileItemSpacing,
                    children: [
                      Text(_displayValue, style: valueStyle),
                      Text(widget.unit.symbol, style: valueStyle),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
