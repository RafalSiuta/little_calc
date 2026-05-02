import 'package:flutter_test/flutter_test.dart';
import 'package:little_calc/model/calculator_logic.dart';

void main() {
  group('CalculatorLogic scientific functions', () {
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
  });
}
