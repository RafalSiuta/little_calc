import 'dart:math';

import 'package:flutter/cupertino.dart';

import '../../providers/calculator_settings_provider.dart';
import '../extensions/number_formatter.dart';
import 'calc_flags.dart';

class CalculatorLogic extends ChangeNotifier {
  String newText = "";
  String oldText = "";
  var display = '0';
  var valueDisplay = '';
  var equationDisplay = '';
  var errorMessage = '';
  String operator = "";

  double oldValue = 0;
  double newValue = 0;
  double total = 0;

  final List<String> _tokens = [];
  String _currentNumber = '';
  int openBrackets = 0;
  int _decimalPlaces = CalculatorSettingsProvider.maxDecimalPlaces;
  bool _useScientificNotation = true;
  double _scientificNotationLargeThreshold = 1e12;
  double _scientificNotationSmallThreshold = 1e-9;
  bool _useRadians = false;
  String? _lastAngleFunctionKey;
  String? _lastAngleEquationName;
  double? _lastAngleSourceValue;
  int? _lastAngleTokenIndex;
  String? _lastAngleResultText;

  List numList = [
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "0",
  ];
  List operatorsList = [
    "*",
    "/",
    "-",
    "+",
  ];

  Flag flag = Flag.RESULT;

  bool get useRadians => _useRadians;
  String get angleModeButtonLabel => _useRadians ? 'Deg' : 'Rad';
  String get angleModeDisplay => _useRadians ? 'Rad' : 'Deg';

  // Applies display-formatting settings provided by app-level calculator
  // preferences and refreshes the visible result when those settings change.
  void updateSettings(CalculatorSettingsProvider settings) {
    final didChange = _decimalPlaces != settings.decimalPlaces ||
        _useScientificNotation != settings.useScientificNotation ||
        _scientificNotationLargeThreshold !=
            settings.scientificNotationLargeThreshold ||
        _scientificNotationSmallThreshold !=
            settings.scientificNotationSmallThreshold;

    _decimalPlaces = settings.decimalPlaces;
    _useScientificNotation = settings.useScientificNotation;
    _scientificNotationLargeThreshold =
        settings.scientificNotationLargeThreshold;
    _scientificNotationSmallThreshold =
        settings.scientificNotationSmallThreshold;

    if (!didChange) {
      return;
    }

    if (_tokens.isNotEmpty && _canEvaluateExpression()) {
      _updatePreviewOrDisplayNumber();
      notifyListeners();
      return;
    }

    final currentDisplayValue = double.tryParse(display);
    if (_tokens.isEmpty && flag == Flag.RESULT && currentDisplayValue != null) {
      display = _formatDisplayNumber(currentDisplayValue);
      notifyListeners();
    }
  }

  // Formats a numeric value for the main display using calculator settings.
  void setText(double value) {
    display = _formatDisplayNumber(value);
  }

  // Converts the current main display text into a number.
  double parser() {
    return double.parse(display);
  }

  // Keeps legacy operand fields aligned with the current token expression so
  // older UI and future refactors can still inspect the active calculator state.
  void checkFlag() {
    if (flag == Flag.RESULT || flag == Flag.FIRST_OPERAND) {
      oldValue = parser();
      total = oldValue;
      flag = Flag.FIRST_OPERAND;
    } else {
      newValue = _currentNumber.isEmpty ? 0 : double.parse(_currentNumber);
      total = _previewValue();
      flag = Flag.SECOND_OPERAND;
    }
  }

  // Preserves the old text-concatenation state used by earlier implementation
  // stages; token updates now handle the actual expression text.
  void setFlag() {
    oldText = _currentNumber;
  }

  // Calculates the current binary operation using the current expression
  // preview. Kept as a named method because callers still express this intent.
  double calculatePendingResult() {
    return _previewValue();
  }

  // Toggles the calculator angle mode between degrees and radians. The button
  // label shows the mode that will be selected next, while the info display
  // shows the currently active mode. If the current expression was produced by
  // a trigonometric function, its result is recalculated for the new mode.
  void onAngleModeToggle() {
    errorMessage = '';
    _useRadians = !_useRadians;
    valueDisplay = angleModeDisplay;
    _recalculateLastAngleFunctionForMode();
    notifyListeners();
  }

  // Replaces the active number token with sine of that value. The argument is
  // read in the currently selected angle mode: degrees or radians.
  void onSin() {
    _applyUnaryNumberFunction(
      equationName: 'sin',
      missingError: 'error - enter number before sin',
      transform: (value) => sin(_angleInputForTrig(value)),
      showAngleMode: true,
      angleFunctionKey: 'sin',
    );
  }

  // Replaces the active number token with cosine of that value. The argument is
  // read in the currently selected angle mode: degrees or radians.
  void onCos() {
    _applyUnaryNumberFunction(
      equationName: 'cos',
      missingError: 'error - enter number before cos',
      transform: (value) => cos(_angleInputForTrig(value)),
      showAngleMode: true,
      angleFunctionKey: 'cos',
    );
  }

  // Replaces the active number token with tangent of that value. The argument
  // is read in the currently selected angle mode: degrees or radians.
  void onTan() {
    _applyUnaryNumberFunction(
      equationName: 'tan',
      missingError: 'error - enter number before tan',
      transform: (value) => tan(_angleInputForTrig(value)),
      showAngleMode: true,
      angleFunctionKey: 'tan',
    );
  }

  // Replaces the active number token with arcsine of that value. The input must
  // be in the inclusive range from -1 to 1, and the result is shown in the
  // currently selected angle mode.
  void onAsin() {
    _applyUnaryNumberFunction(
      equationName: 'sin\u207b\u00b9',
      missingError: 'error - enter number before asin',
      validationError: 'error - asin requires value from -1 to 1',
      isValid: (value) => value >= -1 && value <= 1,
      transform: (value) => _angleOutputFromInverse(asin(value)),
      showAngleMode: true,
      angleFunctionKey: 'asin',
    );
  }

