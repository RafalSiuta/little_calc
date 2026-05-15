import 'package:flutter/material.dart';

import '../../utils/styles/theme.dart';

enum SettingsCardAxis {
  vertical,
  horizontal,
}

class SettingsCard extends StatelessWidget {
  const SettingsCard({
    Key? key,
    required this.title,
    required this.value,
    required this.child,
    this.axis = SettingsCardAxis.vertical,
    this.valueIsAccent = false,
    this.valueColor,
    this.isExpanded = false,
  }) : super(key: key);

  final String title;
  final String value;
  final Widget child;
  final SettingsCardAxis axis;
  final bool valueIsAccent;
  final Color? valueColor;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final calcTheme = context.calcTheme;
    final isHorizontal = axis == SettingsCardAxis.horizontal;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: isExpanded ? 390 : double.infinity),
      padding: EdgeInsets.all(calcTheme.basePadding),
      decoration: calcTheme.settingsCardDecoration,
      child: Flex(
        direction: isHorizontal ? Axis.horizontal : Axis.vertical,
        crossAxisAlignment:
            isHorizontal ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isHorizontal)
            Expanded(
              child: _SettingsCardTitle(
                title: title,
                value: value,
                valueIsAccent: valueIsAccent,
                valueColor: valueColor,
              ),
            )
          else
            _SettingsCardTitle(
              title: title,
              value: value,
              valueIsAccent: valueIsAccent,
              valueColor: valueColor,
            ),
          SizedBox(
            width: isHorizontal ? 10 : 0,
            height: isHorizontal ? 0 : 10,
          ),
          SizedBox(
            width: isHorizontal ? null : double.infinity,
            height: 36,
            child: Align(
              alignment:
                  isHorizontal ? Alignment.centerRight : Alignment.centerLeft,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCardTitle extends StatelessWidget {
  const _SettingsCardTitle({
    Key? key,
    required this.title,
    required this.value,
    required this.valueIsAccent,
    required this.valueColor,
  }) : super(key: key);

  final String title;
  final String value;
  final bool valueIsAccent;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final calcTheme = context.calcTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: calcTheme.settingsCardTextStyle,
          ),
        ),
        SizedBox(width: calcTheme.paddingSmall),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: (valueIsAccent
                  ? calcTheme.settingsCardAccentValueTextStyle
                  : calcTheme.settingsCardValueTextStyle)
              .copyWith(color: valueColor),
        ),
      ],
    );
  }
}
