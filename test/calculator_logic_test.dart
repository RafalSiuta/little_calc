import 'package:flutter_test/flutter_test.dart';
import 'package:little_calc/model/calculator_logic.dart';

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
      expect(logic.display, '-7');
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
