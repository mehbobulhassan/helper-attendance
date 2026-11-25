import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/utils/month_query.dart';
import '../../data/datasources/payment_local_data_source.dart';
import '../../data/repositories/payment_repository_impl.dart';
import '../../domain/entities/payment.dart';
import '../../domain/repositories/payment_repository.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepositoryImpl(
    PaymentLocalDataSource(ref.watch(appDatabaseProvider)),
  );
});

/// Payments made to one worker in one month.
final monthPaymentsProvider =
    FutureProvider.family<List<Payment>, MonthQuery>((ref, query) {
  return ref.watch(paymentRepositoryProvider).getForMonth(
        workerId: query.workerId,
        year: query.year,
        month: query.month,
      );
});

class PaymentController {
  PaymentController(this._ref);
  final Ref _ref;

  Future<void> add(
    MonthQuery query, {
    required int amount,
    required DateTime date,
    String? note,
  }) async {
    await _ref.read(paymentRepositoryProvider).add(Payment(
          workerId: query.workerId,
          amount: amount,
          date: date,
          note: (note == null || note.trim().isEmpty) ? null : note.trim(),
        ));
    _ref.invalidate(monthPaymentsProvider(query));
  }

  Future<void> remove(MonthQuery query, int paymentId) async {
    await _ref.read(paymentRepositoryProvider).delete(paymentId);
    _ref.invalidate(monthPaymentsProvider(query));
  }
}

final paymentControllerProvider =
    Provider<PaymentController>((ref) => PaymentController(ref));
