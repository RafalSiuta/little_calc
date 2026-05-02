import 'package:flutter/foundation.dart';

class CalculatorSettingsProvider extends ChangeNotifier {
  static const int maxDecimalPlaces = 10;

  int _decimalPlaces = maxDecimalPlaces;
  bool _useScientificNotation = true;
  final double _scientificNotationLargeThreshold = 1e12;
  final double _scientificNotationSmallThreshold = 1e-9;

  int get decimalPlaces => _decimalPlaces;
  bool get useScientificNotation => _useScientificNotation;
  double get scientificNotationLargeThreshold =>
      _scientificNotationLargeThreshold;
  double get scientificNotationSmallThreshold =>
      _scientificNotationSmallThreshold;

  void updateDecimalPlaces(int value) {
    final nextValue = value.clamp(0, maxDecimalPlaces).toInt();
    if (_decimalPlaces == nextValue) {
      return;
    }

    _decimalPlaces = nextValue;
    notifyListeners();
  }

  void updateScientificNotation(bool value) {
    if (_useScientificNotation == value) {
      return;
    }

    _useScientificNotation = value;
    notifyListeners();
  }
}
