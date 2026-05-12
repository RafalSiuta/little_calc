import 'package:flutter_test/flutter_test.dart';
import 'package:little_calc/utils/calc_logic/calculator_logic.dart';
import 'package:little_calc/utils/calc_symbols/calc_symbols.dart';

void main() {
  group('CalculatorLogic scientific functions', () {
    test('does not append repeated zeros after toggling zero negative', () {
      final logic = CalculatorLogic();

      logic.onPlusMinus();
      logic.onPlusMinus();
      logic.onNumbers('0');
      logic.onNumbers('0');

      expect(logic.equationDisplay, '-0');
      expect(logic.display, '0');
    });

    test('replaces negative zero when a non-zero digit is entered', () {
      final logic = CalculatorLogic();

      logic.onPlusMinus();
      logic.onPlusMinus();
      logic.onNumbers('7');

      expect(logic.equationDisplay, '-7');
      expect(logic.display, '0');
    });

    test('inserts pi as a constant token', () {
      final logic = CalculatorLogic();

      logic.multifunction('\u03c0');

      expect(logic.equationDisplay, '\u03c0');
      expect(logic.display, '3.1415926536');
    });

    test('inserts e as a constant token', () {
      final logic = CalculatorLogic();

      logic.multifunction('e');

      expect(logic.equationDisplay, 'e');
      expect(logic.display, '2.7182818285');
    });

    test('uses implicit multiplication before constants', () {
      final logic = CalculatorLogic();

      logic.onNumbers('2');
      logic.multifunction('\u03c0');

      expect(logic.equationDisplay, '2\u00d7\u03c0');
      expect(logic.display, '6.2831853072');
    });

    test('keeps display at zero while entering the first operand', () {
      final logic = CalculatorLogic();

      logic.onNumbers('4');
      logic.onNumbers('5');
      logic.onNumbers('6');

      expect(logic.equationDisplay, '456');
      expect(logic.display, '0');
    });

    test('starts live preview only after the second operand is entered', () {
      final logic = CalculatorLogic();

      logic.onNumbers('4');
      logic.onNumbers('5');
      logic.onNumbers('6');
      logic.onOperator('+');

      expect(logic.equationDisplay, '456+');
      expect(logic.display, '0');

      logic.onNumbers('7');
      logic.onNumbers('8');
      logic.onNumbers('9');

      expect(logic.equationDisplay, '456+789');
      expect(logic.display, '1245');
    });

    test('squares an active number and shows exponent notation', () {
      final logic = CalculatorLogic();

      logic.onNumbers('5');
      logic.onPow();

      expect(logic.display, '25');
      expect(logic.equationDisplay, '5^(2)');
      expect(logic.errorMessage, isEmpty);
    });

    test('shows an error when square is pressed without a number', () {
      final logic = CalculatorLogic();

      logic.onPow();

      expect(logic.display, '0');
      expect(logic.errorMessage, 'error - enter number before square');
    });

    test('squares the active number inside a larger expression', () {
      final logic = CalculatorLogic();

      logic.onNumbers('2');
      logic.onOperator('+');
      logic.onNumbers('3');
      logic.onPow();

      expect(logic.display, '11');
      expect(logic.equationDisplay, '2+3^(2)');
    });

    test('cubes an active number and shows exponent notation', () {
      final logic = CalculatorLogic();

      logic.onNumbers('4');
      logic.multifunction('cube');

      expect(logic.display, '64');
      expect(logic.equationDisplay, '4^(3)');
      expect(logic.errorMessage, isEmpty);
    });

    test('shows an error when cube is pressed without a number', () {
      final logic = CalculatorLogic();

      logic.multifunction('cube');

      expect(logic.display, '0');
      expect(logic.errorMessage, 'error - enter number before cube');
    });

    test('starts a pending square-root expression without a number', () {
      final logic = CalculatorLogic();

      logic.onSqrt();

      expect(logic.display, '0');
      expect(logic.equationDisplay, '\u221a(');
    });

    test('inserts multiplication before square root after a number', () {
      final logic = CalculatorLogic();

      logic.onNumbers('5');
      logic.onSqrt();
      logic.onNumbers('9');

      expect(logic.display, '15');
      expect(logic.equationDisplay, '5\u00d7\u221a(9');
    });

    test('starts a pending cube-root expression without a number', () {
      final logic = CalculatorLogic();

      logic.multifunction('cbrt');

      expect(logic.display, '0');
      expect(logic.equationDisplay, '\u00b3\u221a(');
    });

    test('inserts multiplication before cube root after a number', () {
      final logic = CalculatorLogic();

      logic.onNumbers('2');
      logic.multifunction('cbrt');
      logic.onNumbers('8');

      expect(logic.display, '4');
      expect(logic.equationDisplay, '2\u00d7\u00b3\u221a(8');
    });

    test('evaluates real cube root for negative numbers', () {
      final logic = CalculatorLogic();

      logic.multifunction('cbrt');
      logic.onOperator('-');
      logic.onNumbers('8');

      expect(logic.display, '-2');
      expect(logic.equationDisplay, '\u00b3\u221a(-8');
    });

    test('raises a base to the next typed exponent', () {
      final logic = CalculatorLogic();

      logic.onNumbers('2');
      logic.multifunction('power');
      logic.onNumbers('3');

      expect(logic.display, '8');
      expect(logic.equationDisplay, '2^3');
    });

    test('starts an exponential expression', () {
      final logic = CalculatorLogic();

      logic.multifunction('exp');
      logic.onNumbers('2');

      expect(logic.display, '7.3890560989');
      expect(logic.equationDisplay, 'e^(2');
    });

    test('starts an exponential expression from the e to x button label', () {
      final logic = CalculatorLogic();

      logic.multifunction(CalcSymbols.expSign);
      logic.onNumbers('2');

      expect(logic.display, '7.3890560989');
      expect(logic.equationDisplay, 'e^(2');
    });

    test('starts a base-2 exponential expression from the 2 to x button label',
        () {
      final logic = CalculatorLogic();

      logic.multifunction(CalcSymbols.twoPowerSign);
      logic.onNumbers('3');

      expect(logic.display, '8');
      expect(logic.equationDisplay, '2^(3');
    });

    test('inserts phi as the golden ratio constant', () {
      final logic = CalculatorLogic();

      logic.multifunction('phi');

      expect(logic.display, '1.6180339887');
      expect(logic.equationDisplay, 'f');
    });

    test('matches the expanded function keyboard order from Figma', () {
      expect(CalcSymbols.expandedFunctionRows[0][1].label, 'e');
      expect(CalcSymbols.expandedFunctionRows[0][2].label, '\u03c0');
      expect(CalcSymbols.expandedFunctionRows[0][3].label, 'f');
      expect(CalcSymbols.expandedFunctionRows[2][2].label,
          CalcSymbols.twoPowerSign);
      expect(CalcSymbols.expandedFunctionRows[2][3].label,
          CalcSymbols.reciprocalSign);
      expect(CalcSymbols.expandedFunctionRows[4][3].label,
          CalcSymbols.trigToggleSign);
      expect(
        CalcSymbols.expandedFunctionRows.expand((row) => row).where(
              (value) => value.label == '\u03c0',
            ),
        hasLength(1),
      );
    });

    test('applies absolute value to the active number', () {
      final logic = CalculatorLogic();

      logic.onPlusMinus();
      logic.onPlusMinus();
      logic.onNumbers('5');
      logic.multifunction('abs');

      expect(logic.display, '5');
      expect(logic.equationDisplay, '|-5|');
    });

    test('applies factorial to a non-negative integer', () {
      final logic = CalculatorLogic();

      logic.onNumbers('5');
      logic.multifunction('factorial');

      expect(logic.display, '120');
      expect(logic.equationDisplay, '5!');
    });

    test('applies natural logarithm to the active number', () {
      final logic = CalculatorLogic();

      logic.onNumbers('1');
      logic.multifunction('ln');

      expect(logic.display, '0');
      expect(logic.equationDisplay, 'ln(1)');
    });

    test('applies base-10 logarithm to the active number', () {
      final logic = CalculatorLogic();

      logic.onNumbers('1');
      logic.onNumbers('0');
      logic.onNumbers('0');
      logic.multifunction('log');

      expect(logic.display, '2');
      expect(logic.equationDisplay, 'log(100)');
    });

    test('applies reciprocal to the active number', () {
      final logic = CalculatorLogic();

      logic.onNumbers('4');
      logic.multifunction('1/x');

      expect(logic.display, '0.25');
      expect(logic.equationDisplay, '1/(4)');
    });

    test('toggles angle mode from degrees to radians', () {
      final logic = CalculatorLogic();

      expect(logic.useRadians, isFalse);
      expect(logic.angleModeButtonLabel, 'Rad');
      expect(logic.angleModeDisplay, 'Deg');
      expect(logic.valueDisplay, isEmpty);

      logic.multifunction('angleMode');

      expect(logic.useRadians, isTrue);
      expect(logic.angleModeButtonLabel, 'Deg');
      expect(logic.angleModeDisplay, 'Rad');
      expect(logic.valueDisplay, 'Rad');
    });

    test('toggles angle mode back to degrees', () {
      final logic = CalculatorLogic();

      logic.multifunction('Rad');
      logic.multifunction('Deg');

      expect(logic.useRadians, isFalse);
      expect(logic.angleModeButtonLabel, 'Rad');
      expect(logic.angleModeDisplay, 'Deg');
      expect(logic.valueDisplay, 'Deg');
    });

    test('clears angle mode info after equals', () {
      final logic = CalculatorLogic();

      logic.multifunction('Rad');
      logic.onNumbers('1');
      logic.onEqual();

      expect(logic.valueDisplay, isEmpty);
    });

    test('clears angle mode info after delete', () {
      final logic = CalculatorLogic();

      logic.multifunction('Rad');
      logic.onNumbers('1');
      logic.delete();

      expect(logic.valueDisplay, isEmpty);
    });

    test('calculates sine using degrees by default', () {
      final logic = CalculatorLogic();

      logic.onNumbers('9');
      logic.onNumbers('0');
      logic.multifunction('sin');

      expect(logic.display, '1');
      expect(logic.equationDisplay, 'sin(90)');
      expect(logic.valueDisplay, 'Deg');
    });

    test('recalculates last trigonometric result when angle mode changes', () {
      final logic = CalculatorLogic();

      logic.onNumbers('3');
      logic.onNumbers('0');
      logic.multifunction('sin');

      expect(logic.display, '0.5');
      expect(logic.equationDisplay, 'sin(30)');
      expect(logic.valueDisplay, 'Deg');

      logic.multifunction('Rad');

      expect(logic.display, '-0.9880316241');
      expect(logic.equationDisplay, 'sin(30)');
      expect(logic.valueDisplay, 'Rad');
    });

    test('calculates inverse sine using degrees by default', () {
      final logic = CalculatorLogic();

      logic.onNumbers('1');
      logic.multifunction('asin');

      expect(logic.display, '90');
      expect(logic.equationDisplay, 'sin\u207b\u00b9(1)');
      expect(logic.valueDisplay, 'Deg');
    });

    test('calculates hyperbolic sine without angle mode conversion', () {
      final logic = CalculatorLogic();

      logic.onNumbers('0');
      logic.multifunction('sinh');

      expect(logic.display, '0');
      expect(logic.equationDisplay, 'sinh(0)');
      expect(logic.valueDisplay, isEmpty);
    });

    test('rejects inverse cosine values outside range', () {
      final logic = CalculatorLogic();

      logic.onNumbers('2');
      logic.multifunction('acos');

      expect(logic.display, '0');
      expect(logic.errorMessage, 'error - acos requires value from -1 to 1');
    });

    test('rejects factorial for decimal values', () {
      final logic = CalculatorLogic();

      logic.onNumbers('2');
      logic.onDecimal('.');
      logic.onNumbers('5');
      logic.multifunction('factorial');

      expect(logic.display, '0');
      expect(logic.errorMessage, 'error - factorial requires whole number');
    });
  });
}
