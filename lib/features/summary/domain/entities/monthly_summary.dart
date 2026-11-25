/// Never stored. Always calculated from salary, attendance and payments.
class MonthlySummary {
  final int present;
  final int absent;
  final int halfDays;
  final int pending;
  final int monthlySalary;
  final int deduction;
  final int earned;
  final int paid;
  final int balance;

  const MonthlySummary({
    required this.present,
    required this.absent,
    required this.halfDays,
    required this.pending,
    required this.monthlySalary,
    required this.deduction,
    required this.earned,
    required this.paid,
    required this.balance,
  });
}
