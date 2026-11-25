import 'package:flutter_test/flutter_test.dart';
import 'package:helper_attendance/features/attendance/domain/entities/attendance.dart';
import 'package:helper_attendance/features/payments/domain/entities/payment.dart';
import 'package:helper_attendance/features/summary/domain/usecases/calculate_monthly_summary.dart';

void main() {
  const calculate = CalculateMonthlySummary();
  const salary = 15000;

  // Same numbers as the mockup: marked days 1-23 of November 2026,
  // absent on 4 and 15, half-day on 7 and 22, days 24 and 25 still pending.
  List<Attendance> novemberRecords() {
    const absentDays = {4, 15};
    const halfDays = {7, 22};
    return [
      for (var day = 1; day <= 23; day++)
        Attendance(
          workerId: 1,
          date: DateTime(2026, 11, day),
          status: absentDays.contains(day)
              ? AttendanceStatus.absent
              : halfDays.contains(day)
                  ? AttendanceStatus.halfDay
                  : AttendanceStatus.present,
        ),
    ];
  }

  final payments = [
    Payment(workerId: 1, amount: 3000, date: DateTime(2026, 11, 5), note: 'Advance'),
    Payment(workerId: 1, amount: 5000, date: DateTime(2026, 11, 20)),
  ];

  test('matches the mockup numbers', () {
    final s = calculate(
      monthlySalary: salary,
      year: 2026,
      month: 11,
      attendance: novemberRecords(),
      payments: payments,
      today: DateTime(2026, 11, 25),
    );
    expect(s.present, 19);
    expect(s.absent, 2);
    expect(s.halfDays, 2);
    expect(s.pending, 2);
    expect(s.deduction, 1500); // 3 days x Rs 500
    expect(s.earned, 13500);
    expect(s.paid, 8000);
    expect(s.balance, 5500);
  });

  test('pending days are not deducted', () {
    final s = calculate(
      monthlySalary: salary,
      year: 2026,
      month: 11,
      attendance: const [],
      payments: const [],
      today: DateTime(2026, 11, 25),
    );
    expect(s.pending, 25);
    expect(s.deduction, 0);
    expect(s.earned, 15000);
  });

  test('past month counts every unmarked day as pending', () {
    final s = calculate(
      monthlySalary: salary,
      year: 2026,
      month: 10,
      attendance: const [],
      payments: const [],
      today: DateTime(2026, 11, 25),
    );
    expect(s.pending, 31);
  });

  test('earned never goes below zero', () {
    final all31Absent = [
      for (var d = 1; d <= 31; d++)
        Attendance(
          workerId: 1,
          date: DateTime(2026, 10, d),
          status: AttendanceStatus.absent,
        ),
    ];
    final s = calculate(
      monthlySalary: salary,
      year: 2026,
      month: 10,
      attendance: all31Absent,
      payments: const [],
      today: DateTime(2026, 11, 25),
    );
    expect(s.earned, 0);
  });
}
