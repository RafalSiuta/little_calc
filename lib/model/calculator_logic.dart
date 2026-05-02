import 'dart:math';

import 'package:flutter/cupertino.dart';

import '../providers/calculator_settings_provider.dart';
import '../utils/extensions/number_formatter.dart';
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

    if (_lastTokenIsCloseBracket()) {
      _appendOperatorToken("*");
    }

    if (_currentNumber == '0') {
      _replaceLastNumberToken(buttonText);
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

  // Starts a square-root function. Without a preceding number it opens `sqrt(`
  // and waits for input; after a number it inserts multiplication before sqrt.
  void onSqrt() {
    clearSmallDisplay();

    if (_tokens.isEmpty && display != '0' && flag == Flag.RESULT) {
      _resetExpressionToNumber(parser());
    }

    if (_lastTokenIsNumber() || _lastTokenIsCloseBracket()) {
      _appendOperatorToken('*');
    } else if (_tokens.isNotEmpty &&
        !_lastTokenIsOperator() &&
        _tokens.last != '(' &&
        _tokens.last != 'sqrt') {
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

  // Handles the shared bracket key, opening or closing a bracket based on the
  // current token context.
  void onBracket() {
    clearSmallDisplay();

    if (_shouldOpenBracket()) {
      if (_lastTokenIsNumber() || _lastTokenIsCloseBracket()) {
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
      case 'sqrt':
        onSqrt();
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
      case 'C':
        clear();
        break;
      case '&':
        delete();
        break;
    }
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
  void _refreshStateAfterTokenChange() {
    _syncEquationDisplay();

    if (_tokens.isEmpty) {
      display = '0';
      flag = Flag.RESULT;
      return;
    }

    if (_lastTokenIsNumber()) {
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
      if (_canEvaluateExpression()) {
        final result = _evaluateTokens(completeOpenBrackets: true);
        setText(result);
        total = result;
      } else if (_currentNumber.isNotEmpty) {
        display = _currentNumber;
      }
    } catch (e) {
      if (_currentNumber.isNotEmpty) {
        display = _currentNumber;
      }
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
      default:
        return value;
    }
  }

  // Returns true when the expression currently has a calculable ending.
  bool _canEvaluateExpression() {
    if (_tokens.isEmpty) {
      return false;
    }
    return _lastTokenIsNumber() || _lastTokenIsCloseBracket();
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
    if (_lastTokenIsNumber() || _lastTokenIsCloseBracket()) {
      return openBrackets == 0;
    }
    return false;
  }

  // Decides whether the shared bracket key can close an existing bracket.
  bool _canCloseBracket() {
    return openBrackets > 0 &&
        (_lastTokenIsNumber() || _lastTokenIsCloseBracket());
  }

  // Returns true when any binary operator is present in tokens.
  bool _hasOperatorToken() {
    return _tokens.any(_isOperatorToken);
  }

  // Returns true when the last token is a number.
  bool _lastTokenIsNumber() {
    return _tokens.isNotEmpty && _isNumberToken(_tokens.last);
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
    return value == '+' || value == '-' || value == '*' || value == '/';
  }

  // Returns true when a token can be parsed as a number.
  bool _isNumberToken(String value) {
    return double.tryParse(value) != null;
  }

  // Formats a number for storing inside the token list.
  String _formatTokenNumber(double value) {
    return _formatDisplayNumber(value);
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
    var value = _parseFactor();
    while (_position < _expression.length) {
      final operator = _expression[_position];
      if (operator != '*' && operator != '/') {
        break;
      }
      _position++;
      final nextValue = _parseFactor();
      value = operator == '*' ? value * nextValue : value / nextValue;
    }
    return value;
  }

  // Parses signs, parentheses, square-root calls, and raw number factors.
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
}
