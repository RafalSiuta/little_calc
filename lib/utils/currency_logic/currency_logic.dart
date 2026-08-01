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
  String _baseInput = '1';
  String _targetInput = '1';
  bool _replaceActiveInput = false;
  String _completedEquation = '';
  bool _hasOpenEquation = false;
  String _lastResultValue = '1';
  String? _finalResultValue;

  CalculatorLogic get calculator => _calculator;
  CurrencyActiveDisplay get activeDisplay => _activeDisplay;
  Currency? get activeCurrency => _activeDisplay == CurrencyActiveDisplay.target ? _targetCurrency : _baseCurrency;
  String get activeInputDisplay => _activeInput;

  String get equationDisplay {
    return _calculator.equationDisplay;
  }

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
    if (_finalResultValue != null) return _finalResultValue!;
    final calculatorDisplay = _calculator.display;
    if (calculatorDisplay == 'Infinity' || calculatorDisplay == '-Infinity') {
      return 'Error';
    }

    if (_activeDisplay == CurrencyActiveDisplay.equation || _hasOpenEquation) {
      return calculatorDisplay == '0' ? _lastResultValue : calculatorDisplay;
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

  String rateDisplay(
    Currency base,
    Currency target, {
    int decimalPlaces = 4,
  }) {
    final rate = conversionRate(base, target);
    return '1 ${base.codeIso} = '
        '${rate.toStringAsFixed(decimalPlaces)} ${target.codeIso}';
  }

  void updateCurrencies({
    required Currency base,
    required Currency target,
  }) {
    final didChange = _baseCurrency?.codeIso != base.codeIso ||
        _targetCurrency?.codeIso != target.codeIso;

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
    if (display == CurrencyActiveDisplay.equation) return;
    if (_activeDisplay == CurrencyActiveDisplay.base && display == CurrencyActiveDisplay.target) _targetInput = targetValueDisplay;
    if (_activeDisplay == CurrencyActiveDisplay.target && display == CurrencyActiveDisplay.base) _baseInput = baseValueDisplay;
    _activeDisplay = display;
    _replaceActiveInput = true;
    notifyListeners();
  }

  void toggleActiveDisplay({required bool next}) {
    if (_activeDisplay == CurrencyActiveDisplay.equation) {
      setActiveDisplay(next ? CurrencyActiveDisplay.base : CurrencyActiveDisplay.target);
      return;
    }
    setActiveDisplay(_activeDisplay == CurrencyActiveDisplay.base ? CurrencyActiveDisplay.target : CurrencyActiveDisplay.base);
  }

  void handleKeyPress(String value) {
    if (value == 'C') {
      clear();
      return;
    }
    if (_activeDisplay == CurrencyActiveDisplay.equation) {
      if (value == '=') _finishEquation(); else _calculator.multifunction(value);
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

  }

  void delete() {
    if (_activeDisplay == CurrencyActiveDisplay.equation) {
      _calculator.delete();
      return;
    }

    final current = _activeInput;
    _activeInput = _replaceActiveInput || current.length <= 1 ? '1' : current.substring(0, current.length - 1);
    _replaceActiveInput = false;
    notifyListeners();
  }

  void clear() {
    _baseInput = '1';
    _targetInput = '1';
    _replaceActiveInput = true;
    _completedEquation = '';
    _hasOpenEquation = false;
    _lastResultValue = '1';
    _finalResultValue = null;
    _activeDisplay = CurrencyActiveDisplay.base;
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
    _finalResultValue = null;
    final current = _activeInput;
    if (_replaceActiveInput || current == '0') {
      _activeInput = value;
      _replaceActiveInput = false;
      return;
    }

    _activeInput = '$current$value';
  }

  void _appendDecimalSeparator() {
    _finalResultValue = null;
    final current = _activeInput;
    if (_replaceActiveInput) { _activeInput = '0.'; _replaceActiveInput = false; return; }
    if (current.contains('.')) {
      return;
    }

    _activeInput = '$current.';
  }

  void _commitConvertedValueToEquation(String operator) {
    final value = _activeDisplay == CurrencyActiveDisplay.target
        ? _convertedTargetToBase
        : _convertedBaseToTarget;

    if (operator == '=') {
      if (_hasOpenEquation) _calculator.onOperator('+');
      _appendNumberToCalculator(value);
      _finishEquation();
      return;
    } else {
      if (_hasOpenEquation) {
        _calculator.onOperator(operator);
        _appendNumberToCalculator(value);
      } else {
        _lastResultValue = _formatDisplayNumber(value);
        _appendNumberToCalculator(value);
        _calculator.onOperator(operator);
        _hasOpenEquation = true;
      }
      _completedEquation = '';
    }

    _finalResultValue = null;
    _activeDisplay = CurrencyActiveDisplay.equation;
    notifyListeners();
  }

  void _finishEquation() {
    _calculator.onEqual();
    _finalResultValue = _calculator.display;
    _baseInput = '1';
    _targetInput = '1';
    _replaceActiveInput = true;
    _completedEquation = '';
    _hasOpenEquation = false;
    _activeDisplay = CurrencyActiveDisplay.base;
    _calculator.clear();
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
    if (_calculator.display != '0') _lastResultValue = _calculator.display;
    notifyListeners();
  }
}
