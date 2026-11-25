import '../../domain/entities/attendance.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_local_data_source.dart';
import '../models/attendance_model.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  AttendanceRepositoryImpl(this._dataSource);
  final AttendanceLocalDataSource _dataSource;

  @override
  Future<List<Attendance>> getForMonth({
    required int workerId,
    required int year,
    required int month,
  }) =>
      _dataSource.getForMonth(workerId, year, month);

  @override
  Future<void> setStatus({
    required int workerId,
    required DateTime date,
    AttendanceStatus? status,
  }) {
    if (status == null) return _dataSource.delete(workerId, date);
    return _dataSource.upsert(
      AttendanceModel(workerId: workerId, date: date, status: status),
    );
  }
}
