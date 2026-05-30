import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/currency_model/currency.dart';

class CurrenciesProvider extends ChangeNotifier {
  CurrenciesProvider() {
    loadCurrencies();
  }

  static const String currenciesAssetPath = 'assets/data/flags.json';
  static const String flagsAssetDir = 'assets/data/';

  List<Currency> _dummyCurrencies = [];
  Currency? _baseCurrency;
  Currency? _targetCurrency;
  bool _isLoading = false;
  String? _errorMessage;

  List<Currency> get currencies => List.unmodifiable(_dummyCurrencies);
  Currency? get baseCurrency => _baseCurrency;
  Currency? get targetCurrency => _targetCurrency;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadCurrencies({
    String assetPath = currenciesAssetPath,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final source = await rootBundle.loadString(assetPath);
      final currencies = parseCurrencies(source);
      _setCurrencies(currencies);
    } catch (error) {
      _errorMessage = error.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Currency> parseCurrencies(String source) {
    final decoded = jsonDecode(source) as Map<String, dynamic>;
    final items = decoded['flags_list'] as List<dynamic>? ?? [];

    return items
        .map((item) => Currency.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  String flagAssetPath(Currency currency) {
    return '$flagsAssetDir${currency.flagImg}';
  }

  void setBaseCurrency(Currency currency) {
    if (_baseCurrency?.symbol == currency.symbol) {
      return;
    }

    _baseCurrency = currency;
    notifyListeners();
  }

  void setTargetCurrency(Currency currency) {
    if (_targetCurrency?.symbol == currency.symbol) {
      return;
    }

    _targetCurrency = currency;
    notifyListeners();
  }

  Currency? findBySymbol(String symbol) {
    for (final currency in _dummyCurrencies) {
      if (currency.symbol == symbol) {
        return currency;
      }
    }

    return null;
  }

  void _setCurrencies(List<Currency> currencies) {
    _dummyCurrencies = List.unmodifiable(currencies);
    _baseCurrency = findBySymbol('USD') ??
        (_dummyCurrencies.isNotEmpty ? _dummyCurrencies.first : null);
    _targetCurrency = findBySymbol('PLN') ??
        findBySymbol('EUR') ??
        (_dummyCurrencies.length > 1 ? _dummyCurrencies[1] : _baseCurrency);
    _isLoading = false;
    notifyListeners();
  }
}
