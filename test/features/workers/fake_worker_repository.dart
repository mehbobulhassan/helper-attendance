import 'package:helper_attendance/features/workers/domain/entities/worker.dart';
import 'package:helper_attendance/features/workers/domain/repositories/worker_repository.dart';

/// In-memory repository for tests: no SQLite needed. This works because the
/// screens depend on the WorkerRepository interface, not on the database.
class FakeWorkerRepository implements WorkerRepository {
  FakeWorkerRepository([List<Worker> initial = const []])
      : _workers = [...initial];

  final List<Worker> _workers;
  int _nextId = 100;

  @override
  Future<List<Worker>> getWorkers() async =>
      [..._workers]..sort((a, b) => a.name.compareTo(b.name));

  @override
  Future<void> addWorker(Worker worker) async {
    _workers.add(Worker(
      id: _nextId++,
      name: worker.name,
      monthlySalary: worker.monthlySalary,
      createdAt: worker.createdAt,
    ));
  }

  @override
  Future<void> updateWorker(Worker worker) async {
    final index = _workers.indexWhere((w) => w.id == worker.id);
    if (index != -1) _workers[index] = worker;
  }

  @override
  Future<void> deleteWorker(int id) async {
    _workers.removeWhere((w) => w.id == id);
  }
}
