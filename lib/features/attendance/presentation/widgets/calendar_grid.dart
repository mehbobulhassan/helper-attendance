import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/date_key.dart';
import '../../domain/entities/attendance.dart';
import 'day_style.dart';

/// Month grid, Monday first. Unmarked days show no letter, and days after
/// [today] are greyed out and cannot be tapped.
class CalendarGrid extends StatelessWidget {
  const CalendarGrid({
    super.key,
    required this.year,
    required this.month,
    required this.statusByDay,
    required this.today,
    required this.onDayTap,
  });

  final int year;
  final int month;
  final Map<int, AttendanceStatus> statusByDay;
  final DateTime today;
  final void Function(DateTime date) onDayTap;

  static const _weekdayLetters = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    // DateTime.weekday: Monday = 1 ... Sunday = 7.
    final leadingBlanks = DateTime(year, month, 1).weekday - 1;
    final dayCount = daysInMonth(year, month);
    final todayDate = DateTime(today.year, today.month, today.day);

    return Column(
      children: [
        Row(
          children: [
            for (final label in _weekdayLetters)
              Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 7,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (var i = 0; i < leadingBlanks; i++) const SizedBox.shrink(),
            for (var day = 1; day <= dayCount; day++)
              _DayCell(
                date: DateTime(year, month, day),
                status: statusByDay[day],
                isToday: DateTime(year, month, day) == todayDate,
                isFuture: DateTime(year, month, day).isAfter(todayDate),
                onTap: onDayTap,
              ),
          ],
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.status,
    required this.isToday,
    required this.isFuture,
    required this.onTap,
  });

  final DateTime date;
  final AttendanceStatus? status;
  final bool isToday;
  final bool isFuture;
  final void Function(DateTime date) onTap;

  @override
  Widget build(BuildContext context) {
    if (isFuture) {
      return Center(
        child: Text(
          '${date.day}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF98A2B3),
          ),
        ),
      );
    }

    final style = dayStyleFor(status);

    return Semantics(
      button: true,
      label: '${fullDateLabel(date)}, ${statusLabel(status).toLowerCase()}',
      excludeSemantics: true,
      child: Material(
        color: style.background,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isToday ? AppColors.primary : style.border,
            width: isToday ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: () => onTap(date),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: style.foreground,
                ),
              ),
              if (style.letter != null)
                Text(
                  style.letter!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: style.foreground,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}