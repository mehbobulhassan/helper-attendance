import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/today_provider.dart';
import '../../../../core/utils/month_query.dart';
import '../../../attendance/presentation/providers/attendance_providers.dart';
import '../../../payments/presentation/providers/payment_providers.dart';
import '../../../workers/presentation/providers/workers_providers.dart';
import '../../domain/entities/monthly_summary.dart';
import '../../domain/usecases/calculate_monthly_summary.dart';

/// The monthly summary of one worker. It watches attendance and payments,
/// so it recalculates by itself whenever either changes.
final monthlySummaryProvider =
    FutureProvider.family<MonthlySummary, MonthQuery>((ref, query) async {
  final workers = await ref.watch(workersProvider.future);
  final worker = workers.firstWhere((w) => w.id == query.workerId);
  final attendance = await ref.watch(monthAttendanceProvider(query).future);
  final payments = await ref.watch(monthPaymentsProvider(query).future);

  return const CalculateMonthlySummary()(
    monthlySalary: worker.monthlySalary,
    year: query.year,
    month: query.month,
    attendance: attendance,
    payments: payments,
    today: ref.watch(todayProvider),
  );
});
