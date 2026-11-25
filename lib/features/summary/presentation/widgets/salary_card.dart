import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format.dart';
import '../../domain/entities/monthly_summary.dart';
import 'amount_row.dart';
import 'section_card.dart';

class SalaryCard extends StatelessWidget {
  const SalaryCard({super.key, required this.summary});

  final MonthlySummary summary;

  @override
  Widget build(BuildContext context) {
    // A half-day counts as 0.5 of a day.
    final deductedDays = summary.absent + summary.halfDays * 0.5;
    final daysText = deductedDays == deductedDays.roundToDouble()
        ? deductedDays.toInt().toString()
        : deductedDays.toStringAsFixed(1);
    final rateText =
        '${summary.monthlySalary % 30 == 0 ? '' : '≈ '}'
        '${formatRs((summary.monthlySalary / 30).round())}';

    return SectionCard(
      title: 'Salary',
      child: Column(
        children: [
          AmountRow(
            label: 'Monthly salary',
            value: formatRs(summary.monthlySalary),
          ),
          const SizedBox(height: 8),
          AmountRow(
            label: 'Deduction',
            detail: summary.deduction > 0
                ? '($daysText ${deductedDays == 1 ? 'day' : 'days'} × $rateText)'
                : null,
            value: '- ${formatRs(summary.deduction)}',
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 8),
          AmountRow(
            label: 'Earned',
            value: formatRs(summary.earned),
            bold: true,
          ),
        ],
      ),
    );
  }
}