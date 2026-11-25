/// 15000 -> 'Rs 15,000'
String formatRs(int amount) {
  final digits = amount.abs().toString();
  final out = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
    out.write(digits[i]);
  }
  return 'Rs ${amount < 0 ? '-' : ''}$out';
}