  // Replaces the active number token with arccosine of that value. The input
  // must be in the inclusive range from -1 to 1, and the result is shown in the
  // currently selected angle mode.
  void onAcos() {
    _applyUnaryNumberFunction(
      equationName: 'cos\u207b\u00b9',
      missingError: 'error - enter number before acos',
      validationError: 'error - acos requires value from -1 to 1',
      isValid: (value) => value >= -1 && value <= 1,
      transform: (value) => _angleOutputFromInverse(acos(value)),
      showAngleMode: true,
      angleFunctionKey: 'acos',
    );
  }

  // Replaces the active number token with arctangent of that value. The result
  // is shown in the currently selected angle mode.
  void onAtan() {
    _applyUnaryNumberFunction(
      equationName: 'tan\u207b\u00b9',
      missingError: 'error - enter number before atan',
      transform: (value) => _angleOutputFromInverse(atan(value)),
      showAngleMode: true,
      angleFunctionKey: 'atan',
    );
  }

  // Replaces the active number token with the hyperbolic sine of that value.
  void onSinh() {
    _applyUnaryNumberFunction(
      equationName: 'sinh',
      missingError: 'error - enter number before sinh',
      transform: _sinh,
    );
  }

  // Replaces the active number token with the hyperbolic cosine of that value.
  void onCosh() {
    _applyUnaryNumberFunction(
      equationName: 'cosh',
      missingError: 'error - enter number before cosh',
      transform: _cosh,
    );
  }

  // Replaces the active number token with the hyperbolic tangent of that value.
  void onTanh() {
    _applyUnaryNumberFunction(
      equationName: 'tanh',
      missingError: 'error - enter number before tanh',
      transform: _tanh,
    );
  }

  // Replaces the active number token with inverse hyperbolic sine of that
  // value.
  void onAsinh() {
    _applyUnaryNumberFunction(
      equationName: 'sinh\u207b\u00b9',
      missingError: 'error - enter number before asinh',
      transform: _asinh,
    );
  }

  // Replaces the active number token with inverse hyperbolic cosine of that
  // value. The input must be greater than or equal to 1.
  void onAcosh() {
    _applyUnaryNumberFunction(
      equationName: 'cosh\u207b\u00b9',
      missingError: 'error - enter number before acosh',
      validationError:
          'error - acosh requires value greater than or equal to 1',
      isValid: (value) => value >= 1,
      transform: _acosh,
    );
  }

  // Replaces the active number token with inverse hyperbolic tangent of that
  // value. The input must be greater than -1 and less than 1.
  void onAtanh() {
    _applyUnaryNumberFunction(
      equationName: 'tanh\u207b\u00b9',
      missingError: 'error - enter number before atanh',
      validationError: 'error - atanh requires value between -1 and 1',
      isValid: (value) => value > -1 && value < 1,
      transform: _atanh,
    );
  }

  // Evaluates a string expression using operator precedence and parentheses.
  double evaluateExpression(String expression) {
    final parser = _ExpressionParser(expression);
    return parser.parse();
  }

  // Adds a token to the expression and refreshes the visible equation text.
  void addToEquationDisplay(String value) {
    _tokens.add(value);
    _syncEquationDisplay();
  }

  // Clears transient labels without clearing the expression itself.
  void clearSmallDisplay() {
    valueDisplay = '';
    errorMessage = '';
    notifyListeners();
  }

  // Resets the calculator to the initial state.
  void clear() {
    newText = "";
    oldText = "";
    display = '0';
    valueDisplay = '';
    equationDisplay = '';
    errorMessage = '';
    operator = "";
    oldValue = 0;
    newValue = 0;
    total = 0;
    _tokens.clear();
    _currentNumber = '';
    openBrackets = 0;
    _clearAngleFunctionState();
    flag = Flag.RESULT;
    notifyListeners();
  }

  // Deletes the last typed character or token and recalculates the preview from
  // the remaining token list.
  void delete() {
    clearSmallDisplay();

    if (_tokens.isEmpty) {
      clear();
      return;
    }

    final last = _tokens.last;
    if (_isNumberToken(last) && last.length > 1) {
      _tokens[_tokens.length - 1] = last.substring(0, last.length - 1);
      _currentNumber = _tokens.last;
    } else {
      final removed = _tokens.removeLast();
      if (removed == '(') {
        openBrackets = max(0, openBrackets - 1);
      } else if (removed == ')') {
        openBrackets++;
      }
      _currentNumber = _lastTokenIsNumber() ? _tokens.last : '';
    }

    _syncEquationDisplay();
    _discardInvalidAngleFunctionState();
    _refreshStateAfterTokenChange();
    notifyListeners();
  }

  // Adds a decimal separator to the active number token.
  void onDecimal(String buttonText) {
    clearSmallDisplay();
    _prepareForNumericInput();

    if (_currentNumber.contains('.')) {
      return;
    }

    if (_currentNumber.isEmpty) {
      _appendNumberToken('0.');
    } else {
      _replaceLastNumberToken('$_currentNumber.');
    }

    _refreshStateAfterTokenChange();
    notifyListeners();
  }

  // Toggles the sign of the active number token or the visible result.
  void onPlusMinus() {
    clearSmallDisplay();

    if (_currentNumber.isNotEmpty) {
      final nextNumber = _currentNumber.startsWith('-')
          ? _currentNumber.substring(1)
          : '-$_currentNumber';
      _replaceLastNumberToken(nextNumber);
    } else {
      final value = -parser();
      _resetExpressionToNumber(value);
    }

    _refreshStateAfterTokenChange();
    notifyListeners();
  }

