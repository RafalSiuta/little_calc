import 'package:flutter/foundation.dart';

import '../../models/currency_model/currency.dart';
import '../calc_logic/calculator_logic.dart';
import '../extensions/number_formatter.dart';

enum CurrencyActiveDisplay {
  base,
  target,
  equation,
}

class CurrencyLogic extends ChangeNotifier {
  CurrencyLogic({CalculatorLogic? calculator})
      : _calculator = calculator ?? CalculatorLogic() {
    _calculator.addListener(_handleCalculatorChange);
  }

  final CalculatorLogic _calculator;

  Currency? _baseCurrency;
  Currency? _targetCurrency;
  CurrencyActiveDisplay _activeDisplay = CurrencyActiveDisplay.base;
  String _baseInput = '0';
  String _targetInput = '0';

  CalculatorLogic get calculator => _calculator;
  CurrencyActiveDisplay get activeDisplay => _activeDisplay;

  String get equationDisplay => _calculator.equationDisplay;

  String get baseValueDisplay {
    if (_activeDisplay == CurrencyActiveDisplay.target) {
      return _formatDisplayNumber(_convertedTargetToBase);
    }

    return _baseInput;
  }

  String get targetValueDisplay {
    if (_activeDisplay == CurrencyActiveDisplay.target) {
      return _targetInput;
    }

    return _formatDisplayNumber(_convertedBaseToTarget);
  }

  String get resultDisplay {
    final calculatorDisplay = _calculator.display;
    if (calculatorDisplay == 'Infinity' || calculatorDisplay == '-Infinity') {
      return 'Error';
    }

    if (_activeDisplay == CurrencyActiveDisplay.equation ||
        _calculator.equationDisplay.isNotEmpty ||
        calculatorDisplay != '0') {
      return calculatorDisplay;
    }

    return _activeDisplay == CurrencyActiveDisplay.target
        ? baseValueDisplay
        : targetValueDisplay;
  }

  Currency? get resultCurrency {
    if (_activeDisplay == CurrencyActiveDisplay.target) {
      return _baseCurrency;
    }

    return _targetCurrency;
  }

  String baseLabel(Currency base, Currency target) {
    if (_activeDisplay == CurrencyActiveDisplay.target) {
      return 'to: ${base.valueName}';
    }

    return 'from: ${base.valueName}';
  }

  String targetLabel(Currency base, Currency target) {
    if (_activeDisplay == CurrencyActiveDisplay.target) {
      return 'from: ${target.valueName}';
    }

    return 'to: ${target.valueName}';
  }

  String rateDisplay(Currency base, Currency target) {
    final rate = conversionRate(base, target);
    return '1 ${base.symbol} = ${rate.toStringAsFixed(2)} ${target.symbol}';
  }

  void updateCurrencies({
    required Currency base,
    required Currency target,
  }) {
    final didChange = _baseCurrency?.symbol != base.symbol ||
        _targetCurrency?.symbol != target.symbol;

    _baseCurrency = base;
    _targetCurrency = target;

    if (didChange) {
      notifyListeners();
    }
  }

  void setActiveDisplay(CurrencyActiveDisplay display) {
    if (_activeDisplay == display) {
      return;
    }

    _activeDisplay = display;
    notifyListeners();
  }

  void toggleActiveDisplay({required bool next}) {
    const displays = CurrencyActiveDisplay.values;
    final currentIndex = displays.indexOf(_activeDisplay);
    final nextIndex = next
        ? (currentIndex + 1) % displays.length
        : (currentIndex - 1 + displays.length) % displays.length;

    setActiveDisplay(displays[nextIndex]);
  }

  void handleKeyPress(String value) {
    if (_activeDisplay == CurrencyActiveDisplay.equation) {
      _calculator.multifunction(value);
      return;
    }

    if (_isDigit(value)) {
      _appendDigit(value);
      notifyListeners();
      return;
    }

    if (value == '.') {
      _appendDecimalSeparator();
      notifyListeners();
      return;
    }

    if (_isCurrencyOperator(value)) {
      _commitConvertedValueToEquation(value);
      return;
    }

    if (value == 'C') {
      clear();
    }
  }

