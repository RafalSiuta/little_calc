import 'package:flutter/material.dart';

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
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.calcTheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onSelected,
        onHover: (hovered) => setState(() => _isHovered = hovered),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: theme.itemSpacing,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: _isHovered ? theme.accentFill : Colors.transparent,
            borderRadius: widget.isActive
                    ? null
                    : BorderRadius.circular(theme.itemSpacing),
            border: widget.isActive
                ? Border(
                    bottom: BorderSide(
                      color: theme.accent,
                      width: theme.borderThickness,
                    ),
                  )
                : null,
          ),
          child: Row(
            children: [
              PopupMenuButton<UnitDefinition>(
                color: theme.background,
                tooltip: 'Wybierz jednostkę',
                onSelected: widget.onUnitSelected,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.unit.name,
                        style: theme.numButtonNumberTextStyle
                            .copyWith(color: theme.text)),
                    const SizedBox(width: 5),
                    const Icon(Icons.arrow_drop_down, size: 24),
                  ],
                ),
                itemBuilder: (context) => [
                  for (final item in widget.units)
                    PopupMenuItem<UnitDefinition>(
                      value: item,
                      child: Row(
                        children: [
                          Text(item.symbol, style: theme.settingsCardTextStyle),
                          const SizedBox(width: 8),
                          Text(item.name, style: theme.settingsCardValueTextStyle),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${widget.value} ${widget.unit.symbol}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: theme.displayMidTextStyle.copyWith(
                    color: widget.isActive ? theme.accent : theme.text,
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