  // Adds a digit to the active number token and updates the live result
  // preview.
  void onNumbers(String buttonText) {
    clearSmallDisplay();
    _prepareForNumericInput();
    newText = buttonText;

    if (_lastTokenIsConstant() || _lastTokenIsCloseBracket()) {
      _appendOperatorToken("*");
    }

    if (_currentNumber == '0') {
      _replaceLastNumberToken(buttonText);
    } else if (_currentNumber == '-0') {
      if (buttonText != '0') {
        _replaceLastNumberToken('-$buttonText');
      }
    } else {
      _appendNumberToken(buttonText);
    }

    _refreshStateAfterTokenChange();
    notifyListeners();
  }

  // Adds or replaces a binary operator token.
  void onOperator(String operatorButton) {
    clearSmallDisplay();

    if (_tokens.isEmpty && display != '0') {
      _resetExpressionToNumber(parser());
    }

    if (_tokens.isEmpty) {
      return;
    }

    if (_lastTokenIsOperator()) {
      _tokens[_tokens.length - 1] = operatorButton;
    } else if (_tokens.last == '(') {
      if (operatorButton != '-') {
        return;
      }
      _tokens.add(operatorButton);
    } else {
      _appendOperatorToken(operatorButton);
    }

    operator = operatorButton;
    _currentNumber = '';
    flag = Flag.OPERATOR;
    _syncEquationDisplay();
    notifyListeners();
  }

  // Evaluates the current token expression, moves the result to the main
  // display, and clears the equation display for the next calculation.
  void onEqual() {
    clearSmallDisplay();

    if (!_canEvaluateExpression()) {
      notifyListeners();
      return;
    }

    try {
      final result = _evaluateTokens(completeOpenBrackets: true);
      oldValue = result;
      total = result;
      newValue = 0;
      setText(result);
      _tokens.clear();
      _currentNumber = '';
      equationDisplay = '';
      operator = "";
      openBrackets = 0;
      flag = Flag.RESULT;
    } catch (e) {
      display = "0";
    }

    notifyListeners();
  }

  // Applies percentage to the active number token and updates the expression
  // preview.
  void onPercent() {
    clearSmallDisplay();

    if (_currentNumber.isEmpty) {
      return;
    }

    final value = double.parse(_currentNumber) / 100;
    _replaceLastNumberToken(_formatTokenNumber(value));
    _refreshStateAfterTokenChange();
    notifyListeners();
  }

  // Squares the active number token, shows the exponent notation in the
  // equation display, and keeps the squared result ready for follow-up input.
  void onPow() {
    clearSmallDisplay();

    if (!_lastTokenIsNumber()) {
      display = '0';
      errorMessage = 'error - enter number before square';
      notifyListeners();
      return;
    }

    final value = double.parse(_tokens.last);
    final sourceText = _formatTokenNumber(value);
    final result = pow(value, 2).toDouble();
    final resultText = _formatTokenNumber(result);
    final equationPrefix =
        _tokens.take(_tokens.length - 1).map(_equationGlyph).join();

    _tokens[_tokens.length - 1] = resultText;
    _currentNumber = resultText;
    equationDisplay = '$equationPrefix$sourceText^(2)';
    final previewResult = _evaluateTokens(completeOpenBrackets: true);
    setText(previewResult);
    oldValue = previewResult;
    total = previewResult;
    flag = Flag.FIRST_OPERAND;
    notifyListeners();
  }

  // Cubes the active number token, writes the original value as `x^(3)` in
  // equationDisplay, and keeps the cubed numeric token available for the next
  // operator or equals press.
  void onCube() {
    clearSmallDisplay();

    if (!_lastTokenIsNumber()) {
      display = '0';
      errorMessage = 'error - enter number before cube';
      notifyListeners();
      return;
    }

    final value = double.parse(_tokens.last);
    final sourceText = _formatTokenNumber(value);
    final result = pow(value, 3).toDouble();
    final resultText = _formatTokenNumber(result);
    final equationPrefix =
        _tokens.take(_tokens.length - 1).map(_equationGlyph).join();

    _tokens[_tokens.length - 1] = resultText;
    _currentNumber = resultText;
    equationDisplay = '$equationPrefix$sourceText^(3)';
    final previewResult = _evaluateTokens(completeOpenBrackets: true);
    setText(previewResult);
    oldValue = previewResult;
    total = previewResult;
    flag = Flag.FIRST_OPERAND;
    notifyListeners();
  }

  // Starts a power expression from the current value. The active number,
  // constant, or closed bracket becomes the base, `^` is inserted as an
  // operator, and the next typed value becomes the exponent.
  void onPower() {
    clearSmallDisplay();

    if (_tokens.isEmpty && display != '0' && flag == Flag.RESULT) {
      _resetExpressionToNumber(parser());
    }

    if (!_lastTokenIsNumber() &&
        !_lastTokenIsConstant() &&
        !_lastTokenIsCloseBracket()) {
      display = '0';
      errorMessage = 'error - enter base before power';
      notifyListeners();
      return;
    }

    _appendOperatorToken('^');
    operator = '^';
    flag = Flag.OPERATOR;
    _syncEquationDisplay();
    notifyListeners();
  }

  // Replaces the active number token with its absolute value, updates the
  // equationDisplay with `|x|` notation, and keeps the absolute numeric result
  // available for follow-up operators.
  void onAbs() {
    clearSmallDisplay();

    if (!_lastTokenIsNumber()) {
      display = '0';
      errorMessage = 'error - enter number before absolute value';
      notifyListeners();
      return;
    }

    final value = double.parse(_tokens.last);
    final sourceText = _formatTokenNumber(value);
    final resultText = _formatTokenNumber(value.abs());
    final equationPrefix =
        _tokens.take(_tokens.length - 1).map(_equationGlyph).join();

    _tokens[_tokens.length - 1] = resultText;
    _currentNumber = resultText;
    equationDisplay = '$equationPrefix|$sourceText|';
    final previewResult = _evaluateTokens(completeOpenBrackets: true);
    setText(previewResult);
    oldValue = previewResult;
    total = previewResult;
    flag = Flag.FIRST_OPERAND;
    notifyListeners();
  }

