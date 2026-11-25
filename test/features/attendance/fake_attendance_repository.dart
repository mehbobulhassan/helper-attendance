import 'package:helper_attendance/core/utils/date_key.dart';
import 'package:helper_attendance/features/attendance/domain/entities/attendance.dart';
import 'package:helper_attendance/features/attendance/domain/repositories/attendance_repository.dart';

/// In-memory repository for tests. One record per worker per day.
class FakeAttendanceRepository implements AttendanceRepository {
  FakeAttendanceRepository([List<Attendance> initial = const []]) {
    for (final a in initial) {
      _records[_key(a.workerId, a.date)] = a;
    }
  }

  final Map<String, Attendance> _records = {};

  String _key(int workerId, DateTime date) => '$workerId-${dateKey(date)}';

  @override
  Future<List<Attendance>> getForMonth({
    required int workerId,
    required int year,
    required int month,
  }) async {
    return _records.values
        .where((a) =>
            a.workerId == workerId &&
            a.date.year == year &&
            a.date.month == month)
        .toList();
  }

  @override
  Future<void> setStatus({
    required int workerId,
    required DateTime date,
    AttendanceStatus? status,
  }) async {
    final key = _key(workerId, date);
    if (status == null) {
      _records.remove(key);
    } else {
      _records[key] = Attendance(
        workerId: workerId,
        date: DateTime(date.year, date.month, date.day),
        status: status,
      );
    }
  }
}