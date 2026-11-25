import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/attendance.dart';

/// How a day looks for each status. null means unmarked (pending).
/// The letter means status is never shown by colour alone.
class DayStyle {
  const DayStyle({
    required this.background,
    required this.foreground,
    required this.border,
    this.letter,
  });

  final Color background;
  final Color foreground;
  final Color border;
  final String? letter;
}

DayStyle dayStyleFor(AttendanceStatus? status) => switch (status) {
      AttendanceStatus.present => const DayStyle(
          background: Color(0xFFDCFAE6),
          foreground: Color(0xFF14532D),
          border: Color(0xFF86D6A6),
          letter: 'P',
        ),
      AttendanceStatus.absent => const DayStyle(
          background: Color(0xFFFEE4E2),
          foreground: Color(0xFF912018),
          border: Color(0xFFFDA29B),
          letter: 'A',
        ),
      AttendanceStatus.halfDay => const DayStyle(
          background: Color(0xFFFEF0C7),
          foreground: Color(0xFF7A2E0E),
          border: Color(0xFFFEC84B),
          letter: 'H',
        ),
      null => const DayStyle(
          background: Colors.white,
          foreground: AppColors.text,
          border: AppColors.inputBorder,
        ),
    };

String statusLabel(AttendanceStatus? status) => switch (status) {
      AttendanceStatus.present => 'Present',
      AttendanceStatus.absent => 'Absent',
      AttendanceStatus.halfDay => 'Half-day',
      null => 'Unmarked',
    };