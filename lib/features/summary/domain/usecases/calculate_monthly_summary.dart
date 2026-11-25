import '../../../../core/utils/date_key.dart';
import '../../../attendance/domain/entities/attendance.dart';
import '../../../payments/domain/entities/payment.dart';
import '../entities/monthly_summary.dart';

/// Rules:
/// - daily rate = monthly salary / 30 (fixed, whatever the month length)
/// - deduction  = daily rate x (absent + 0.5 x half-days)
/// - pending (unmarked) days are never deducted
/// - earned     = salary - deduction (never below 0)
/// - balance    = earned - payments made in that month
///
/// A plain class with no Flutter, Riverpod or SQLite in it, so it is
/// easy to test.
class CalculateMonthlySummary {
  const CalculateMonthlySummary();

  MonthlySummary call({
    required int monthlySalary,
    required int year,
    required int month,
    required List<Attendance> attendance,
    required List<Payment> payments,
    required DateTime today,
  }) {
    var present = 0, absent = 0, half = 0;
    for (final a in attendance) {
      switch (a.status) {
        case AttendanceStatus.present:
          present++;
        case AttendanceStatus.absent:
          absent++;
        case AttendanceStatus.halfDay:
          half++;
      }
    }

    // Days that can still be marked: up to today for the current month,
    // the whole month for past months, none for future months.
    final int daysCounted;
    if (year == today.year && month == today.month) {
      daysCounted = today.day;
    } else if (DateTime(year, month)
        .isBefore(DateTime(today.year, today.month))) {
      daysCounted = daysInMonth(year, month);
    } else {
      daysCounted = 0;
    }
    final markedInRange =
        attendance.where((a) => a.date.day <= daysCounted).length;
    final pending = (daysCounted - markedInRange).clamp(0, 31);

    // Integer maths: salary / 30 x (absent + half / 2)
    //              = salary x (2 x absent + half) / 60
    final deduction = (monthlySalary * (2 * absent + half) / 60).round();
    final earned = (monthlySalary - deduction).clamp(0, monthlySalary);
    final paid = payments.fold<int>(0, (sum, p) => sum + p.amount);

    return MonthlySummary(
      present: present,
      absent: absent,
      halfDays: half,
      pending: pending,
      monthlySalary: monthlySalary,
      deduction: deduction,
      earned: earned,
      paid: paid,
      balance: earned - paid,
    );
  }
}
