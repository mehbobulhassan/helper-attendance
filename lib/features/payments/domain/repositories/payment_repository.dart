import '../entities/payment.dart';

abstract class PaymentRepository {
  Future<List<Payment>> getForMonth({
    required int workerId,
    required int year,
    required int month,
  });
  Future<void> add(Payment payment);
  Future<void> delete(int id);
}
