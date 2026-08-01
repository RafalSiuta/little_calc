import 'package:flutter/foundation.dart';

import '../calc_logic/calculator_logic.dart';
import '../extensions/number_formatter.dart';
import 'unit_definitions.dart';

enum UnitActiveDisplay { source, target, equation }

class UnitConverterLogic extends ChangeNotifier {
  UnitConverterLogic({UnitCategory category = UnitCategory.length, CalculatorLogic? calculator})
      : _category = category,
        _calculator = calculator ?? CalculatorLogic() {
    _calculator.addListener(_handleCalculatorChange);
    final units = availableUnits;
    _sourceUnit = units.first;
    _targetUnit = units[1];
  }

  final CalculatorLogic _calculator;
  UnitCategory _category;
  late UnitDefinition _sourceUnit;
  late UnitDefinition _targetUnit;
  UnitActiveDisplay _activeDisplay = UnitActiveDisplay.source;
  String _sourceInput = '1';
  String _targetInput = '1';
  bool _replaceActiveInput = true;
  String _completedEquation = '';
  bool _hasOpenEquation = false;
  String _lastResultValue = '1';
  String? _finalResultValue;

  UnitCategory get category => _category;
  List<UnitDefinition> get availableUnits => UnitDefinitions.byCategory[_category]!;
  UnitDefinition get sourceUnit => _sourceUnit;
  UnitDefinition get targetUnit => _targetUnit;
  UnitDefinition get selectedUnit => _activeDisplay == UnitActiveDisplay.target ? _targetUnit : _sourceUnit;
  UnitActiveDisplay get activeDisplay => _activeDisplay;
  String get sourceValue => _activeDisplay == UnitActiveDisplay.target ? _format(_convert(_targetInput, _targetUnit, _sourceUnit)) : _sourceInput;
  String get targetValue => _activeDisplay == UnitActiveDisplay.target ? _targetInput : _format(_convert(_sourceInput, _sourceUnit, _targetUnit));
  String get resultValue {
    if (_finalResultValue != null) return _finalResultValue!;
    if (_activeDisplay == UnitActiveDisplay.equation || _hasOpenEquation) {
      return _calculator.display == '0' ? _lastResultValue : _calculator.display;
    }
    return _activeDisplay == UnitActiveDisplay.target ? sourceValue : targetValue;
  }
  UnitDefinition get resultUnit => _activeDisplay == UnitActiveDisplay.target ? _sourceUnit : _targetUnit;
  String get equationDisplay {
    return _calculator.equationDisplay;
  }

  void setCategory(UnitCategory value) {
    if (value == _category) return;
    _category = value;
    final units = availableUnits;
    _sourceUnit = units.first;
    _targetUnit = units[1];
    _activeDisplay = UnitActiveDisplay.source;
    _sourceInput = '1';
    _targetInput = '1';
    _replaceActiveInput = true;
    _completedEquation = '';
    _hasOpenEquation = false;
    _lastResultValue = '1';
    _finalResultValue = null;
    _calculator.clear();
    notifyListeners();
  }

  void selectUnit(UnitDefinition value) {
    if (_activeDisplay == UnitActiveDisplay.target) _targetUnit = value;
    else _sourceUnit = value;
    notifyListeners();
  }

  void setSourceUnit(UnitDefinition value) { _sourceUnit = value; notifyListeners(); }
  void setTargetUnit(UnitDefinition value) { _targetUnit = value; notifyListeners(); }

  void swapUnits() {
    final visibleSource = sourceValue;
    final visibleTarget = targetValue;
    final unit = _sourceUnit; _sourceUnit = _targetUnit; _targetUnit = unit;
    if (_activeDisplay == UnitActiveDisplay.target) {
      _targetInput = visibleSource;
    } else {
      _sourceInput = visibleTarget;
    }
    _replaceActiveInput = true;
    _finalResultValue = null;
    notifyListeners();
  }

  void setActiveDisplay(UnitActiveDisplay value) {
    if (_activeDisplay == value || value == UnitActiveDisplay.equation) return;
    if (_activeDisplay == UnitActiveDisplay.source && value == UnitActiveDisplay.target) _targetInput = targetValue;
    if (_activeDisplay == UnitActiveDisplay.target && value == UnitActiveDisplay.source) _sourceInput = sourceValue;
    _activeDisplay = value;
    _replaceActiveInput = true;
    notifyListeners();
  }

