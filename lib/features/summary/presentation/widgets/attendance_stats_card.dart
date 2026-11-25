import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../attendance/domain/entities/attendance.dart';
import '../../../attendance/presentation/widgets/day_style.dart';
import '../../domain/entities/monthly_summary.dart';
import 'section_card.dart';

class AttendanceStatsCard extends StatelessWidget {
  const AttendanceStatsCard({super.key, required this.summary});

  final MonthlySummary summary;

  @override
  Widget build(BuildContext context) {
    final pending = summary.pending;

    return SectionCard(
      title: 'Attendance',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Stat(
                value: summary.present,
                label: 'Present',
                color: dayStyleFor(AttendanceStatus.present).foreground,
              ),
              _Stat(
                value: summary.absent,
                label: 'Absent',
                color: dayStyleFor(AttendanceStatus.absent).foreground,
              ),
              _Stat(
                value: summary.halfDays,
                label: 'Half-day',
                color: dayStyleFor(AttendanceStatus.halfDay).foreground,
              ),
              _Stat(
                value: summary.pending,
                label: 'Pending',
                color: AppColors.text,
              ),
            ],
          ),
          if (pending > 0) ...[
            const SizedBox(height: 10),
            Text(
              '$pending ${pending == 1 ? 'day is' : 'days are'} not marked yet. '
              'Pending days are not deducted.',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.color});

  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}