import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../data/datasources/worker_local_data_source.dart';
import '../../data/repositories/worker_repository_impl.dart';
import '../../domain/entities/worker.dart';
import '../../domain/repositories/worker_repository.dart';

// Wiring: the only place where the domain interface meets its implementation.
final workerRepositoryProvider = Provider<WorkerRepository>((ref) {
  return WorkerRepositoryImpl(
    WorkerLocalDataSource(ref.watch(appDatabaseProvider)),
  );
});

/// The list of workers, plus the actions that change it.
final workersProvider =
    AsyncNotifierProvider<WorkersNotifier, List<Worker>>(WorkersNotifier.new);

class WorkersNotifier extends AsyncNotifier<List<Worker>> {
  WorkerRepository get _repo => ref.read(workerRepositoryProvider);

  @override
  Future<List<Worker>> build() => _repo.getWorkers();

  Future<void> add({required String name, required int monthlySalary}) async {
    await _repo.addWorker(Worker(
      name: name,
      monthlySalary: monthlySalary,
      createdAt: DateTime.now(),
    ));
    await _reload();
  }

  Future<void> edit(Worker worker) async {
    await _repo.updateWorker(worker);
    await _reload();
  }

  Future<void> remove(int id) async {
    await _repo.deleteWorker(id);
    await _reload();
  }

  Future<void> _reload() async {
    state = await AsyncValue.guard(_repo.getWorkers);
  }
}
