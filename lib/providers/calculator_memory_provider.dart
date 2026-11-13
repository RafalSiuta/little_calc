import 'package:flutter/foundation.dart';

class CalculatorMemoryProvider extends ChangeNotifier {
  double? _value;

  double? get value => _value;

  void clear() {
    if (_value == null) return;
    _value = null;
    notifyListeners();
  }

  void add(double? amount) {
    if (amount == null || !amount.isFinite) return;
    final next = (_value ?? 0) + amount;
    if (!next.isFinite) return;
    _value = next;
    notifyListeners();
  }

  void subtract(double? amount) {
    if (amount == null || !amount.isFinite) return;
    final next = (_value ?? 0) - amount;
    if (!next.isFinite) return;
    _value = next;
    notifyListeners();
  }

  bool handleKey(
    String key, {
    required double? currentValue,
    required void Function(double) onRecall,
  }) {
    switch (key) {
      case 'MC':
        clear();
        return true;
      case 'MR':
        if (_value != null) onRecall(_value!);
        return true;
      case 'M+':
        add(currentValue);
        return true;
      case 'M-':
        subtract(currentValue);
        return true;
      default:
        return false;
    }
  }
}
