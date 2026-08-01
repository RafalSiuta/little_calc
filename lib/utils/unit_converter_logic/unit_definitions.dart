enum UnitCategory { area, length, temperature, volume, mass, data, time }

class UnitDefinition {
  const UnitDefinition({
    required this.symbol,
    required this.name,
    required this.toBase,
    this.fromBase,
  });

  final String symbol;
  final String name;
  final double Function(double value) toBase;
  final double Function(double value)? fromBase;

  double convertFromBase(double value) => fromBase?.call(value) ?? value / toBase(1);
}

class UnitDefinitions {
  const UnitDefinitions._();

  static const Map<UnitCategory, String> categoryNames = {
    UnitCategory.area: 'powierzchnia',
    UnitCategory.length: 'długość',
    UnitCategory.temperature: 'temperatura',
    UnitCategory.volume: 'objętość',
    UnitCategory.mass: 'masa',
    UnitCategory.data: 'dane',
    UnitCategory.time: 'czas',
  };

  static const Map<UnitCategory, String> listHeaderNames = {
    UnitCategory.area: 'Jednostki powierzchni',
    UnitCategory.length: 'Jednostki długości',
    UnitCategory.temperature: 'Jednostki temperatury',
    UnitCategory.volume: 'Jednostki objętości',
    UnitCategory.mass: 'Jednostki masy',
    UnitCategory.data: 'Jednostki danych',
    UnitCategory.time: 'Jednostki czasu',
  };

  static final Map<UnitCategory, List<UnitDefinition>> byCategory = {
    UnitCategory.area: [
      UnitDefinition(symbol: 'm²', name: 'metr kwadratowy', toBase: (v) => v),
      UnitDefinition(symbol: 'km²', name: 'kilometr kwadratowy', toBase: (v) => v * 1e6),
      UnitDefinition(symbol: 'cm²', name: 'centymetr kwadratowy', toBase: (v) => v / 1e4),
      UnitDefinition(symbol: 'ha', name: 'hektar', toBase: (v) => v * 10000),
      UnitDefinition(symbol: 'acre', name: 'akr', toBase: (v) => v * 4046.8564224),
      UnitDefinition(symbol: 'ft²', name: 'stopa kwadratowa', toBase: (v) => v * 0.09290304),
      UnitDefinition(symbol: 'in²', name: 'cal kwadratowy', toBase: (v) => v * 0.00064516),
    ],
    UnitCategory.length: [
      UnitDefinition(symbol: 'm', name: 'metr', toBase: (v) => v),
      UnitDefinition(symbol: 'km', name: 'kilometr', toBase: (v) => v * 1000),
      UnitDefinition(symbol: 'cm', name: 'centymetr', toBase: (v) => v / 100),
      UnitDefinition(symbol: 'mm', name: 'milimetr', toBase: (v) => v / 1000),
      UnitDefinition(symbol: 'mi', name: 'mila', toBase: (v) => v * 1609.344),
      UnitDefinition(symbol: 'yd', name: 'jard', toBase: (v) => v * 0.9144),
      UnitDefinition(symbol: 'ft', name: 'stopa', toBase: (v) => v * 0.3048),
      UnitDefinition(symbol: 'in', name: 'cal', toBase: (v) => v * 0.0254),
    ],
    UnitCategory.temperature: [
      UnitDefinition(symbol: '°C', name: 'Celsjusz', toBase: (v) => v, fromBase: (v) => v),
      UnitDefinition(symbol: '°F', name: 'Fahrenheit', toBase: (v) => (v - 32) * 5 / 9, fromBase: (v) => v * 9 / 5 + 32),
      UnitDefinition(symbol: 'K', name: 'kelwin', toBase: (v) => v - 273.15, fromBase: (v) => v + 273.15),
    ],
    UnitCategory.volume: [
      UnitDefinition(symbol: 'l', name: 'litr', toBase: (v) => v),
      UnitDefinition(symbol: 'ml', name: 'mililitr', toBase: (v) => v / 1000),
      UnitDefinition(symbol: 'm³', name: 'metr sześcienny', toBase: (v) => v * 1000),
      UnitDefinition(symbol: 'gal', name: 'galon amerykański', toBase: (v) => v * 3.785411784),
      UnitDefinition(symbol: 'qt', name: 'kwarta amerykańska', toBase: (v) => v * 0.946352946),
      UnitDefinition(symbol: 'pt', name: 'pinta amerykańska', toBase: (v) => v * 0.473176473),
      UnitDefinition(symbol: 'fl oz', name: 'uncja płynu', toBase: (v) => v * 0.0295735295625),
    ],
    UnitCategory.mass: [
      UnitDefinition(symbol: 'kg', name: 'kilogram', toBase: (v) => v),
      UnitDefinition(symbol: 'g', name: 'gram', toBase: (v) => v / 1000),
      UnitDefinition(symbol: 'mg', name: 'miligram', toBase: (v) => v / 1e6),
      UnitDefinition(symbol: 't', name: 'tona metryczna', toBase: (v) => v * 1000),
      UnitDefinition(symbol: 'lb', name: 'funt', toBase: (v) => v * 0.45359237),
      UnitDefinition(symbol: 'oz', name: 'uncja', toBase: (v) => v * 0.028349523125),
      UnitDefinition(symbol: 'st', name: 'kamień', toBase: (v) => v * 6.35029318),
    ],
    UnitCategory.data: [
      UnitDefinition(symbol: 'B', name: 'bajt', toBase: (v) => v),
      UnitDefinition(symbol: 'KB', name: 'kilobajt', toBase: (v) => v * 1000),
      UnitDefinition(symbol: 'MB', name: 'megabajt', toBase: (v) => v * 1e6),
      UnitDefinition(symbol: 'GB', name: 'gigabajt', toBase: (v) => v * 1e9),
      UnitDefinition(symbol: 'KiB', name: 'kibibajt', toBase: (v) => v * 1024),
      UnitDefinition(symbol: 'MiB', name: 'mebibajt', toBase: (v) => v * 1024 * 1024),
      UnitDefinition(symbol: 'GiB', name: 'gibibajt', toBase: (v) => v * 1024 * 1024 * 1024),
    ],
    UnitCategory.time: [
      UnitDefinition(symbol: 'ms', name: 'milisekunda', toBase: (v) => v / 1000),
      UnitDefinition(symbol: 's', name: 'sekunda', toBase: (v) => v),
      UnitDefinition(symbol: 'min', name: 'minuta', toBase: (v) => v * 60),
      UnitDefinition(symbol: 'h', name: 'godzina', toBase: (v) => v * 3600),
      UnitDefinition(symbol: 'd', name: 'dzień', toBase: (v) => v * 86400),
      UnitDefinition(symbol: 'wk', name: 'tydzień', toBase: (v) => v * 604800),
    ],
  };
}
