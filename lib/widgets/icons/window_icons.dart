import 'package:flutter/material.dart';

import '../../utils/custom_icons/bixcalc_icons.dart';
import '../../utils/styles/theme.dart';

class WindowMinimizeIcon extends StatelessWidget {
  const WindowMinimizeIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final isMacOS = Theme.of(context).platform == TargetPlatform.macOS;
    return Icon(
      isMacOS ? BixCalcIcons.minimize_app_macos : BixCalcIcons.minimize_app,
      color: context.calcTheme.unselected,
    );
  }
}

class WindowMaximizeIcon extends StatelessWidget {
  const WindowMaximizeIcon({super.key, this.isExpanded = false});

  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    final icon = switch ((platform, isExpanded)) {
      (TargetPlatform.macOS, false) => BixCalcIcons.maximize_window_macos,
      (TargetPlatform.macOS, true) => BixCalcIcons.minimize_window_macos,
      (_, false) => BixCalcIcons.maximize_window_win,
      (_, true) => BixCalcIcons.minimize_window_win,
    };
    return Icon(icon, color: context.calcTheme.unselected);
  }
}

class WindowCloseIcon extends StatelessWidget {
  const WindowCloseIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final isMacOS = Theme.of(context).platform == TargetPlatform.macOS;
    return Icon(
      isMacOS ? BixCalcIcons.close_app_macos : BixCalcIcons.close_app_win,
      color: context.calcTheme.unselected,
    );
  }
}
