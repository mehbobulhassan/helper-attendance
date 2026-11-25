import 'package:flutter_test/flutter_test.dart';
import 'package:helper_attendance/core/utils/format.dart';

void main() {
  test('formatRs adds thousand separators', () {
    expect(formatRs(0), 'Rs 0');
    expect(formatRs(500), 'Rs 500');
    expect(formatRs(15000), 'Rs 15,000');
    expect(formatRs(1250000), 'Rs 1,250,000');
  });
}
