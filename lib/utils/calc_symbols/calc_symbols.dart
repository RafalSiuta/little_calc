enum CalcKeyType {
  number,
  operator,
  function,
}

class CalcKey {
  const CalcKey(
    this.label, {
    this.type = CalcKeyType.number,
    this.flex = 1,
  });

  final String label;
  final CalcKeyType type;
  final int flex;
}

class CalcSymbols {
  static const String divisionSign = '\u00f7';
  static const String multiplicationSign = '\u00d7';

  static const String squareSign = 'x\u00b2';
  static const String cubeSign = 'x\u00b3';
  static const String powerSign = 'y\u00b2';
  static const String expSign = 'e\u02e3';
  static const String twoPowerSign = '2\u02e3';
  static const String reciprocalSign = '1/x';
  static const String goldenRatioSign = 'f';
  static const String absoluteSign = '|x|';
  static const String factorialSign = 'x!';
  static const String squareRootSign = '\u221a';
  static const String cubeRootSign = '\u00b3\u221a';
  static const String trigToggleSign = '\u2190';

  static const CalcKeyType _fn = CalcKeyType.function;
  static const CalcKeyType _op = CalcKeyType.operator;

  static const List<List<CalcKey>> compactRows = [
    [
      CalcKey('MC', type: _fn),
      CalcKey('MR', type: _fn),
      CalcKey('M+', type: _fn),
      CalcKey('M-', type: _fn),
    ],
    [
      CalcKey('C', type: _fn),
      CalcKey('()', type: _op),
      CalcKey('+/-', type: _op),
      CalcKey(divisionSign, type: _op),
    ],
    [
      CalcKey('7'),
      CalcKey('8'),
      CalcKey('9'),
      CalcKey(multiplicationSign, type: _op),
    ],
    [
      CalcKey('4'),
      CalcKey('5'),
      CalcKey('6'),
      CalcKey('-', type: _op),
    ],
    [
      CalcKey('1'),
      CalcKey('2'),
      CalcKey('3'),
      CalcKey('+', type: _op),
    ],
    [
      CalcKey('.', type: _op),
      CalcKey('0'),
      CalcKey('=', type: _op, flex: 2),
    ],
  ];

  static const List<List<CalcKey>> expandedFunctionRows = [
    [
      CalcKey('%', type: _fn),
      CalcKey('e', type: _fn),
      CalcKey('\u03c0', type: _fn),
      CalcKey(goldenRatioSign, type: _fn),
    ],
    [
      CalcKey(squareSign, type: _fn),
      CalcKey(cubeSign, type: _fn),
      CalcKey(expSign, type: _fn),
      CalcKey(powerSign, type: _fn),
    ],
    [
      CalcKey(squareRootSign, type: _fn),
      CalcKey(cubeRootSign, type: _fn),
      CalcKey(twoPowerSign, type: _fn),
      CalcKey(reciprocalSign, type: _fn),
    ],
    [
      CalcKey('ln', type: _fn),
      CalcKey('log', type: _fn),
      CalcKey(factorialSign, type: _fn),
      CalcKey(absoluteSign, type: _fn),
    ],
    [
      CalcKey('sin', type: _fn),
      CalcKey('cos', type: _fn),
      CalcKey('tan', type: _fn),
      CalcKey(trigToggleSign, type: _op),
    ],
    [
      CalcKey('sin\u207b\u00b9', type: _fn),
      CalcKey('cos\u207b\u00b9', type: _fn),
      CalcKey('tan\u207b\u00b9', type: _fn),
      CalcKey('Rad', type: _op),
    ],
  ];

  static const List<List<CalcKey>> expandedHyperbolicFunctionRows = [
    [
      CalcKey('%', type: _fn),
      CalcKey('e', type: _fn),
      CalcKey('\u03c0', type: _fn),
      CalcKey(goldenRatioSign, type: _fn),
    ],
    [
      CalcKey(squareSign, type: _fn),
      CalcKey(cubeSign, type: _fn),
      CalcKey(expSign, type: _fn),
      CalcKey(powerSign, type: _fn),
    ],
    [
      CalcKey(squareRootSign, type: _fn),
      CalcKey(cubeRootSign, type: _fn),
      CalcKey(twoPowerSign, type: _fn),
      CalcKey(reciprocalSign, type: _fn),
    ],
    [
      CalcKey('ln', type: _fn),
      CalcKey('log', type: _fn),
      CalcKey(factorialSign, type: _fn),
      CalcKey(absoluteSign, type: _fn),
    ],
    [
      CalcKey('sinh', type: _fn),
      CalcKey('cosh', type: _fn),
      CalcKey('tanh', type: _fn),
      CalcKey(trigToggleSign, type: _op),
    ],
    [
      CalcKey('sinh\u207b\u00b9', type: _fn),
      CalcKey('cosh\u207b\u00b9', type: _fn),
      CalcKey('tanh\u207b\u00b9', type: _fn),
      CalcKey('Rad', type: _op),
    ],
  ];

  static const List<List<CalcKey>> expandedBasicRows = compactRows;

  static String logicValue(String value) {
    switch (value) {
      case divisionSign:
        return '/';
      case multiplicationSign:
        return '*';
      case squareRootSign:
        return 'sqrt';
      case squareSign:
        return 'square';
      case cubeSign:
        return 'cube';
      case powerSign:
        return 'power';
      case expSign:
        return 'exp';
      case twoPowerSign:
        return 'twoPower';
      case goldenRatioSign:
        return 'phi';
      case 'sin\u207b\u00b9':
        return 'asin';
      case 'cos\u207b\u00b9':
        return 'acos';
      case 'tan\u207b\u00b9':
        return 'atan';
      case 'sinh\u207b\u00b9':
        return 'asinh';
      case 'cosh\u207b\u00b9':
        return 'acosh';
      case 'tanh\u207b\u00b9':
        return 'atanh';
      case absoluteSign:
        return 'abs';
      case factorialSign:
        return 'factorial';
      case cubeRootSign:
        return 'cbrt';
      case 'Rad':
      case 'Deg':
        return 'angleMode';
      case 'MC':
      case 'MR':
      case 'M+':
      case 'M-':
        return '';
      case '()':
        return '()';
      default:
        return value;
    }
  }
}
