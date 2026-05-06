import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/styles/colors.dart';
import '../buttons/window_action_button.dart';
import '../icons/window_icons.dart';

class WindowTitleBar extends StatelessWidget {
  const WindowTitleBar({Key? key}) : super(key: key);

  static const double height = 44;
  static const MethodChannel _windowChannel =
      MethodChannel('little_calc/window');

  Future<void> _invokeWindowAction(String action) async {
    try {
      await _windowChannel.invokeMethod<void>(action);
    } on MissingPluginException {
      // Allows the UI to render outside the Windows runner.
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanStart: (_) => _invokeWindowAction('drag'),
                onDoubleTap: () => _invokeWindowAction('toggleMaximize'),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'little_calc',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Exo',
                      fontSize: AppFontSizes.windowTitle,
                      fontWeight: FontWeight.w200,
                      height: 1,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            WindowActionButton(
              semanticLabel: 'Minimize',
              onPressed: () => _invokeWindowAction('minimize'),
              child: const WindowMinimizeIcon(),
            ),
            const SizedBox(width: 16),
            WindowActionButton(
              semanticLabel: 'Maximize',
              onPressed: () => _invokeWindowAction('toggleMaximize'),
              child: const WindowMaximizeIcon(),
            ),
            const SizedBox(width: 16),
            WindowActionButton(
              semanticLabel: 'Close',
              onPressed: () => _invokeWindowAction('close'),
              child: const WindowCloseIcon(),
            ),
          ],
        ),
      ),
    );
  }
}
