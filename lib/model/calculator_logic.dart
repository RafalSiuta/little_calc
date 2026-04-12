import 'dart:math';
import 'package:flutter/cupertino.dart';

import 'calc_flags.dart';

class CalculatorLogic extends ChangeNotifier {
  String newText = "";
  String oldText = "";
  var display = '0';
  var valueDisplay = '';
  var unitDisplay = '';
  var shortNameDisplay = '';
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

  void setText(double value, int pattern) {
    display =
        value.toStringAsFixed(value.truncateToDouble() == value ? 0 : pattern);
  }

  double parser() {
    return double.parse(display);
  }

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

  //check digit status and store operand as a oldText
  void setFlag() {
    if (flag == Flag.FIRST_OPERAND || flag == Flag.SECOND_OPERAND) {
      oldText = display;
    } else {
      oldText = "";
    }
  }

  void clear() {
    display = '0';
    oldValue = 0;
    newValue = 0;
    total = 0;
    clearSmallDisplay();
    flag = Flag.RESULT;
    notifyListeners();
  }

  void clearSmallDisplay() {
    valueDisplay = '';
    unitDisplay = '';
    shortNameDisplay = '';
    notifyListeners();
  }

  void delete() {
    int start = 0;
    int end = display.toString().length - 1;
    clearSmallDisplay();

    if (display.toString().length > 0) {
      newText = display.substring(start, end);
      display = newText;
    }
    if (display.toString().length == 0) {
      display = '0';
    }
    flag = Flag.RESULT;
    notifyListeners();
  }

  void onDecimal(String buttonText) {
    clearSmallDisplay();
    newText = buttonText;
    oldText = display;

    try {
      if (flag == Flag.RESULT ||
          flag == Flag.FIRST_OPERAND ||
          flag == Flag.SECOND_OPERAND) {
        if (display.toString().contains(".") ||
            display.toString().contains(",")) {
          oldText = display.toString().replaceAll(",", ".");
        } else {
          display = (oldText + newText).replaceAll(",", ".");
        }
      }
      if (flag == Flag.OPERATOR) {
        if (display == "0") {
          display = (oldText + newText).replaceAll(",", ".");
        } else {
          display = ("0" + newText).replaceAll(",", ".");
        }
      }
      checkFlag();
    } catch (e) {
      display = "0";
    }
    notifyListeners();
  }

  void onPlusMinus() {
    clearSmallDisplay();
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

  void onNumbers(String buttonText) {
    clearSmallDisplay();
    newText = buttonText; //.toString();

//    display = newText;
//    print(newText);
    try {
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

  void onOperator(String operatorButton) {
    clearSmallDisplay();
    if (flag == Flag.RESULT) {
      operator = operatorButton;
    }
    if (flag == Flag.SECOND_OPERAND) {
      switch (operator) {
        case "+":
          oldValue += newValue;
          break;
        case "-":
          oldValue -= newValue;
          break;
        case "*":
          oldValue *= newValue;
          break;
        case "/":
          oldValue /= newValue;
          break;
      }
      total = oldValue;
      newValue = 0;
      setText(oldValue, 20);
    }
    operator = operatorButton;
    flag = Flag.OPERATOR;
    notifyListeners();
  }

  void onEqual() {
    clearSmallDisplay();
    try {
      switch (operator) {
        case "+":
          oldValue += newValue;
          break;
        case "-":
          oldValue -= newValue;
          break;
        case "*":
          oldValue *= newValue;
          break;
        case "/":
          oldValue /= newValue;
          break;
        case "=":
          oldValue = total;
          break;
      }
      total = oldValue;
      newValue = 0;
      setText(oldValue, 20);

      flag = Flag.RESULT;
    } catch (e) {
      display = "0";
    }
    notifyListeners();
  }

  void onPercent() {
    clearSmallDisplay();
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

  void onPow() {
    clearSmallDisplay();
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

  void onSqrt() {
    clearSmallDisplay();
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
      case '.':
        onDecimal(char);
        break;
      case '%':
        onPercent();
        break;
      case 'C':
        clear();
        break;
      case '&':
        delete();
        break;
    }
  }
}
