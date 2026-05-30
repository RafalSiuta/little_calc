class Currency {
  const Currency({
    required this.id,
    required this.countryName,
    required this.valueName,
    required this.qty,
    required this.symbol,
    required this.flagImg,
    required this.currencyValues,
  });

  final String id;
  final String countryName;
  final String valueName;
  final int qty;
  final String symbol;
  final String flagImg;
  final List<CurrencyValue> currencyValues;

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      id: json['id'] as String? ?? '',
      countryName: json['country_name'] as String? ?? '',
      valueName: json['value_name'] as String? ?? '',
      qty: json['qty'] as int? ?? 1,
      symbol: json['symbol'] as String? ?? '',
      flagImg: json['flag_img'] as String? ?? '',
      currencyValues: (json['currency_values'] as List<dynamic>? ?? [])
          .map((item) => CurrencyValue.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'country_name': countryName,
      'value_name': valueName,
      'qty': qty,
      'symbol': symbol,
      'flag_img': flagImg,
      'currency_values': [
        for (final value in currencyValues) value.toJson(),
      ],
    };
  }
}

class CurrencyValue {
  const CurrencyValue({
    required this.id,
    required this.date,
    required this.value,
  });

  final String id;
  final String date;
  final String value;

  double get numericValue {
    return double.tryParse(value.replaceAll(',', '.')) ?? 0;
  }

  factory CurrencyValue.fromJson(Map<String, dynamic> json) {
    return CurrencyValue(
      id: json['id'] as String? ?? '',
      date: json['date'] as String? ?? '',
      value: json['value'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'value': value,
    };
  }
}
