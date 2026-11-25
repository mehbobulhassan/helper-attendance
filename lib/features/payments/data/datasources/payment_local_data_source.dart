import '../../../../core/database/app_database.dart';
import '../../../../core/utils/date_key.dart';
import '../models/payment_model.dart';

class PaymentLocalDataSource {
  PaymentLocalDataSource(this._appDb);
  final AppDatabase _appDb;

  Future<List<PaymentModel>> getForMonth(
      int workerId, int year, int month) async {
    final db = await _appDb.database;
    final (start, end) = monthRangeKeys(year, month);
    final rows = await db.query(
      'payments',
      where: 'worker_id = ? AND date >= ? AND date < ?',
      whereArgs: [workerId, start, end],
      orderBy: 'date',
    );
    return rows.map(PaymentModel.fromMap).toList();
  }

  Future<void> insert(PaymentModel payment) async {
    final db = await _appDb.database;
    await db.insert('payments', payment.toMap()..remove('id'));
  }

  Future<void> delete(int id) async {
    final db = await _appDb.database;
    await db.delete('payments', where: 'id = ?', whereArgs: [id]);
  }
}
