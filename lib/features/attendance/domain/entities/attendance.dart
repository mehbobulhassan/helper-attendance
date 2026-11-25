/// Stored as the enum index: 0 = present, 1 = absent, 2 = half-day.
/// An unmarked ("pending") day has no row at all.
enum AttendanceStatus { present, absent, halfDay }

class Attendance {
  final int? id;
  final int workerId;
  final DateTime date;
  final AttendanceStatus status;

  const Attendance({
    this.id,
    required this.workerId,
    required this.date,
    required this.status,
  });
}
