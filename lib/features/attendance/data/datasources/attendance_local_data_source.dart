import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/utils/date_key.dart';
import '../models/attendance_model.dart';

class AttendanceLocalDataSource {
  AttendanceLocalDataSource(this._appDb);
  final AppDatabase _appDb;

  Future<List<AttendanceModel>> getForMonth(
      int workerId, int year, int month) async {
    final db = await _appDb.database;
    final (start, end) = monthRangeKeys(year, month);
    final rows = await db.query(
      'attendance',
      where: 'worker_id = ? AND date >= ? AND date < ?',
      whereArgs: [workerId, start, end],
      orderBy: 'date',
    );
    return rows.map(AttendanceModel.fromMap).toList();
  }

  /// UNIQUE (worker_id, date) + replace = one status per worker per day.
  Future<void> upsert(AttendanceModel m) async {
    final db = await _appDb.database;
    await db.insert(
      'attendance',
      m.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete(int workerId, DateTime date) async {
    final db = await _appDb.database;
    await db.delete(
      'attendance',
      where: 'worker_id = ? AND date = ?',
      whereArgs: [workerId, dateKey(date)],
    );
  }
}
