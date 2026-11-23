import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/window_layout_provider.dart';
import '../../utils/internationalization/i18n_extension.dart';
import '../../utils/styles/theme.dart';
import '../buttons/window_action_button.dart';
import '../icons/window_icons.dart';

class WindowTitleBar extends StatelessWidget {
  const WindowTitleBar({Key? key}) : super(key: key);

  static const double height = 44;
  static const MethodChannel _windowChannel = MethodChannel('bixcalc/window');

  Future<void> _invokeWindowAction(String action) async {
    try {
      await _windowChannel.invokeMethod<void>(action);
    } on MissingPluginException {
      // Allows the UI to render outside the Windows runner.
    }
  }

  @override
  Widget build(BuildContext context) {
    final calcTheme = context.calcTheme;
    final isMacOS = Theme.of(context).platform == TargetPlatform.macOS;
    final windowLayout = context.watch<WindowLayoutProvider>();
    final isExpanded = windowLayout.isExpanded;

    final badge = Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: (_) => _invokeWindowAction('drag'),
        onDoubleTap: windowLayout.toggleCalculatorWidth,
        child: Padding(
          padding: EdgeInsets.only(left: isMacOS ? 0 : calcTheme.paddingSmall),
          child: Align(
            alignment: isMacOS ? Alignment.centerRight : Alignment.centerLeft,
            child: Image.asset(
              isMacOS
                  ? 'assets/images/badge_macos.png'
                  : 'assets/images/badge.png',
              width: 98,
              height: 24,
              fit: BoxFit.contain,
              semanticLabel: 'BIXCALC',
            ),
          ),
        ),
      ),
    );

    return SizedBox(
      height: !isMacOS && !isExpanded ? 48 : height,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: calcTheme.basePadding,
          vertical: 10,
        ),
        child: Row(
          spacing: calcTheme.itemSpacing,
          children: [
            if (!isMacOS) badge,
            WindowActionButton(
              semanticLabel: context.tr('actions.minimize'),
              onPressed: () => _invokeWindowAction('minimize'),
              child: const WindowMinimizeIcon(),
            ),
            WindowActionButton(
              semanticLabel: context.tr(
                isExpanded
                    ? 'actions.collapse_calculator'
                    : 'actions.expand_calculator',
              ),
              onPressed: windowLayout.toggleCalculatorWidth,
              child: WindowMaximizeIcon(isExpanded: isExpanded),
            ),
            WindowActionButton(
              semanticLabel: context.tr('actions.close'),
              onPressed: () => _invokeWindowAction('close'),
              child: const WindowCloseIcon(),
            ),
            if (isMacOS) badge,
          ],
        ),
      ),
    );
  }
}