  // Replaces the active non-negative integer token with its factorial. Decimal
  // and negative inputs are rejected because factorial is only supported for
  // whole numbers in the calculator UI.
  void onFactorial() {
    clearSmallDisplay();

    if (!_lastTokenIsNumber()) {
      display = '0';
      errorMessage = 'error - enter number before factorial';
      notifyListeners();
      return;
    }

    final value = double.parse(_tokens.last);
    if (value < 0 || value % 1 != 0) {
      display = '0';
      errorMessage = 'error - factorial requires whole number';
      notifyListeners();
      return;
    }

    final sourceText = _formatTokenNumber(value);
    final resultText = _formatTokenNumber(_factorial(value.toInt()));
    final equationPrefix =
        _tokens.take(_tokens.length - 1).map(_equationGlyph).join();

    _tokens[_tokens.length - 1] = resultText;
    _currentNumber = resultText;
    equationDisplay = '$equationPrefix$sourceText!';
    final previewResult = _evaluateTokens(completeOpenBrackets: true);
    setText(previewResult);
    oldValue = previewResult;
    total = previewResult;
    flag = Flag.FIRST_OPERAND;
    notifyListeners();
  }

  // Replaces the active positive number token with its natural logarithm.
  // Non-positive inputs are rejected because ln is defined only for values
  // greater than zero in this calculator.
  void onLn() {
    clearSmallDisplay();

    if (_tokens.isEmpty && display != '0' && flag == Flag.RESULT) {
      _resetExpressionToNumber(parser());
    }

    if (!_lastTokenIsNumber()) {
      display = '0';
      errorMessage = 'error - enter number before ln';
      notifyListeners();
      return;
    }

    final value = double.parse(_tokens.last);
    if (value <= 0) {
      display = '0';
      errorMessage = 'error - ln requires positive number';
      notifyListeners();
      return;
    }

    final sourceText = _formatTokenNumber(value);
    final resultText = _formatTokenNumber(log(value));
    final equationPrefix =
        _tokens.take(_tokens.length - 1).map(_equationGlyph).join();

    _tokens[_tokens.length - 1] = resultText;
    _currentNumber = resultText;
    equationDisplay = '${equationPrefix}ln($sourceText)';
    final previewResult = _evaluateTokens(completeOpenBrackets: true);
    setText(previewResult);
    oldValue = previewResult;
    total = previewResult;
    flag = Flag.FIRST_OPERAND;
    notifyListeners();
  }

  // Replaces the active positive number token with its base-10 logarithm.
  // Non-positive inputs are rejected because log10 is defined only for values
  // greater than zero in this calculator.
  void onLog() {
    clearSmallDisplay();

    if (_tokens.isEmpty && display != '0' && flag == Flag.RESULT) {
      _resetExpressionToNumber(parser());
    }

    if (!_lastTokenIsNumber()) {
      display = '0';
      errorMessage = 'error - enter number before log';
      notifyListeners();
      return;
    }

    final value = double.parse(_tokens.last);
    if (value <= 0) {
      display = '0';
      errorMessage = 'error - log requires positive number';
      notifyListeners();
      return;
    }

    final sourceText = _formatTokenNumber(value);
    final resultText = _formatTokenNumber(log(value) / ln10);
    final equationPrefix =
        _tokens.take(_tokens.length - 1).map(_equationGlyph).join();

    _tokens[_tokens.length - 1] = resultText;
    _currentNumber = resultText;
    equationDisplay = '${equationPrefix}log($sourceText)';
    final previewResult = _evaluateTokens(completeOpenBrackets: true);
    setText(previewResult);
    oldValue = previewResult;
    total = previewResult;
    flag = Flag.FIRST_OPERAND;
    notifyListeners();
  }

  // Replaces the active non-zero number token with its reciprocal value.
  // Zero is rejected to avoid division by zero.
  void onReciprocal() {
    clearSmallDisplay();

    if (_tokens.isEmpty && display != '0' && flag == Flag.RESULT) {
      _resetExpressionToNumber(parser());
    }

    if (!_lastTokenIsNumber()) {
      display = '0';
      errorMessage = 'error - enter number before reciprocal';
      notifyListeners();
      return;
    }

    final value = double.parse(_tokens.last);
    if (value == 0) {
      display = '0';
      errorMessage = 'error - reciprocal cannot divide by zero';
      notifyListeners();
      return;
    }

    final sourceText = _formatTokenNumber(value);
    final resultText = _formatTokenNumber(1 / value);
    final equationPrefix =
        _tokens.take(_tokens.length - 1).map(_equationGlyph).join();

    _tokens[_tokens.length - 1] = resultText;
    _currentNumber = resultText;
    equationDisplay = '${equationPrefix}1/($sourceText)';
    final previewResult = _evaluateTokens(completeOpenBrackets: true);
    setText(previewResult);
    oldValue = previewResult;
    total = previewResult;
    flag = Flag.FIRST_OPERAND;
    notifyListeners();
  }

  // Inserts a mathematical constant as a value token.
  void onConstant(String constant) {
    clearSmallDisplay();
    _prepareForNumericInput();

    final token = _constantToken(constant);
    if (token == null) {
      return;
    }

    if (_lastTokenIsNumber() ||
        _lastTokenIsConstant() ||
        _lastTokenIsCloseBracket()) {
      _appendOperatorToken('*');
    } else if (_tokens.isNotEmpty &&
        !_lastTokenIsOperator() &&
        _tokens.last != '(') {
      return;
    }

    _tokens.add(token);
    _currentNumber = '';
    _refreshStateAfterTokenChange();
    notifyListeners();
  }

