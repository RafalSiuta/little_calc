import 'package:bixcalc/models/currency_model/currency.dart';
import 'package:bixcalc/providers/calculator_memory_provider.dart';
import 'package:bixcalc/utils/calc_logic/calculator_logic.dart';
import 'package:bixcalc/utils/calc_symbols/calc_symbols.dart';
import 'package:bixcalc/utils/currency_logic/currency_logic.dart';
import 'package:bixcalc/utils/unit_converter_logic/unit_converter_logic.dart';
import 'package:bixcalc/utils/unit_converter_logic/unit_definitions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'stores a converted value and recalls it in the scientific calculator',
    () {
      final memory = CalculatorMemoryProvider();
      final units = UnitConverterLogic(category: UnitCategory.length)
        ..setTargetUnit(UnitDefinitions.byCategory[UnitCategory.length]![2])
        ..handleKeyPress('2');
      final calculator = CalculatorLogic();

      expect(units.resultValue, '200');
      expect(CalcSymbols.logicValue('M+'), 'M+');
      memory.handleKey(
        'M+',
        currentValue: units.memoryValue,
        onRecall: units.recallMemoryValue,
      );
      memory.handleKey(
        'MR',
        currentValue: calculator.memoryValue,
        onRecall: calculator.recallMemoryValue,
      );

      expect(calculator.display, '200');
      calculator.onOperator('+');
      calculator.onNumbers('3');
      calculator.onEqual();
      expect(calculator.display, '203');

      units.dispose();
      calculator.dispose();
      memory.dispose();
    },
  );

  test('adds and subtracts values across calculators, then clears memory', () {
    final memory = CalculatorMemoryProvider();
    final calculator = CalculatorLogic()..onNumbers('7');
    final currency = CurrencyLogic()
      ..updateCurrencies(base: _currency('USD', 4), target: _currency('PLN', 1))
      ..clear()
      ..handleKeyPress('2');

    memory.handleKey(
      'M+',
      currentValue: calculator.memoryValue,
      onRecall: calculator.recallMemoryValue,
    );
    memory.handleKey(
      'M-',
      currentValue: currency.memoryValue,
      onRecall: currency.recallMemoryValue,
    );
    expect(memory.value, -1);

    currency.setActiveDisplay(CurrencyActiveDisplay.target);
    memory.handleKey(
      'MR',
      currentValue: currency.memoryValue,
      onRecall: currency.recallMemoryValue,
    );
    expect(currency.targetValueDisplay, '-1');

    memory.handleKey(
      'MC',
      currentValue: null,
      onRecall: calculator.recallMemoryValue,
    );
    expect(memory.value, isNull);
    expect(
      memory.handleKey(
        'MR',
        currentValue: null,
        onRecall: calculator.recallMemoryValue,
      ),
      isTrue,
    );
    expect(calculator.memoryValue, 7);

    calculator.dispose();
    currency.dispose();
    memory.dispose();
  });
}

Currency _currency(String code, double value) => Currency(
  id: code,
  countryName: code,
  valueName: code,
  qty: 1,
  codeIso: code,
  symbol: code,
  flagImg: '',
  currencyValues: [
    CurrencyValue(id: code, date: '01.01.2026', value: '$value'),
  ],
);
