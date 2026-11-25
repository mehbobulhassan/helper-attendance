import '../../domain/entities/payment.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_local_data_source.dart';
import '../models/payment_model.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl(this._dataSource);
  final PaymentLocalDataSource _dataSource;

  @override
  Future<List<Payment>> getForMonth({
    required int workerId,
    required int year,
    required int month,
  }) =>
      _dataSource.getForMonth(workerId, year, month);

  @override
  Future<void> add(Payment payment) =>
      _dataSource.insert(PaymentModel.fromEntity(payment));

  @override
  Future<void> delete(int id) => _dataSource.delete(id);
}
