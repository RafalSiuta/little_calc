enum UnitCategory { area, length, temperature, volume, mass, data, time }

class UnitDefinition {
  const UnitDefinition({
    required this.symbol,
    required this.id,
    required this.toBase,
    this.fromBase,
  });

  final String symbol;
  final String id;
  final double Function(double value) toBase;
  final double Function(double value)? fromBase;

  double convertFromBase(double value) =>
      fromBase?.call(value) ?? value / toBase(1);
}

class UnitDefinitions {
  const UnitDefinitions._();

  static final Map<UnitCategory, List<UnitDefinition>> byCategory = {
    UnitCategory.area: [
      UnitDefinition(symbol: 'm²', id: 'square_meter', toBase: (v) => v),
      UnitDefinition(
        symbol: 'km²',
        id: 'square_kilometer',
        toBase: (v) => v * 1e6,
      ),
      UnitDefinition(
        symbol: 'cm²',
        id: 'square_centimeter',
        toBase: (v) => v / 1e4,
      ),
      UnitDefinition(symbol: 'ha', id: 'hectare', toBase: (v) => v * 10000),
      UnitDefinition(
        symbol: 'acre',
        id: 'acre',
        toBase: (v) => v * 4046.8564224,
      ),
      UnitDefinition(
        symbol: 'ft²',
        id: 'square_foot',
        toBase: (v) => v * 0.09290304,
      ),
      UnitDefinition(
        symbol: 'in²',
        id: 'square_inch',
        toBase: (v) => v * 0.00064516,
      ),
    ],
    UnitCategory.length: [
      UnitDefinition(symbol: 'm', id: 'meter', toBase: (v) => v),
      UnitDefinition(symbol: 'km', id: 'kilometer', toBase: (v) => v * 1000),
      UnitDefinition(symbol: 'cm', id: 'centimeter', toBase: (v) => v / 100),
      UnitDefinition(symbol: 'mm', id: 'millimeter', toBase: (v) => v / 1000),
      UnitDefinition(symbol: 'mi', id: 'mile', toBase: (v) => v * 1609.344),
      UnitDefinition(symbol: 'yd', id: 'yard', toBase: (v) => v * 0.9144),
      UnitDefinition(symbol: 'ft', id: 'foot', toBase: (v) => v * 0.3048),
      UnitDefinition(symbol: 'in', id: 'inch', toBase: (v) => v * 0.0254),
    ],
    UnitCategory.temperature: [
      UnitDefinition(
        symbol: '°C',
        id: 'celsius',
        toBase: (v) => v,
        fromBase: (v) => v,
      ),
      UnitDefinition(
        symbol: '°F',
        id: 'fahrenheit',
        toBase: (v) => (v - 32) * 5 / 9,
        fromBase: (v) => v * 9 / 5 + 32,
      ),
      UnitDefinition(
        symbol: 'K',
        id: 'kelvin',
        toBase: (v) => v - 273.15,
        fromBase: (v) => v + 273.15,
      ),
    ],
    UnitCategory.volume: [
      UnitDefinition(symbol: 'l', id: 'liter', toBase: (v) => v),
      UnitDefinition(symbol: 'ml', id: 'milliliter', toBase: (v) => v / 1000),
      UnitDefinition(symbol: 'm³', id: 'cubic_meter', toBase: (v) => v * 1000),
      UnitDefinition(
        symbol: 'gal',
        id: 'us_gallon',
        toBase: (v) => v * 3.785411784,
      ),
      UnitDefinition(
        symbol: 'qt',
        id: 'us_quart',
        toBase: (v) => v * 0.946352946,
      ),
      UnitDefinition(
        symbol: 'pt',
        id: 'us_pint',
        toBase: (v) => v * 0.473176473,
      ),
      UnitDefinition(
        symbol: 'fl oz',
        id: 'us_fluid_ounce',
        toBase: (v) => v * 0.0295735295625,
      ),
    ],
    UnitCategory.mass: [
      UnitDefinition(symbol: 'kg', id: 'kilogram', toBase: (v) => v),
      UnitDefinition(symbol: 'g', id: 'gram', toBase: (v) => v / 1000),
      UnitDefinition(symbol: 'mg', id: 'milligram', toBase: (v) => v / 1e6),
      UnitDefinition(symbol: 't', id: 'tonne', toBase: (v) => v * 1000),
      UnitDefinition(symbol: 'lb', id: 'pound', toBase: (v) => v * 0.45359237),
      UnitDefinition(
        symbol: 'oz',
        id: 'ounce',
        toBase: (v) => v * 0.028349523125,
      ),
      UnitDefinition(symbol: 'st', id: 'stone', toBase: (v) => v * 6.35029318),
    ],
    UnitCategory.data: [
      UnitDefinition(symbol: 'B', id: 'byte', toBase: (v) => v),
      UnitDefinition(symbol: 'KB', id: 'kilobyte', toBase: (v) => v * 1000),
      UnitDefinition(symbol: 'MB', id: 'megabyte', toBase: (v) => v * 1e6),
      UnitDefinition(symbol: 'GB', id: 'gigabyte', toBase: (v) => v * 1e9),
      UnitDefinition(symbol: 'KiB', id: 'kibibyte', toBase: (v) => v * 1024),
      UnitDefinition(
        symbol: 'MiB',
        id: 'mebibyte',
        toBase: (v) => v * 1024 * 1024,
      ),
      UnitDefinition(
        symbol: 'GiB',
        id: 'gibibyte',
        toBase: (v) => v * 1024 * 1024 * 1024,
      ),
    ],
    UnitCategory.time: [
      UnitDefinition(symbol: 'ms', id: 'millisecond', toBase: (v) => v / 1000),
      UnitDefinition(symbol: 's', id: 'second', toBase: (v) => v),
      UnitDefinition(symbol: 'min', id: 'minute', toBase: (v) => v * 60),
      UnitDefinition(symbol: 'h', id: 'hour', toBase: (v) => v * 3600),
      UnitDefinition(symbol: 'd', id: 'day', toBase: (v) => v * 86400),
      UnitDefinition(symbol: 'wk', id: 'week', toBase: (v) => v * 604800),
    ],
  };
}
