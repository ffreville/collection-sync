/// `1234.5` -> `"1 234,50 €"` — no `intl` dependency, just enough French
/// formatting for the estimated-value totals shown around the app.
String formatCurrency(double value) {
  final fixed = value.toStringAsFixed(2);
  final parts = fixed.split('.');
  final digits = parts[0].replaceFirst('-', '');
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(' ');
    buffer.write(digits[i]);
  }
  final sign = parts[0].startsWith('-') ? '-' : '';
  return '$sign${buffer.toString()},${parts[1]} €';
}