  // Starts an exponential function. It renders as `e^(`, waits for the
  // exponent inside the bracket, and inserts multiplication automatically when
  // used after an existing value.
  void onExp() {
    clearSmallDisplay();

    if (_tokens.isEmpty && display != '0' && flag == Flag.RESULT) {
      _resetExpressionToNumber(parser());
    }

    if (_lastTokenIsNumber() ||
        _lastTokenIsConstant() ||
        _lastTokenIsCloseBracket()) {
      _appendOperatorToken('*');
    } else if (_tokens.isNotEmpty &&
        !_lastTokenIsOperator() &&
        _tokens.last != '(' &&
        !_isFunctionToken(_tokens.last)) {
      return;
    }

    _tokens
      ..add('exp')
      ..add('(');
    openBrackets++;
    _currentNumber = '';
    display = '0';
    flag = Flag.OPEN_BRACKET;
    _syncEquationDisplay();
    notifyListeners();
  }

  // Starts a square-root function. Without a preceding number it opens `sqrt(`
  // and waits for input; after a number it inserts multiplication before sqrt.
  void onSqrt() {
    clearSmallDisplay();

    if (_tokens.isEmpty && display != '0' && flag == Flag.RESULT) {
      _resetExpressionToNumber(parser());
    }

    if (_lastTokenIsNumber() ||
        _lastTokenIsConstant() ||
        _lastTokenIsCloseBracket()) {
      _appendOperatorToken('*');
    } else if (_tokens.isNotEmpty &&
        !_lastTokenIsOperator() &&
        _tokens.last != '(' &&
        !_isFunctionToken(_tokens.last)) {
      return;
    }

    _tokens
      ..add('sqrt')
      ..add('(');
    openBrackets++;
    _currentNumber = '';
    display = '0';
    flag = Flag.OPEN_BRACKET;
    _syncEquationDisplay();
    notifyListeners();
  }

  // Starts a cube-root function. It opens `cbrt(` when pressed first, inserts
  // multiplication when pressed after a value, and evaluates negative inputs as
  // real cube roots instead of rejecting them.
  void onCubeRoot() {
    clearSmallDisplay();

    if (_tokens.isEmpty && display != '0' && flag == Flag.RESULT) {
      _resetExpressionToNumber(parser());
    }

    if (_lastTokenIsNumber() ||
        _lastTokenIsConstant() ||
        _lastTokenIsCloseBracket()) {
      _appendOperatorToken('*');
    } else if (_tokens.isNotEmpty &&
        !_lastTokenIsOperator() &&
        _tokens.last != '(' &&
        !_isFunctionToken(_tokens.last)) {
      return;
    }

    _tokens
      ..add('cbrt')
      ..add('(');
    openBrackets++;
    _currentNumber = '';
    display = '0';
    flag = Flag.OPEN_BRACKET;
    _syncEquationDisplay();
    notifyListeners();
  }

  // Handles the shared bracket key, opening or closing a bracket based on the
  // current token context.
  void onBracket() {
    clearSmallDisplay();

    if (_shouldOpenBracket()) {
      if (_lastTokenIsNumber() ||
          _lastTokenIsConstant() ||
          _lastTokenIsCloseBracket()) {
        _appendOperatorToken("*");
      }
      _tokens.add('(');
      openBrackets++;
      _currentNumber = '';
      flag = Flag.OPEN_BRACKET;
    } else if (_canCloseBracket()) {
      _tokens.add(')');
      openBrackets--;
      _currentNumber = '';
      flag = Flag.CLOSE_BRACKET;
    }

    _refreshStateAfterTokenChange();
    notifyListeners();
  }

  // Routes a keyboard token to the matching calculator action.
  void multifunction(String char) {
    for (var num in numList) {
      if (num == char) {
        onNumbers(char);
      }
    }
    for (var oper in operatorsList) {
      if (oper == char) {
        onOperator(char);
      }
    }
    switch (char) {
      case '=':
        onEqual();
        break;
      case '+/-':
        onPlusMinus();
        break;
      case 'xÂ˛':
        onPow();
        break;
      case 'âš':
        onSqrt();
        break;
      case 'square':
        onPow();
        break;
      case 'x\u00b3':
      case 'cube':
        onCube();
        break;
      case 'y\u00b2':
      case 'power':
        onPower();
        break;
      case 'e\u02e3':
      case 'exp':
        onExp();
        break;
      case '|x|':
      case 'abs':
        onAbs();
        break;
      case 'x!':
      case 'factorial':
        onFactorial();
        break;
      case 'ln':
        onLn();
        break;
      case 'log':
        onLog();
        break;
      case '1/x':
        onReciprocal();
        break;
      case 'sin':
        onSin();
        break;
      case 'cos':
        onCos();
        break;
      case 'tan':
        onTan();
        break;
      case 'asin':
        onAsin();
        break;
      case 'acos':
        onAcos();
        break;
      case 'atan':
        onAtan();
        break;
      case 'sinh':
        onSinh();
        break;
      case 'cosh':
        onCosh();
        break;
      case 'tanh':
        onTanh();
        break;
      case 'asinh':
        onAsinh();
        break;
      case 'acosh':
        onAcosh();
        break;
      case 'atanh':
        onAtanh();
        break;
      case 'Rad':
      case 'Deg':
      case 'angleMode':
        onAngleModeToggle();
        break;
      case 'sqrt':
        onSqrt();
        break;
      case '\u00b3\u221a':
      case 'cbrt':
        onCubeRoot();
        break;
      case '.':
        onDecimal(char);
        break;
      case '%':
        onPercent();
        break;
      case '()':
        onBracket();
        break;
      case '\u03c0':
      case 'e':
        onConstant(char);
        break;
      case 'C':
        clear();
        break;
      case '&':
        delete();
        break;
    }
  }

