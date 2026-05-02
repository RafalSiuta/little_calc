String numberFormatter(
  double value, {
  int decimalPlaces = 10,
  bool useScientificNotation = true,
  double scientificNotationLargeThreshold = 1e12,
  double scientificNotationSmallThreshold = 1e-9,
}) {
  final places = decimalPlaces.clamp(0, 10).toInt();

  if (value.isNaN) {
    return 'NaN';
  }

  if (value.isInfinite) {
    return value.isNegative ? '-Infinity' : 'Infinity';
  }

  if (value == 0) {
    return '0';
  }

  final absoluteValue = value.abs();
  final shouldUseScientificNotation = useScientificNotation &&
      (absoluteValue >= scientificNotationLargeThreshold ||
          absoluteValue < scientificNotationSmallThreshold);

  if (shouldUseScientificNotation) {
    return _trimScientificNotation(value.toStringAsExponential(places));
  }

  return _trimFixedNotation(value.toStringAsFixed(places));
}

String _trimFixedNotation(String value) {
  if (!value.contains('.')) {
    return value;
  }

  return value
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}

String _trimScientificNotation(String value) {
  final parts = value.split('e');
  if (parts.length != 2) {
    return value;
  }

  final mantissa = _trimFixedNotation(parts.first);
  final exponent = int.tryParse(parts.last)?.toString() ?? parts.last;

  return '${mantissa}e$exponent';
}