  void delete() {
    if (_activeDisplay == CurrencyActiveDisplay.equation) {
      _calculator.delete();
      return;
    }

    final current = _activeInput;
    _activeInput =
        current.length <= 1 ? '0' : current.substring(0, current.length - 1);
    notifyListeners();
  }

  void clear() {
    _baseInput = '0';
    _targetInput = '0';
    _calculator.clear();
    notifyListeners();
  }

  double conversionRate(Currency source, Currency destination) {
    final sourceRate = _ratePerUnitInPln(source);
    final destinationRate = _ratePerUnitInPln(destination);

    if (sourceRate == 0 || destinationRate == 0) {
      return 0;
    }

    return sourceRate / destinationRate;
  }

  @override
  void dispose() {
    _calculator
      ..removeListener(_handleCalculatorChange)
      ..dispose();
    super.dispose();
  }

  String get _activeInput {
    return _activeDisplay == CurrencyActiveDisplay.target
        ? _targetInput
        : _baseInput;
  }

  set _activeInput(String value) {
    if (_activeDisplay == CurrencyActiveDisplay.target) {
      _targetInput = value;
    } else {
      _baseInput = value;
    }
  }

  double get _convertedBaseToTarget {
    final base = _baseCurrency;
    final target = _targetCurrency;
    if (base == null || target == null) {
      return 0;
    }

    return _parseInput(_baseInput) * conversionRate(base, target);
  }

  double get _convertedTargetToBase {
    final base = _baseCurrency;
    final target = _targetCurrency;
    if (base == null || target == null) {
      return 0;
    }

    return _parseInput(_targetInput) * conversionRate(target, base);
  }

  void _appendDigit(String value) {
    final current = _activeInput;
    if (current == '0') {
      _activeInput = value;
      return;
    }

    _activeInput = '$current$value';
  }

  void _appendDecimalSeparator() {
    final current = _activeInput;
    if (current.contains('.')) {
      return;
    }

    _activeInput = '$current.';
  }

  void _commitConvertedValueToEquation(String operator) {
    final value = _activeDisplay == CurrencyActiveDisplay.target
        ? _convertedTargetToBase
        : _convertedBaseToTarget;

    _appendNumberToCalculator(value);

    if (operator == '=') {
      _calculator.onEqual();
    } else {
      _calculator.onOperator(operator);
      if (_calculator.display == '0') {
        _calculator.setText(value);
      }
    }

    _activeInput = '0';
    notifyListeners();
  }

  void _appendNumberToCalculator(double value) {
    final formatted = _formatCalculatorNumber(value);
    for (final char in formatted.split('')) {
      if (char == '-') {
        _calculator.onPlusMinus();
      } else if (char == '.') {
        _calculator.onDecimal('.');
      } else if (_isDigit(char)) {
        _calculator.onNumbers(char);
      }
    }
  }

  double _ratePerUnitInPln(Currency currency) {
    final latestRate = currency.currencyValues.isEmpty
        ? 0
        : currency.currencyValues.last.numericValue;

    if (currency.qty == 0) {
      return 0;
    }

    return latestRate / currency.qty;
  }

  double _parseInput(String value) {
    return double.tryParse(value) ?? 0;
  }

  String _formatDisplayNumber(double value) {
    return numberFormatter(value, decimalPlaces: 10);
  }

  String _formatCalculatorNumber(double value) {
    return numberFormatter(
      value,
      decimalPlaces: 10,
      useScientificNotation: false,
    );
  }

  bool _isDigit(String value) {
    return value.length == 1 && '0123456789'.contains(value);
  }

  bool _isCurrencyOperator(String value) {
    return value == '+' ||
        value == '-' ||
        value == '*' ||
        value == '/' ||
        value == '=';
  }

  void _handleCalculatorChange() {
    notifyListeners();
  }
}
