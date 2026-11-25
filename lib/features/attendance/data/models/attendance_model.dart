import '../../../../core/utils/date_key.dart';
import '../../domain/entities/attendance.dart';

class AttendanceModel extends Attendance {
  const AttendanceModel({
    super.id,
    required super.workerId,
    required super.date,
    required super.status,
  });

  factory AttendanceModel.fromMap(Map<String, Object?> m) => AttendanceModel(
        id: m['id'] as int?,
        workerId: m['worker_id'] as int,
        date: parseDateKey(m['date'] as String),
        status: AttendanceStatus.values[m['status'] as int],
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'worker_id': workerId,
        'date': dateKey(date),
        'status': status.index,
      };
}
