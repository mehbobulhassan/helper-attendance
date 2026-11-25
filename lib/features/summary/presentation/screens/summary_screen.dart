import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/utils/month_query.dart';
import '../../../../core/utils/today_provider.dart';
import '../../../payments/domain/entities/payment.dart';
import '../../../payments/presentation/providers/payment_providers.dart';
import '../../../workers/domain/entities/worker.dart';
import '../../../workers/presentation/providers/workers_providers.dart';
import '../providers/summary_providers.dart';
import '../widgets/add_payment_sheet.dart';
import '../widgets/attendance_stats_card.dart';
import '../widgets/balance_card.dart';
import '../widgets/payments_card.dart';
import '../widgets/salary_card.dart';

class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({super.key, required this.query});

  final MonthQuery query;

  Worker? _findWorker(List<Worker> workers) {
    for (final w in workers) {
      if (w.id == query.workerId) return w;
    }
    return null;
  }

  void _openAddPayment(BuildContext context, WidgetRef ref) {
    final today = ref.read(todayProvider);
    final todayIsInMonth =
        today.year == query.year && today.month == query.month;
    // Default date: today when viewing the current month,
    // otherwise the last day of the month being viewed.
    final initialDate = todayIsInMonth
        ? DateTime(today.year, today.month, today.day)
        : DateTime(query.year, query.month + 1, 0);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (_) => AddPaymentSheet(query: query, initialDate: initialDate),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Payment payment,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete payment?'),
        content: Text(
          '${formatRs(payment.amount)} on ${shortDateLabel(payment.date)} '
          'will be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(paymentControllerProvider).remove(query, payment.id!);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final worker = _findWorker(ref.watch(workersProvider).value ?? const []);
    if (worker == null) return const Scaffold();

    final summary = ref.watch(monthlySummaryProvider(query));
    final payments = ref.watch(monthPaymentsProvider(query)).value;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              worker.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Text(
              monthYearLabel(DateTime(query.year, query.month)),
              style: const TextStyle(fontSize: 13, color: Color(0xFFD5F3EE)),
            ),
          ],
        ),
      ),
      body: summary.when(
        // Keep showing the old numbers while they recalculate.
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: OutlinedButton(
            onPressed: () => ref.invalidate(monthlySummaryProvider(query)),
            child: const Text('Could not load. Try again'),
          ),
        ),
        data: (s) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            BalanceCard(balance: s.balance),
            const SizedBox(height: 12),
            AttendanceStatsCard(summary: s),
            const SizedBox(height: 12),
            SalaryCard(summary: s),
            const SizedBox(height: 12),
            PaymentsCard(
              payments: payments ?? const <Payment>[],
              total: s.paid,
              onDelete: (p) => _confirmDelete(context, ref, p),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: OutlinedButton.icon(
            onPressed: () => _openAddPayment(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Add payment'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}