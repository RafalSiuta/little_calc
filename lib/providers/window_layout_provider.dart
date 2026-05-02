import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class WindowLayoutProvider extends ChangeNotifier {
  static const MethodChannel _windowChannel =
      MethodChannel('little_calc/window');
  static const int compactWindowWidth = 390;
  static const int expandedWindowWidth = 803;

  bool _isExpanded = false;

  bool get isExpanded => _isExpanded;

  Future<void> toggleCalculatorWidth() async {
    final nextIsExpanded = !_isExpanded;
    final nextWidth = nextIsExpanded ? expandedWindowWidth : compactWindowWidth;

    try {
      await _windowChannel.invokeMethod<void>(
        'setCalculatorWidth',
        {'width': nextWidth},
      );
      _setExpanded(nextIsExpanded);
    } on MissingPluginException {
      _setExpanded(nextIsExpanded);
    } on PlatformException {
      // Keep the current visual state if the native runner rejects the resize.
    }
  }

  void _setExpanded(bool value) {
    if (_isExpanded == value) {
      return;
    }

    _isExpanded = value;
    notifyListeners();
  }
}
