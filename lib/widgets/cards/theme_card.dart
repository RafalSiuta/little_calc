import 'package:flutter/material.dart';

import '../../utils/styles/theme.dart';

class ThemeCard extends StatelessWidget {
  const ThemeCard({
    Key? key,
    required this.themeId,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  final int themeId;
  final bool isSelected;
  final VoidCallback onTap;

  static const double figmaAspectRatio = 82 / 129;

  @override
  Widget build(BuildContext context) {
    final theme = CalcTheme.fromThemeId(themeId);

    return AspectRatio(
      aspectRatio: figmaAspectRatio,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(theme.cardBorderRadius),
          onTap: onTap,
          child: Container(
            clipBehavior: Clip.antiAlias,
            padding: EdgeInsets.all(theme.borderThickness),
            decoration: theme.settingsCardDecoration.copyWith(
              border: isSelected
                  ? Border.all(
                      color: theme.accent,
                      width: theme.borderThickness,
                    )
                  : null,
            ),
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: theme.paddingSmall,
                    ),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '3.1415',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.themeCardTextStyle,
                      ),
                    ),
                  ),
                ),
                for (final row in _rows)
                  Expanded(
                    child: Row(
                      children: [
                        for (final item in row)
                          Expanded(
                            child: _ThemeCardKey(
                              label: item.label,
                              color: _keyColor(theme, item.type),
                              borderColor: theme.borderDark,
                              borderWidth: theme.borderThickness,
                              textStyle: theme.themeCardButtonTextStyle,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Color _keyColor(CalcTheme theme, _ThemeKeyType type) {
    switch (type) {
      case _ThemeKeyType.function:
        return theme.functionsText;
      case _ThemeKeyType.operator:
        return theme.operatorsText;
      case _ThemeKeyType.number:
        return theme.numbersText;
      case _ThemeKeyType.text:
        return theme.text;
    }
  }
}

class _ThemeCardKey extends StatelessWidget {
  const _ThemeCardKey({
    Key? key,
    required this.label,
    required this.color,
    required this.borderColor,
    required this.borderWidth,
    required this.textStyle,
  }) : super(key: key);

  final String label;
  final Color color;
  final Color borderColor;
  final double borderWidth;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.clip,
        style: textStyle.copyWith(color: color),
      ),
    );
  }
}

enum _ThemeKeyType {
  function,
  operator,
  number,
  text,
}

class _ThemeKey {
  const _ThemeKey(this.label, this.type);

  final String label;
  final _ThemeKeyType type;
}

const List<List<_ThemeKey>> _rows = [
  [
    _ThemeKey('C', _ThemeKeyType.function),
    _ThemeKey('π', _ThemeKeyType.function),
    _ThemeKey('%', _ThemeKeyType.function),
    _ThemeKey('+', _ThemeKeyType.operator),
  ],
  [
    _ThemeKey('1', _ThemeKeyType.number),
    _ThemeKey('2', _ThemeKeyType.number),
    _ThemeKey('3', _ThemeKeyType.number),
    _ThemeKey('-', _ThemeKeyType.operator),
  ],
  [
    _ThemeKey('4', _ThemeKeyType.number),
    _ThemeKey('5', _ThemeKeyType.number),
    _ThemeKey('6', _ThemeKeyType.number),
    _ThemeKey('=', _ThemeKeyType.operator),
  ],
];
