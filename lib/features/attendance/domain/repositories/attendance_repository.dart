import '../entities/attendance.dart';

abstract class AttendanceRepository {
  Future<List<Attendance>> getForMonth({
    required int workerId,
    required int year,
    required int month,
  });

  /// Pass a status to mark the day, or null to set it back to unmarked.
  Future<void> setStatus({
    required int workerId,
    required DateTime date,
    AttendanceStatus? status,
  });
}
