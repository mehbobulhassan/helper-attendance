import 'package:flutter_test/flutter_test.dart';
import 'package:helper_attendance/core/utils/date_format.dart';

void main() {
  test('monthYearLabel', () {
    expect(monthYearLabel(DateTime(2026, 11)), 'November 2026');
  });

  test('fullDateLabel', () {
    expect(fullDateLabel(DateTime(2026, 11, 25)), 'Wednesday, 25 November');
  });
}