import '../entities/worker.dart';

abstract class WorkerRepository {
  Future<List<Worker>> getWorkers();
  Future<void> addWorker(Worker worker);
  Future<void> updateWorker(Worker worker);

  /// Also deletes the worker's attendance and payments (ON DELETE CASCADE).
  Future<void> deleteWorker(int id);
}
