import 'package:helper_attendance/features/payments/domain/entities/payment.dart';
import 'package:helper_attendance/features/payments/domain/repositories/payment_repository.dart';

/// In-memory repository for tests.
class FakePaymentRepository implements PaymentRepository {
  FakePaymentRepository([List<Payment> initial = const []])
      : _payments = [...initial];

  final List<Payment> _payments;
  int _nextId = 100;

  @override
  Future<List<Payment>> getForMonth({
    required int workerId,
    required int year,
    required int month,
  }) async {
    return _payments
        .where((p) =>
            p.workerId == workerId &&
            p.date.year == year &&
            p.date.month == month)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  @override
  Future<void> add(Payment payment) async {
    _payments.add(Payment(
      id: _nextId++,
      workerId: payment.workerId,
      amount: payment.amount,
      date: payment.date,
      note: payment.note,
    ));
  }

  @override
  Future<void> delete(int id) async {
    _payments.removeWhere((p) => p.id == id);
  }
}