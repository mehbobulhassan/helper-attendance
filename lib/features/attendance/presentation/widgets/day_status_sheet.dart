import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/month_query.dart';
import '../../domain/entities/attendance.dart';
import '../providers/attendance_providers.dart';
import 'day_style.dart';

/// Bottom sheet to set one day's status. Choosing an option saves it
/// straight away and closes the sheet.
class DayStatusSheet extends ConsumerWidget {
  const DayStatusSheet({
    super.key,
    required this.query,
    required this.workerName,
    required this.date,
    required this.current,
  });

  final MonthQuery query;
  final String workerName;
  final DateTime date;
  final AttendanceStatus? current;

  Future<void> _select(
    BuildContext context,
    WidgetRef ref,
    AttendanceStatus? status,
  ) async {
    await ref.read(attendanceControllerProvider).setStatus(query, date, status);
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentText = current == null
        ? 'not marked yet'
        : 'marked ${statusLabel(current).toLowerCase()}';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fullDateLabel(date),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Text(
              '$workerName · $currentText',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            for (final status in AttendanceStatus.values) ...[
              _OptionTile(
                badge: _Badge(style: dayStyleFor(status)),
                label: statusLabel(status),
                selected: current == status,
                onTap: () => _select(context, ref, status),
              ),
              const SizedBox(height: 10),
            ],
            _OptionTile(
              badge: _Badge(style: dayStyleFor(null), letterOverride: '–'),
              label: 'Unmarked (clear)',
              selected: current == null,
              onTap: () => _select(context, ref, null),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.style, this.letterOverride});

  final DayStyle style;
  final String? letterOverride;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: style.border),
      ),
      child: Text(
        letterOverride ?? style.letter ?? '',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: style.foreground,
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.badge,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final Widget badge;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.inputBorder,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                badge,
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                ),
                if (selected)
                  const Icon(Icons.check, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}