import 'package:flutter_test/flutter_test.dart';
import 'package:little_calc/models/currency_model/currency.dart';
import 'package:little_calc/utils/currency_logic/currency_logic.dart';

void main() {
  group('CurrencyLogic', () {
    test('enters numbers on the base display and converts to target', () {
      final logic = CurrencyLogic()
        ..updateCurrencies(
          base: _currency('USD', value: 4),
          target: _currency('PLN', value: 1),
        );

      logic.handleKeyPress('1');
      logic.handleKeyPress('2');
      logic.handleKeyPress('.');
      logic.handleKeyPress('5');

      expect(logic.baseValueDisplay, '12.5');
      expect(logic.targetValueDisplay, '50');
      expect(logic.resultDisplay, '50');
    });

    test('ignores non numeric functions on currency choice displays', () {
      final logic = CurrencyLogic()
        ..updateCurrencies(
          base: _currency('USD', value: 4),
          target: _currency('PLN', value: 1),
        );

      logic.handleKeyPress('1');
      logic.handleKeyPress('()');
      logic.handleKeyPress('square');

      expect(logic.baseValueDisplay, '1');
      expect(logic.equationDisplay, isEmpty);
    });

    test('commits converted currency amount to equation when operator is used',
        () {
      final logic = CurrencyLogic()
        ..updateCurrencies(
          base: _currency('USD', value: 4),
          target: _currency('PLN', value: 1),
        );

      logic.handleKeyPress('1');
      logic.handleKeyPress('0');
      logic.handleKeyPress('+');
      logic.handleKeyPress('2');
      logic.handleKeyPress('+');

      expect(logic.equationDisplay, '40+8+');
      expect(logic.resultDisplay, '48');
    });

    test('converts backwards when target display is active', () {
      final usd = _currency('USD', value: 4, valueName: 'dolar');
      final pln = _currency('PLN', value: 1, valueName: 'zloty');
      final logic = CurrencyLogic()
        ..updateCurrencies(base: usd, target: pln)
        ..setActiveDisplay(CurrencyActiveDisplay.target);

      logic.handleKeyPress('2');
      logic.handleKeyPress('0');

      expect(logic.targetValueDisplay, '20');
      expect(logic.baseValueDisplay, '5');
      expect(logic.resultDisplay, '5');
      expect(logic.resultCurrency, usd);
      expect(logic.baseLabel(usd, pln), 'to: dolar');
      expect(logic.targetLabel(usd, pln), 'from: zloty');
    });

    test('uses normal calculator logic on equation display', () {
      final logic = CurrencyLogic()
        ..updateCurrencies(
          base: _currency('USD', value: 4),
          target: _currency('PLN', value: 1),
        )
        ..setActiveDisplay(CurrencyActiveDisplay.equation);

      logic.handleKeyPress('2');
      logic.handleKeyPress('+');
      logic.handleKeyPress('3');

      expect(logic.equationDisplay, '2+3');
      expect(logic.resultDisplay, '5');
    });

    test('formats info rate with two decimal places', () {
      final usd = _currency('USD', value: 3.6257);
      final pln = _currency('PLN', value: 1);
      final logic = CurrencyLogic()..updateCurrencies(base: usd, target: pln);

      expect(logic.rateDisplay(usd, pln), '1 USD = 3.6257 PLN');
    });

    test('distinguishes currencies that share the same display symbol', () {
      final usd = _currency('USD', value: 4);
      final cad = _currency('CAD', value: 3);
      final pln = _currency('PLN', value: 1);
      final logic = CurrencyLogic()..updateCurrencies(base: usd, target: pln);

      logic.updateCurrencies(base: cad, target: pln);

      expect(logic.rateDisplay(cad, pln), '1 CAD = 3.0000 PLN');
    });

    test('clear resets currency inputs and equation on every active display',
        () {
      final logic = CurrencyLogic()
        ..updateCurrencies(
          base: _currency('USD', value: 4),
          target: _currency('PLN', value: 1),
        );

      logic.handleKeyPress('1');
      logic.handleKeyPress('0');
      logic.handleKeyPress('+');
      logic.setActiveDisplay(CurrencyActiveDisplay.target);
      logic.handleKeyPress('2');
      logic.handleKeyPress('0');
      logic.handleKeyPress('C');

      expect(logic.baseValueDisplay, '0');
      expect(logic.targetValueDisplay, '0');
      expect(logic.equationDisplay, isEmpty);
      expect(logic.resultDisplay, '0');
    });
  });
}

Currency _currency(
  String symbol, {
  required double value,
  int qty = 1,
  String? valueName,
}) {
  return Currency(
    id: symbol.toLowerCase(),
    countryName: symbol,
    valueName: valueName ?? symbol,
    qty: qty,
    codeIso: symbol,
    symbol: symbol == 'PLN' ? 'zł' : '\$',
    flagImg: '',
    currencyValues: [
      CurrencyValue(
        id: '${symbol.toLowerCase()}-1',
        date: '01.01.2026',
        value: value.toString(),
      ),
    ],
  );
}
