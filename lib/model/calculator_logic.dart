import 'dart:math';
import 'package:flutter/cupertino.dart';

import 'calc_flags.dart';

class CalculatorLogic extends ChangeNotifier {
  String newText = "";
  String oldText = "";
  String secondOperandText = "";
  var display = '0';
  var valueDisplay = '';
  var equationDisplay = '';
  // var shortNameDisplay = '';
  String operator = "";

  double oldValue = 0;
  double newValue = 0;
  double total = 0;

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
  int openBrackets = 0;

  // Formats a numeric result for the main display, trimming decimals for whole
  // numbers and keeping up to [pattern] fractional digits otherwise.
  void setText(double value, int pattern) {
    display =
        value.toStringAsFixed(value.truncateToDouble() == value ? 0 : pattern);
  }

  // Converts the current main display value into a number used by operations.
  double parser() {
    return double.parse(display);
  }

  // Stores the current display value in the operand slot implied by [flag].
  // The first entered number becomes [oldValue], then numbers after an
  // operator become [newValue].
  void checkFlag() {
    if (flag == Flag.RESULT || flag == Flag.FIRST_OPERAND) {
      total = oldValue;
      oldValue = parser();
      flag = Flag.FIRST_OPERAND;
    } else {
      total = newValue;
      newValue = parser();
      flag = Flag.SECOND_OPERAND;
    }
  }

  // Calculates the current binary operation without mutating operands. This is
  // used for live result previews while the user is still typing the second
  // operand.
  double calculatePendingResult() {
    switch (operator) {
      case "+":
        return oldValue + newValue;
      case "-":
        return oldValue - newValue;
      case "*":
        return oldValue * newValue;
      case "/":
        return oldValue / newValue;
      default:
        return parser();
    }
  }

  // Evaluates the currently visible equation with operator precedence and
  // parentheses. This parser is intentionally small and local to the calculator
  // model, so the existing flag-based input flow can remain readable.
  double evaluateExpression(String expression) {
    final parser = _ExpressionParser(expression);
    return parser.parse();
  }

  // Returns true when the equation currently ends with a number or a closing
  // bracket, which means it is safe to calculate a preview result.
  bool canPreviewEquation() {
    if (equationDisplay.isEmpty) {
      return false;
    }
    final last = equationDisplay[equationDisplay.length - 1];
    return _isDigit(last) || last == ')';
  }

  // Updates the main display with a live result preview for the current
  // equation. Unclosed brackets are temporarily closed only for preview.
  void updateDisplayFromEquation() {
    if (!canPreviewEquation()) {
      return;
    }
    final previewExpression = equationDisplay + _closingBracketsPreview();
    final result = evaluateExpression(previewExpression);
    setText(result, 20);
    total = result;
  }

  // Completes currently open brackets for preview calculation only.
  String _closingBracketsPreview() {
    return List.filled(openBrackets, ')').join();
  }

  // Returns whether a character is one of the binary operators shown to users.
  bool _isOperatorGlyph(String value) {
    return value == '+' ||
        value == '-' ||
        value == '\u00d7' ||
        value == '\u00f7';
  }

  // Returns whether a character is a decimal digit.
  bool _isDigit(String value) {
    return value.codeUnitAt(0) >= 48 && value.codeUnitAt(0) <= 57;
  }

  // Checks the currently typed number segment so a decimal separator can only
  // be added once per operand.
  bool _currentNumberContainsDecimal() {
    for (var i = equationDisplay.length - 1; i >= 0; i--) {
      final char = equationDisplay[i];
      if (char == '.') {
        return true;
      }
      if (_isOperatorGlyph(char) || char == '(' || char == ')') {
        return false;
      }
    }
    return false;
  }

  // Decides whether the shared "()" key should add an opening bracket.
  bool _shouldOpenBracket() {
    if (equationDisplay.isEmpty) {
      return true;
    }
    final last = equationDisplay[equationDisplay.length - 1];
    return _isOperatorGlyph(last) || last == '(';
  }

  // Decides whether the shared "()" key can close an already opened bracket.
  bool _canCloseBracket() {
    if (openBrackets <= 0 || equationDisplay.isEmpty) {
      return false;
    }
    final last = equationDisplay[equationDisplay.length - 1];
    return _isDigit(last) || last == ')';
  }

  // Prepares text concatenation for digit input by deciding whether the next
  // digit extends the current operand or starts from an empty display.
  void setFlag() {
    if (flag == Flag.FIRST_OPERAND || flag == Flag.SECOND_OPERAND) {
      oldText = display;
    } else {
      oldText = "";
    }
  }

  // Adds a user-selected token to the equation display shown above the result.
  void addToEquationDisplay(String value) {
    equationDisplay += _equationGlyph(value);
  }