  void toggleActiveDisplay({required bool next}) {
    if (_activeDisplay == UnitActiveDisplay.equation) { setActiveDisplay(next ? UnitActiveDisplay.source : UnitActiveDisplay.target); return; }
    setActiveDisplay(_activeDisplay == UnitActiveDisplay.source ? UnitActiveDisplay.target : UnitActiveDisplay.source);
  }

  void handleKeyPress(String value) {
    if (value == 'C') { clear(); return; }
    if (_activeDisplay == UnitActiveDisplay.equation) {
      if (value == '=') _finishEquation(); else _calculator.multifunction(value);
      return;
    }
    if (_isDigit(value)) _append(value);
    else if (value == '.') _appendDecimal();
    else if (_isOperator(value)) { _commitConvertedValueToEquation(value); return; }
    notifyListeners();
  }

  void delete() {
    if (_activeDisplay == UnitActiveDisplay.equation) { _calculator.delete(); return; }
    final value = _activeInput;
    _activeInput = _replaceActiveInput || value.length <= 1 ? '1' : value.substring(0, value.length - 1);
    _replaceActiveInput = false;
    notifyListeners();
  }

  void clear() { _sourceInput = '1'; _targetInput = '1'; _replaceActiveInput = true; _completedEquation = ''; _hasOpenEquation = false; _lastResultValue = '1'; _finalResultValue = null; _activeDisplay = UnitActiveDisplay.source; _calculator.clear(); notifyListeners(); }
  String rateDisplay() => '1 ${_sourceUnit.symbol} = ${_format(_convert('1', _sourceUnit, _targetUnit))} ${_targetUnit.symbol}';
  double convertedValueFor(UnitDefinition unit) => _convert(_activeInput, selectedUnit, unit);

  String get _activeInput => _activeDisplay == UnitActiveDisplay.target ? _targetInput : _sourceInput;
  set _activeInput(String value) { if (_activeDisplay == UnitActiveDisplay.target) _targetInput = value; else _sourceInput = value; }
  void _append(String value) { _finalResultValue = null; _activeInput = _replaceActiveInput ? value : '$_activeInput$value'; _replaceActiveInput = false; }
  void _appendDecimal() { _finalResultValue = null; _activeInput = _replaceActiveInput ? '0.' : (_activeInput.contains('.') ? _activeInput : '$_activeInput.'); _replaceActiveInput = false; }
  double _convert(String value, UnitDefinition from, UnitDefinition to) => to.convertFromBase(from.toBase(double.tryParse(value) ?? 0));
  String _format(double value) => numberFormatter(value, decimalPlaces: 10);
  bool _isDigit(String value) => value.length == 1 && '0123456789'.contains(value);
  bool _isOperator(String value) => const ['+', '-', '*', '/', '='].contains(value);
  void _commitConvertedValueToEquation(String operator) {
    final convertedValue = double.tryParse(
      _activeDisplay == UnitActiveDisplay.target ? sourceValue : targetValue,
    ) ?? 0;
    _lastResultValue = _format(convertedValue);

    if (operator == '=') {
      if (_hasOpenEquation) _calculator.onOperator('+');
      _appendNumberToCalculator(convertedValue);
      _finishEquation();
      return;
    } else {
      if (_hasOpenEquation) {
        _calculator.onOperator(operator);
        _appendNumberToCalculator(convertedValue);
      } else {
        _appendNumberToCalculator(convertedValue);
        _calculator.onOperator(operator);
        _hasOpenEquation = true;
      }
      _completedEquation = '';
    }
    _finalResultValue = null;
    _activeDisplay = UnitActiveDisplay.equation;
    notifyListeners();
  }
  void _finishEquation() {
    _calculator.onEqual();
    _finalResultValue = _calculator.display;
    _sourceInput = '1';
    _targetInput = '1';
    _replaceActiveInput = true;
    _completedEquation = '';
    _hasOpenEquation = false;
    _activeDisplay = UnitActiveDisplay.source;
    _calculator.clear();
    notifyListeners();
  }
  void _appendNumberToCalculator(double value) { for (final char in _format(value).split('')) { if (char == '-') _calculator.onPlusMinus(); else if (char == '.') _calculator.onDecimal('.'); else if (_isDigit(char)) _calculator.onNumbers(char); } }
  void _handleCalculatorChange() {
    if (_calculator.display != '0') _lastResultValue = _calculator.display;
    notifyListeners();
  }
  @override void dispose() { _calculator..removeListener(_handleCalculatorChange)..dispose(); super.dispose(); }
}
