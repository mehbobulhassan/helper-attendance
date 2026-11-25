import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Opens the SQLite database and creates the tables.
/// Queries live in each feature's data source, not here.
class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  static Database? _db;

  Future<Database> get database async => _db ??= await _open();

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'helper_attendance.db');
    return openDatabase(
      path,
      version: 1,
      // SQLite ignores foreign keys unless this is switched on every time.
      // Without it, ON DELETE CASCADE does nothing.
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE workers (
        id             INTEGER PRIMARY KEY AUTOINCREMENT,
        name           TEXT    NOT NULL,
        monthly_salary INTEGER NOT NULL,
        created_at     TEXT    NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE attendance (
        id        INTEGER PRIMARY KEY AUTOINCREMENT,
        worker_id INTEGER NOT NULL
                  REFERENCES workers(id) ON DELETE CASCADE,
        date      TEXT    NOT NULL,
        status    INTEGER NOT NULL,
        UNIQUE (worker_id, date)
      )
    ''');
    await db.execute('''
      CREATE TABLE payments (
        id        INTEGER PRIMARY KEY AUTOINCREMENT,
        worker_id INTEGER NOT NULL
                  REFERENCES workers(id) ON DELETE CASCADE,
        amount    INTEGER NOT NULL,
        date      TEXT    NOT NULL,
        note      TEXT
      )
    ''');
  }
}

final appDatabaseProvider = Provider<AppDatabase>((ref) => AppDatabase.instance);
