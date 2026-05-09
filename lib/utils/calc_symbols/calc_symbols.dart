class CalcSymbols {
  static const String divisionSign = '\u00f7';
  static const String multiplicationSign = '\u00d7';

  static const String squareSign = 'x\u00b2';
  static const String cubeSign = 'x\u00b3';
  static const String powerSign = 'y\u00b2';
  static const String expSign = 'e\u02e3';
  static const String absoluteSign = '|x|';
  static const String factorialSign = 'x!';
  static const String squareRootSign = '\u221a';
  static const String cubeRootSign = '\u00b3\u221a';

  static const List<List<String>> compactRows = [
    ['C', '()', '%', divisionSign],
    ['7', '8', '9', multiplicationSign],
    ['4', '5', '6', '-'],
    ['1', '2', '3', '+'],
    ['+/-', '0', '.', '='],
  ];

  static const List<List<String>> expandedFunctionRows = [
    ['sin', 'cos', 'tan', squareRootSign, squareSign],
    [
      'sin\u207b\u00b9',
      'cos\u207b\u00b9',
      'tan\u207b\u00b9',
      cubeRootSign,
      cubeSign
    ],
    ['sinh', 'cosh', 'tanh', powerSign, '\u03c0'],
    ['sinh\u207b\u00b9', 'cosh\u207b\u00b9', 'tanh\u207b\u00b9', '\u03c0', 'e'],
    ['Rad', 'log', 'ln', absoluteSign, factorialSign],
  ];

  static const List<List<String>> expandedBasicRows = compactRows;

  static const List<List<String>> expandedRows = [
    [
      'sin',
      'cos',
      'tan',
      squareRootSign,
      squareSign,
      'C',
      '()',
      '%',
      divisionSign,
    ],
    [
      'sin\u207b\u00b9',
      'cos\u207b\u00b9',
      'tan\u207b\u00b9',
      cubeRootSign,
      cubeSign,
      '7',
      '8',
      '9',
      multiplicationSign,
    ],
    [
      'sinh',
      'cosh',
      'tanh',
      powerSign,
      '\u03c0',
      '4',
      '5',
      '6',
      '-',
    ],
    [
      'sinh\u207b\u00b9',
      'cosh\u207b\u00b9',
      'tanh\u207b\u00b9',
      '\u03c0',
      'e',
      '1',
      '2',
      '3',
      '+',
    ],
    ['Rad', 'log', 'ln', absoluteSign, factorialSign, '+/-', '0', '.', '='],
  ];

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
      case '()':
        return '()';
      default:
        return value;
    }
  }
}
