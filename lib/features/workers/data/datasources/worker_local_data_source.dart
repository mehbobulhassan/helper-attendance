import '../../../../core/database/app_database.dart';
import '../models/worker_model.dart';

class WorkerLocalDataSource {
  WorkerLocalDataSource(this._appDb);
  final AppDatabase _appDb;

  Future<List<WorkerModel>> getAll() async {
    final db = await _appDb.database;
    final rows = await db.query('workers', orderBy: 'name');
    return rows.map(WorkerModel.fromMap).toList();
  }

  Future<void> insert(WorkerModel worker) async {
    final db = await _appDb.database;
    await db.insert('workers', worker.toMap()..remove('id'));
  }

  Future<void> update(WorkerModel worker) async {
    final db = await _appDb.database;
    await db.update('workers', worker.toMap(),
        where: 'id = ?', whereArgs: [worker.id]);
  }

  Future<void> delete(int id) async {
    final db = await _appDb.database;
    await db.delete('workers', where: 'id = ?', whereArgs: [id]);
  }
}
