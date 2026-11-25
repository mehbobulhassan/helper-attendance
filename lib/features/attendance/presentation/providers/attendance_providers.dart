import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/utils/month_query.dart';
import '../../data/datasources/attendance_local_data_source.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../domain/entities/attendance.dart';
import '../../domain/repositories/attendance_repository.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepositoryImpl(
    AttendanceLocalDataSource(ref.watch(appDatabaseProvider)),
  );
});

/// Attendance records of one worker in one month (marked days only).
final monthAttendanceProvider =
    FutureProvider.family<List<Attendance>, MonthQuery>((ref, query) {
  return ref.watch(attendanceRepositoryProvider).getForMonth(
        workerId: query.workerId,
        year: query.year,
        month: query.month,
      );
});

/// Actions on attendance. After a change it refreshes the month, and every
/// provider that watches it (like the summary) updates on its own.
class AttendanceController {
  AttendanceController(this._ref);
  final Ref _ref;

  Future<void> setStatus(
    MonthQuery query,
    DateTime date,
    AttendanceStatus? status, // null = back to unmarked
  ) async {
    await _ref.read(attendanceRepositoryProvider).setStatus(
          workerId: query.workerId,
          date: date,
          status: status,
        );
    _ref.invalidate(monthAttendanceProvider(query));
  }
}

final attendanceControllerProvider =
    Provider<AttendanceController>((ref) => AttendanceController(ref));
