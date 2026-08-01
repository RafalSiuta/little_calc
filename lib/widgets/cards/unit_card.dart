import 'package:flutter/material.dart';

import '../../utils/styles/theme.dart';
import '../../utils/unit_converter_logic/unit_definitions.dart';

class UnitCard extends StatefulWidget {
  const UnitCard({
    Key? key,
    required this.unit,
    required this.value,
    required this.isActive,
    this.onTap,
  }) : super(key: key);

  final UnitDefinition unit;
  final String value;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  State<UnitCard> createState() => _UnitCardState();
}

class _UnitCardState extends State<UnitCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.calcTheme;
    final showHover = _isHovered;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        onHover: (hovered) => setState(() => _isHovered = hovered),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        child: Container(
          height: 82,
          constraints: const BoxConstraints(maxWidth: 380),
          padding: EdgeInsets.symmetric(
            horizontal: theme.paddingSmall,
            vertical: theme.basePadding,
          ),
          decoration: BoxDecoration(
            color: showHover ? theme.accentFill : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: widget.isActive
                    ? theme.accent
                    : showHover
                        ? Colors.transparent
                        : theme.borderDark,
                width: theme.borderThickness,
              ),
            ),
            borderRadius: widget.isActive
                    ? null
                    : BorderRadius.circular(theme.itemSpacing),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.unit.symbol,
                        style: theme.numButtonNumberTextStyle
                            .copyWith(color: theme.text),
                      ),
                      if (widget.isActive) ...[
                        const SizedBox(width: 5),
                        Icon(Icons.arrow_drop_down, size: 24, color: theme.text),
                      ],
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.unit.name,
                    style: theme.numButtonNumberTextStyle
                        .copyWith(color: theme.text, fontSize: 10.32),
                  ),
                ],
              ),
              const Spacer(),
              Text(widget.value,
                  style: theme.numButtonNumberTextStyle.copyWith(
                    color: widget.isActive || showHover
                        ? theme.accent
                        : theme.numbersText,
                  )),
              const SizedBox(width: 5),
              Text(widget.unit.symbol,
                  style: theme.numButtonNumberTextStyle.copyWith(
                    color: widget.isActive || showHover
                        ? theme.accent
                        : theme.numbersText,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
