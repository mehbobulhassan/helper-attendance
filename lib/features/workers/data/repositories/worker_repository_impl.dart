import '../../domain/entities/worker.dart';
import '../../domain/repositories/worker_repository.dart';
import '../datasources/worker_local_data_source.dart';
import '../models/worker_model.dart';

class WorkerRepositoryImpl implements WorkerRepository {
  WorkerRepositoryImpl(this._dataSource);
  final WorkerLocalDataSource _dataSource;

  @override
  Future<List<Worker>> getWorkers() => _dataSource.getAll();

  @override
  Future<void> addWorker(Worker worker) =>
      _dataSource.insert(WorkerModel.fromEntity(worker));

  @override
  Future<void> updateWorker(Worker worker) =>
      _dataSource.update(WorkerModel.fromEntity(worker));

  @override
  Future<void> deleteWorker(int id) => _dataSource.delete(id);
}
