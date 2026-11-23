import 'package:flutter/material.dart';

import '../../utils/custom_icons/bixcalc_icons.dart';
import '../../utils/styles/dimensions/dimensions.dart';
import '../../utils/styles/theme.dart';

class RadioBtn<T> extends StatefulWidget {
  const RadioBtn({
    super.key,
    required this.value,
    this.label,
    this.padding = const EdgeInsets.all(12),
  });

  final T value;
  final Widget? label;
  final EdgeInsetsGeometry padding;

  @override
  State<RadioBtn<T>> createState() => _RadioBtnState<T>();
}

class _RadioBtnState<T> extends State<RadioBtn<T>> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final group = RadioGroup.maybeOf<T>(context);
    final theme = context.calcTheme;
    final label = widget.label;
    final enabled = group != null;

    return MergeSemantics(
      child: RawRadio<T>(
        value: widget.value,
        groupRegistry: group,
        enabled: enabled,
        toggleable: false,
        autofocus: false,
        focusNode: _focusNode,
        mouseCursor: WidgetStateMouseCursor.clickable,
        builder: (context, state) {
          final selected = state.value == true;
          final icon = SizedBox.square(
            dimension: AppDimens.baseIconSize,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Icon(
                selected
                    ? BixCalcIcons.radio_selected
                    : BixCalcIcons.radio_unselected,
                color: selected ? theme.accent : theme.unselected,
                size: AppDimens.currentBaseIconSize,
              ),
            ),
          );
          final highlighted =
              enabled &&
              (state.states.contains(WidgetState.focused) ||
                  state.states.contains(WidgetState.hovered));

          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(theme.cardBorderRadius),
              color: highlighted
                  ? theme.windowActionHoverColor
                  : Colors.transparent,
            ),
            child: Padding(
              padding: widget.padding,
              child: label == null
                  ? icon
                  : Row(
                      spacing: theme.paddingSmall,
                      children: [
                        Expanded(child: label),
                        icon,
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }
}
