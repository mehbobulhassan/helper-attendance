import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/attendance.dart';
import 'day_style.dart';

class StatusLegend extends StatelessWidget {
  const StatusLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 14,
      runSpacing: 8,
      children: [
        _LegendItem(status: AttendanceStatus.present, label: 'P Present'),
        _LegendItem(status: AttendanceStatus.absent, label: 'A Absent'),
        _LegendItem(status: AttendanceStatus.halfDay, label: 'H Half-day'),
        _LegendItem(status: null, label: 'Pending'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.status, required this.label});

  final AttendanceStatus? status;
  final String label;

  @override
  Widget build(BuildContext context) {
    final style = dayStyleFor(status);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: style.background,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: style.border),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}