  void _applyUnaryNumberFunction({
    required String equationName,
    required String missingError,
    required double Function(double value) transform,
    String? validationError,
    bool Function(double value)? isValid,
    bool showAngleMode = false,
    String? angleFunctionKey,
  }) {
    clearSmallDisplay();

    if (_tokens.isEmpty && display != '0' && flag == Flag.RESULT) {
      _resetExpressionToNumber(parser());
    }

    if (!_lastTokenIsNumber()) {
      display = '0';
      errorMessage = missingError;
      notifyListeners();
      return;
    }

    final value = double.parse(_tokens.last);
    if (isValid != null && !isValid(value)) {
      display = '0';
      errorMessage = validationError ?? missingError;
      notifyListeners();
      return;
    }

    final sourceText = _formatTokenNumber(value);
    final result = transform(value);
    if (result.isNaN || result.isInfinite) {
      display = '0';
      errorMessage = 'error - invalid function result';
      notifyListeners();
      return;
    }

    final resultText = _formatTokenNumber(result);
    final equationPrefix =
        _tokens.take(_tokens.length - 1).map(_equationGlyph).join();

    final tokenIndex = _tokens.length - 1;
    _tokens[tokenIndex] = resultText;
    _currentNumber = resultText;
    equationDisplay = '$equationPrefix$equationName($sourceText)';
    final previewResult = _evaluateTokens(completeOpenBrackets: true);
    setText(previewResult);
    oldValue = previewResult;
    total = previewResult;
    flag = Flag.FIRST_OPERAND;
    if (showAngleMode) {
      valueDisplay = angleModeDisplay;
      _lastAngleFunctionKey = angleFunctionKey;
      _lastAngleEquationName = equationName;
      _lastAngleSourceValue = value;
      _lastAngleTokenIndex = tokenIndex;
      _lastAngleResultText = resultText;
    } else {
      _clearAngleFunctionState();
    }
    notifyListeners();
  }

  // Prepares a fresh token expression when the user starts typing after a
  // completed result.
  void _prepareForNumericInput() {
    if (flag == Flag.RESULT && _tokens.isEmpty && display != '0') {
      display = '0';
      oldValue = 0;
      newValue = 0;
      total = 0;
    }
  }

  // Adds a digit or decimal text to the active number token.
  void _appendNumberToken(String text) {
    if (_currentNumber.isEmpty) {
      _currentNumber = text;
      _tokens.add(_currentNumber);
    } else {
      _currentNumber += text;
      _tokens[_tokens.length - 1] = _currentNumber;
    }
  }

  // Replaces the active number token.
  void _replaceLastNumberToken(String value) {
    _currentNumber = value;
    if (_lastTokenIsNumber()) {
      _tokens[_tokens.length - 1] = value;
    } else {
      _tokens.add(value);
    }
  }

  // Adds an operator token and resets active number input.
  void _appendOperatorToken(String value) {
    _tokens.add(value);
    _currentNumber = '';
  }

  // Replaces the whole expression with a single numeric token.
  void _resetExpressionToNumber(double value) {
    _tokens
      ..clear()
      ..add(_formatTokenNumber(value));
    _currentNumber = _tokens.last;
    openBrackets = 0;
    _syncEquationDisplay();
  }

  // Recalculates display, equation text, and flag state from current tokens.
  // A single typed operand is shown only in equationDisplay; the main display
  // stays at 0 until there is an expression worth previewing, for example a
  // binary operation with a second operand or a pending function expression.
  void _refreshStateAfterTokenChange() {
    _syncEquationDisplay();

    if (_tokens.isEmpty) {
      display = '0';
      flag = Flag.RESULT;
      return;
    }

    if (_lastTokenIsNumber() || _lastTokenIsConstant()) {
      flag = _hasOperatorToken() || openBrackets > 0
          ? Flag.SECOND_OPERAND
          : Flag.FIRST_OPERAND;
      _updatePreviewOrDisplayNumber();
      checkFlag();
      return;
    }

    if (_lastTokenIsCloseBracket()) {
      flag = Flag.CLOSE_BRACKET;
      _updatePreviewOrDisplayNumber();
      return;
    }

    if (_lastTokenIsOperator()) {
      operator = _tokens.last;
      flag = Flag.OPERATOR;
      return;
    }

    if (_tokens.last == '(') {
      flag = Flag.OPEN_BRACKET;
    }
  }

  // Shows either the complete expression preview or the currently typed number.
  void _updatePreviewOrDisplayNumber() {
    try {
      if (_shouldShowLiveResult()) {
        final result = _evaluateTokens(completeOpenBrackets: true);
        setText(result);
        total = result;
      } else {
        display = '0';
      }
    } catch (e) {
      display = _currentNumber.isNotEmpty ? _currentNumber : '0';
    }
  }

  // Updates equationDisplay from tokens using UI glyphs for operators.
  void _syncEquationDisplay() {
    equationDisplay = _tokens.map(_equationGlyph).join();
  }

  // Converts internal tokens to visible equation glyphs.
  String _equationGlyph(String value) {
    switch (value) {
      case '/':
        return '\u00f7';
      case '*':
        return '\u00d7';
      case 'sqrt':
        return '\u221a';
      case 'cbrt':
        return '\u00b3\u221a';
      case 'exp':
        return 'e^';
      case 'pi':
        return '\u03c0';
      case 'e':
        return 'e';
      default:
        return value;
    }
  }

  // Returns true when the expression currently has a calculable ending.
  bool _canEvaluateExpression() {
    if (_tokens.isEmpty) {
      return false;
    }
    return _lastTokenIsNumber() ||
        _lastTokenIsConstant() ||
        _lastTokenIsCloseBracket();
  }

