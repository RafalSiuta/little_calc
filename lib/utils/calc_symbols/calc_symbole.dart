class CalcSymbols {
  static const String divisionSign = '\u00f7';
  static const String multiplicationSign = '\u00d7';

  static const String squareSign = 'x\u00b2';
  static const String squareRootSign = '\u221a';

  static const List<List<String>> compactRows = [
    ['C', '()', '%', divisionSign],
    ['7', '8', '9', multiplicationSign],
    ['4', '5', '6', '-'],
    ['1', '2', '3', '+'],
    ['+/-', '0', '.', '='],
  ];

  static const List<List<String>> expandedRows = [
    [
      'sin',
      'cos',
      'Rad',
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
      '\u00b3\u221a',
      'x\u00b3',
      '7',
      '8',
      '9',
      multiplicationSign,
    ],
    [
      'sinh',
      'cosh',
      'tanh',
      'y\u00b2',
      'e\u02e3',
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
    ['ln', 'log', '1/x', '|x|', 'x!', '+/-', '0', '.', '='],
  ];
}