  // Starts a clean equation after a completed calculation when the next input
  // should begin a new expression instead of extending the old one.
  void prepareEquationForInput() {
    if (flag == Flag.RESULT && equationDisplay.isEmpty && display != '0') {
      display = '0';
      oldValue = 0;
      newValue = 0;
    }
  }

  // Uses the visible result as the first token when the user continues from a
  // completed calculation with another operator.
  void prepareEquationForOperator() {
    if (flag == Flag.RESULT && equationDisplay.isEmpty) {
      equationDisplay = display;
    }
  }

  // Converts internal logic tokens into the glyphs that should be visible in
  // the equation display.
  String _equationGlyph(String value) {
    switch (value) {
      case '/':
        return '\u00f7';
      case '*':
        return '\u00d7';
      case 'sqrt':
        return '\u221a';
      case 'square':
        return '\u00b2';
      case '+/-':
        return '\u00b1';
      default:
        return value;
    }
  }

  // Resets every value and display fragment back to the initial calculator
  // state.
  void clear() {
    display = '0';
    oldValue = 0;
    newValue = 0;
    secondOperandText = "";
    total = 0;
    operator = "";
    openBrackets = 0;
    clearSmallDisplay();
    equationDisplay = '';
    flag = Flag.RESULT;
    notifyListeners();
  }

  // Clears secondary display text without touching the equation being typed.
  void clearSmallDisplay() {
    valueDisplay = '';
    // shortNameDisplay = '';
    notifyListeners();
  }

  // Removes the last digit from the main display and the last visible token
  // from the equation display. Empty displays fall back to the initial state.
  void delete() {
    int start = 0;
    int end = display.toString().length - 1;
    clearSmallDisplay();

    if (equationDisplay.isNotEmpty) {
      final removedChar = equationDisplay[equationDisplay.length - 1];
      equationDisplay = equationDisplay.substring(
        0,
        equationDisplay.length - 1,
      );
      if (removedChar == '(') {
        openBrackets = max(0, openBrackets - 1);
      }
      if (removedChar == ')') {
        openBrackets++;
      }
    }

    if (flag == Flag.OPERATOR) {
      operator = "";
      flag = equationDisplay.endsWith('(')
          ? Flag.OPEN_BRACKET
          : Flag.FIRST_OPERAND;
      notifyListeners();
      return;
    }

    if (equationDisplay.isEmpty) {
      display = '0';
      oldValue = 0;
      newValue = 0;
      secondOperandText = "";
      total = 0;
      flag = Flag.RESULT;
      notifyListeners();
      return;
    }

    if (flag == Flag.SECOND_OPERAND && secondOperandText.isNotEmpty) {
      secondOperandText = secondOperandText.substring(
        0,
        secondOperandText.length - 1,
      );
      if (secondOperandText.isEmpty) {
        newValue = 0;
        setText(oldValue, 20);
        flag = Flag.OPERATOR;
      } else {
        newValue = double.parse(secondOperandText);
        setText(calculatePendingResult(), 20);
      }
      notifyListeners();
      return;
    }

    try {
      updateDisplayFromEquation();
    } catch (e) {
      if (display.toString().length > 0) {
        newText = display.substring(start, end);
        display = newText;
      }
      if (display.toString().length == 0) {
        display = '0';
      }
    }
    flag = Flag.RESULT;
    notifyListeners();
  }

  // Adds a decimal separator to the active operand when it does not already
  // contain one.
  void onDecimal(String buttonText) {
    clearSmallDisplay();
    prepareEquationForInput();
    if (_currentNumberContainsDecimal()) {
      return;
    }
    if (equationDisplay.isEmpty ||
        _isOperatorGlyph(equationDisplay[equationDisplay.length - 1]) ||
        equationDisplay.endsWith('(')) {
      addToEquationDisplay('0');
    }
    addToEquationDisplay(buttonText);
    flag = openBrackets > 0 ? Flag.OPEN_BRACKET : flag;
    notifyListeners();
  }

  // Toggles the sign of the current display value and stores the changed value
  // in the active operand.
  void onPlusMinus() {
    clearSmallDisplay();
    addToEquationDisplay('+/-');
    total = parser();

    if (total == 0) {
      clear();
    } else {
      total = total * (-1);
      setText(total, 20);
    }

    checkFlag();
    notifyListeners();
  }