  // Evaluates tokens as an expression, optionally closing open brackets for
  // live preview.
  double _evaluateTokens({required bool completeOpenBrackets}) {
    final expressionTokens = List<String>.from(_tokens);
    if (completeOpenBrackets) {
      expressionTokens.addAll(List.filled(openBrackets, ')'));
    }
    return evaluateExpression(expressionTokens.join());
  }

  // Returns a display preview value without mutating token state.
  double _previewValue() {
    if (_canEvaluateExpression()) {
      return _evaluateTokens(completeOpenBrackets: true);
    }
    return parser();
  }

  // Decides whether the shared bracket key should open a bracket.
  bool _shouldOpenBracket() {
    if (_tokens.isEmpty) {
      return true;
    }
    if (_lastTokenIsOperator() || _tokens.last == '(') {
      return true;
    }
    if (_lastTokenIsNumber() ||
        _lastTokenIsConstant() ||
        _lastTokenIsCloseBracket()) {
      return openBrackets == 0;
    }
    return false;
  }

  // Decides whether the shared bracket key can close an existing bracket.
  bool _canCloseBracket() {
    return openBrackets > 0 &&
        (_lastTokenIsNumber() ||
            _lastTokenIsConstant() ||
            _lastTokenIsCloseBracket());
  }

  // Returns true when any binary operator is present in tokens.
  bool _hasOperatorToken() {
    return _tokens.any(_isOperatorToken);
  }

  bool _hasFunctionToken() {
    return _tokens.any(_isFunctionToken);
  }

  bool _shouldShowLiveResult() {
    return _canEvaluateExpression() &&
        (_hasOperatorToken() ||
            _hasFunctionToken() ||
            (_tokens.length == 1 && _lastTokenIsConstant()));
  }

  // Returns true when the last token is a number.
  bool _lastTokenIsNumber() {
    return _tokens.isNotEmpty && _isNumberToken(_tokens.last);
  }

  // Returns true when the last token is a mathematical constant.
  bool _lastTokenIsConstant() {
    return _tokens.isNotEmpty && _isConstantToken(_tokens.last);
  }

  // Returns true when the last token is a closing bracket.
  bool _lastTokenIsCloseBracket() {
    return _tokens.isNotEmpty && _tokens.last == ')';
  }

  // Returns true when the last token is a binary operator.
  bool _lastTokenIsOperator() {
    return _tokens.isNotEmpty && _isOperatorToken(_tokens.last);
  }

  // Returns true when a token is one of the supported binary operators.
  bool _isOperatorToken(String value) {
    return value == '+' ||
        value == '-' ||
        value == '*' ||
        value == '/' ||
        value == '^';
  }

  // Returns true when a token starts a function that consumes the next factor.
  bool _isFunctionToken(String value) {
    return value == 'sqrt' || value == 'cbrt' || value == 'exp';
  }

  // Returns true when a token can be parsed as a number.
  bool _isNumberToken(String value) {
    return double.tryParse(value) != null;
  }

  // Returns true when a token is one of the supported mathematical constants.
  bool _isConstantToken(String value) {
    return value == 'pi' || value == 'e';
  }

  // Converts a button label into the matching constant token.
  String? _constantToken(String value) {
    switch (value) {
      case '\u03c0':
        return 'pi';
      case 'e':
        return 'e';
      default:
        return null;
    }
  }

  // Formats a number for storing inside the token list.
  String _formatTokenNumber(double value) {
    return _formatDisplayNumber(value);
  }

  double _angleInputForTrig(double value) {
    return _useRadians ? value : value * pi / 180;
  }

  double _angleOutputFromInverse(double value) {
    return _useRadians ? value : value * 180 / pi;
  }

  double _computeAngleFunction(String key, double value) {
    switch (key) {
      case 'sin':
        return sin(_angleInputForTrig(value));
      case 'cos':
        return cos(_angleInputForTrig(value));
      case 'tan':
        return tan(_angleInputForTrig(value));
      case 'asin':
        return _angleOutputFromInverse(asin(value));
      case 'acos':
        return _angleOutputFromInverse(acos(value));
      case 'atan':
        return _angleOutputFromInverse(atan(value));
      default:
        throw ArgumentError.value(key, 'key', 'Unsupported angle function.');
    }
  }

  void _recalculateLastAngleFunctionForMode() {
    final key = _lastAngleFunctionKey;
    final equationName = _lastAngleEquationName;
    final sourceValue = _lastAngleSourceValue;
    final tokenIndex = _lastAngleTokenIndex;
    if (key == null ||
        equationName == null ||
        sourceValue == null ||
        tokenIndex == null ||
        tokenIndex >= _tokens.length ||
        _tokens[tokenIndex] != _lastAngleResultText) {
      _clearAngleFunctionState();
      return;
    }

    final result = _computeAngleFunction(key, sourceValue);
    if (result.isNaN || result.isInfinite) {
      display = '0';
      errorMessage = 'error - invalid function result';
      return;
    }

    final resultText = _formatTokenNumber(result);
    _tokens[tokenIndex] = resultText;
    _lastAngleResultText = resultText;
    if (tokenIndex == _tokens.length - 1) {
      _currentNumber = resultText;
    }

    final sourceText = _formatTokenNumber(sourceValue);
    if (_tokens.length == 1) {
      equationDisplay = '$equationName($sourceText)';
      setText(result);
      total = result;
      oldValue = result;
      return;
    }

    _syncEquationDisplay();
    if (_shouldShowLiveResult()) {
      final previewResult = _evaluateTokens(completeOpenBrackets: true);
      setText(previewResult);
      total = previewResult;
    }
  }

