import '../../../../core/utils/date_key.dart';
import '../../domain/entities/payment.dart';

class PaymentModel extends Payment {
  const PaymentModel({
    super.id,
    required super.workerId,
    required super.amount,
    required super.date,
    super.note,
  });

  factory PaymentModel.fromEntity(Payment p) => PaymentModel(
        id: p.id,
        workerId: p.workerId,
        amount: p.amount,
        date: p.date,
        note: p.note,
      );

  factory PaymentModel.fromMap(Map<String, Object?> m) => PaymentModel(
        id: m['id'] as int?,
        workerId: m['worker_id'] as int,
        amount: m['amount'] as int,
        date: parseDateKey(m['date'] as String),
        note: m['note'] as String?,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'worker_id': workerId,
        'amount': amount,
        'date': dateKey(date),
        'note': note,
      };
}