  // Handles digit buttons, building the current operand text and updating the
  // operand value according to [flag].
  void onNumbers(String buttonText) {
    clearSmallDisplay();
    prepareEquationForInput();
    addToEquationDisplay(buttonText);
    newText = buttonText; //.toString();

//    display = newText;
//    print(newText);
    try {
      if (operator.isNotEmpty || openBrackets > 0) {
        updateDisplayFromEquation();
        flag = Flag.SECOND_OPERAND;
        notifyListeners();
        return;
      }

      setFlag();
      if (oldText == "0") {
        display = newText;
      } else {
        display = oldText + newText;
      }

      checkFlag();
    } catch (e) {
      //print('error');
    }
    notifyListeners();
  }

  // Stores the selected binary operator. If a second operand is already
  // present, it resolves the pending operation before accepting the next one.
  void onOperator(String operatorButton) {
    clearSmallDisplay();
    prepareEquationForOperator();
    if (equationDisplay.isEmpty) {
      return;
    }
    final last = equationDisplay[equationDisplay.length - 1];
    if (_isOperatorGlyph(last)) {
      equationDisplay = equationDisplay.substring(
        0,
        equationDisplay.length - 1,
      );
    } else if (last == '(') {
      return;
    }
    try {
      updateDisplayFromEquation();
      oldValue = total;
    } catch (e) {
      // Keep the previous preview until the expression becomes complete again.
    }
    addToEquationDisplay(operatorButton);
    if (flag == Flag.RESULT) {
      operator = operatorButton;
    }
    if (flag == Flag.SECOND_OPERAND) {
      newValue = 0;
      secondOperandText = "";
    }
    operator = operatorButton;
    flag = Flag.OPERATOR;
    notifyListeners();
  }

  // Resolves the pending binary operation and moves the result back to the main
  // display.
  void onEqual() {
    clearSmallDisplay();
    try {
      if (equationDisplay.isNotEmpty && canPreviewEquation()) {
        oldValue = evaluateExpression(
          equationDisplay + _closingBracketsPreview(),
        );
      } else if (flag == Flag.SECOND_OPERAND) {
        oldValue = calculatePendingResult();
      }
      total = oldValue;
      newValue = 0;
      secondOperandText = "";
      setText(oldValue, 20);
      equationDisplay = '';
      openBrackets = 0;
      operator = "";

      flag = Flag.RESULT;
    } catch (e) {
      display = "0";
    }
    notifyListeners();
  }

  // Applies percentage semantics to the active operation while preserving the
  // existing flag-driven operand flow.
  void onPercent() {
    clearSmallDisplay();
    addToEquationDisplay('%');
    if (flag == Flag.RESULT) {
      operator = operator;
    }
    if (flag == Flag.FIRST_OPERAND) {
      oldValue = (oldValue / 100);
    }
    if (flag == Flag.SECOND_OPERAND) {
      oldValue *= newValue / 100;
    }
    total = oldValue;
    newValue = 0;
    setText(oldValue, 20);

    flag = Flag.RESULT;
    notifyListeners();
  } //TODO check operatop = operator is it correct ???

  // Squares the current display value and stores the result as the active
  // operand.
  void onPow() {
    clearSmallDisplay();
    addToEquationDisplay('square');
    try {
      total = parser();
      total = pow(total, 2) as double;
      setText(total, 20);
      flag = Flag.RESULT;
      checkFlag();
    } catch (e) {
      display = '0';
    }
    notifyListeners();
  }

  // Calculates the square root of the current display value and stores the
  // result as the active operand.
  void onSqrt() {
    clearSmallDisplay();
    addToEquationDisplay('sqrt');
    try {
      total = parser();

      total = sqrt(total);
      setText(total, 20);
    } catch (e) {
      display = '0';
    }

    checkFlag();
    notifyListeners();
  }

  // Routes a keyboard button token to the matching calculator action.
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
      case 'x²':
        onPow();
        break;
      case '√':
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

  // Handles the shared bracket key. It opens a bracket when the equation is at
  // the start or after an operator, otherwise it closes the latest open bracket.
  void onBracket() {
    clearSmallDisplay();
    prepareEquationForInput();

    if (_shouldOpenBracket()) {
      addToEquationDisplay('(');
      openBrackets++;
      flag = Flag.OPEN_BRACKET;
    } else if (_canCloseBracket()) {
      addToEquationDisplay(')');
      openBrackets--;
      flag = Flag.CLOSE_BRACKET;
      try {
        updateDisplayFromEquation();
      } catch (e) {
        // Wait for a complete expression before showing a bracket preview.
      }
    }

    notifyListeners();
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

  double parse() {
    final value = _parseExpression();
    if (_position != _expression.length) {
      throw const FormatException('Unexpected expression token.');
    }
    return value;
  }

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

    return _parseNumber();
  }

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
    if (start == _position) {
      throw const FormatException('Expected number.');
    }
    return double.parse(_expression.substring(start, _position));
  }
}