  void _discardInvalidAngleFunctionState() {
    final tokenIndex = _lastAngleTokenIndex;
    if (tokenIndex == null) {
      return;
    }
    if (tokenIndex >= _tokens.length ||
        _tokens[tokenIndex] != _lastAngleResultText) {
      _clearAngleFunctionState();
    }
  }

  void _clearAngleFunctionState() {
    _lastAngleFunctionKey = null;
    _lastAngleEquationName = null;
    _lastAngleSourceValue = null;
    _lastAngleTokenIndex = null;
    _lastAngleResultText = null;
  }

  double _sinh(double value) {
    return (exp(value) - exp(-value)) / 2;
  }

  double _cosh(double value) {
    return (exp(value) + exp(-value)) / 2;
  }

  double _tanh(double value) {
    return _sinh(value) / _cosh(value);
  }

  double _asinh(double value) {
    return log(value + sqrt((value * value) + 1));
  }

  double _acosh(double value) {
    return log(value + sqrt(value - 1) * sqrt(value + 1));
  }

  double _atanh(double value) {
    return 0.5 * log((1 + value) / (1 - value));
  }

  // Formats a numeric value for display or calculated tokens using the current
  // precision and scientific-notation settings.
  String _formatDisplayNumber(double value) {
    return numberFormatter(
      value,
      decimalPlaces: _decimalPlaces,
      useScientificNotation: _useScientificNotation,
      scientificNotationLargeThreshold: _scientificNotationLargeThreshold,
      scientificNotationSmallThreshold: _scientificNotationSmallThreshold,
    );
  }

  // Calculates n! as a double so it can reuse the existing display formatter.
  double _factorial(int value) {
    var result = 1.0;
    for (var i = 2; i <= value; i++) {
      result *= i;
    }
    return result;
  }
}

class _ExpressionParser {
  _ExpressionParser(String expression)
      : _expression = expression
            .replaceAll('\u00d7', '*')
            .replaceAll('\u00f7', '/')
            .replaceAll(' ', '');

  final String _expression;
  int _position = 0;

  // Parses the full expression and rejects trailing unsupported characters.
  double parse() {
    final value = _parseExpression();
    if (_position != _expression.length) {
      throw const FormatException('Unexpected expression token.');
    }
    return value;
  }

  // Parses addition and subtraction, delegating higher-priority operations to
  // term parsing.
  double _parseExpression() {
    var value = _parseTerm();
    while (_position < _expression.length) {
      final operator = _expression[_position];
      if (operator != '+' && operator != '-') {
        break;
      }
      _position++;
      final nextValue = _parseTerm();
      value = operator == '+' ? value + nextValue : value - nextValue;
    }
    return value;
  }

  // Parses multiplication and division before returning control to expression
  // parsing.
  double _parseTerm() {
    var value = _parsePower();
    while (_position < _expression.length) {
      final operator = _expression[_position];
      if (operator != '*' && operator != '/') {
        break;
      }
      _position++;
      final nextValue = _parsePower();
      value = operator == '*' ? value * nextValue : value / nextValue;
    }
    return value;
  }

  // Parses exponentiation with right associativity, so `2^3^2` is read as
  // `2^(3^2)`.
  double _parsePower() {
    final value = _parseFactor();
    if (_position < _expression.length && _expression[_position] == '^') {
      _position++;
      return pow(value, _parsePower()).toDouble();
    }
    return value;
  }

  // Parses signs, parentheses, root functions, constants, and raw number
  // factors.
  double _parseFactor() {
    if (_position >= _expression.length) {
      throw const FormatException('Expected expression factor.');
    }

    final char = _expression[_position];
    if (char == '+') {
      _position++;
      return _parseFactor();
    }
    if (char == '-') {
      _position++;
      return -_parseFactor();
    }
    if (char == '(') {
      _position++;
      final value = _parseExpression();
      if (_position >= _expression.length || _expression[_position] != ')') {
        throw const FormatException('Missing closing bracket.');
      }
      _position++;
      return value;
    }
    if (_expression.startsWith('sqrt', _position)) {
      _position += 4;
      final value = _parseFactor();
      if (value < 0) {
        throw const FormatException('Square root of negative number.');
      }
      return sqrt(value);
    }
    if (_expression.startsWith('cbrt', _position)) {
      _position += 4;
      return _cubeRoot(_parseFactor());
    }
    if (_expression.startsWith('exp', _position)) {
      _position += 3;
      return exp(_parseFactor());
    }
    if (_expression.startsWith('pi', _position)) {
      _position += 2;
      return pi;
    }
    if (char == '\u03c0') {
      _position++;
      return pi;
    }
    if (char == 'e') {
      _position++;
      return e;
    }

    return _parseNumber();
  }

  // Parses a decimal number with optional scientific-notation exponent.
  double _parseNumber() {
    final start = _position;
    while (_position < _expression.length) {
      final char = _expression[_position];
      final isDigit = char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57;
      if (!isDigit && char != '.') {
        break;
      }
      _position++;
    }

    if (_position < _expression.length) {
      final exponentChar = _expression[_position];
      if (exponentChar == 'e' || exponentChar == 'E') {
        final exponentStart = _position;
        _position++;

        if (_position < _expression.length) {
          final signChar = _expression[_position];
          if (signChar == '+' || signChar == '-') {
            _position++;
          }
        }

        final digitStart = _position;
        while (_position < _expression.length) {
          final char = _expression[_position];
          final isDigit = char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57;
          if (!isDigit) {
            break;
          }
          _position++;
        }

        if (digitStart == _position) {
          _position = exponentStart;
        }
      }
    }

    if (start == _position) {
      throw const FormatException('Expected number.');
    }
    return double.parse(_expression.substring(start, _position));
  }

  double _cubeRoot(double value) {
    if (value == 0) {
      return 0;
    }
    final magnitude = pow(value.abs(), 1 / 3).toDouble();
    return value.isNegative ? -magnitude : magnitude;
  }
}
