import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/utils/month_query.dart';
import '../../../workers/domain/entities/worker.dart';
import '../../../workers/presentation/providers/workers_providers.dart';
import '../../../workers/presentation/screens/worker_form_screen.dart';
import '../../domain/entities/attendance.dart';
import '../providers/attendance_providers.dart';
import '../widgets/calendar_grid.dart';
import '../widgets/day_status_sheet.dart';
import '../widgets/month_switcher.dart';
import '../widgets/status_legend.dart';
import '../../../summary/presentation/screens/summary_screen.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  /// [today] is only for tests. Normally it is DateTime.now().
  const AttendanceScreen({super.key, required this.workerId, this.today});

  final int workerId;
  final DateTime? today;

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  late final DateTime _today = widget.today ?? DateTime.now();
  late DateTime _month = DateTime(_today.year, _today.month);

  bool get _isCurrentMonth =>
      _month.year == _today.year && _month.month == _today.month;

  void _changeMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta));
  }

  void _openDaySheet(
    Worker worker,
    MonthQuery query,
    DateTime date,
    AttendanceStatus? current,
  ) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (_) => DayStatusSheet(
        query: query,
        workerName: worker.name,
        date: date,
        current: current,
      ),
    );
  }

  Worker? _findWorker(List<Worker> workers) {
    for (final w in workers) {
      if (w.id == widget.workerId) return w;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Watching the list (not a copied Worker) means an edit made in the form
    // shows up here straight away.
    final worker = _findWorker(ref.watch(workersProvider).value ?? const []);
    if (worker == null) return const Scaffold();

    final query = (
      workerId: worker.id!,
      year: _month.year,
      month: _month.month,
    );
    final attendance = ref.watch(monthAttendanceProvider(query));

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
              '${formatRs(worker.monthlySalary)} / month',
              style: const TextStyle(fontSize: 13, color: Color(0xFFD5F3EE)),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Edit worker',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => WorkerFormScreen(worker: worker),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          MonthSwitcher(
            month: _month,
            canGoNext: !_isCurrentMonth,
            onPrevious: () => _changeMonth(-1),
            onNext: () => _changeMonth(1),
          ),
          const SizedBox(height: 8),
          attendance.when(
            skipLoadingOnReload: true,
            loading: () => const SizedBox(
              height: 320,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => SizedBox(
              height: 320,
              child: Center(
                child: OutlinedButton(
                  onPressed: () =>
                      ref.invalidate(monthAttendanceProvider(query)),
                  child: const Text('Could not load. Try again'),
                ),
              ),
            ),
            data: (records) => CalendarGrid(
              year: _month.year,
              month: _month.month,
              today: _today,
              statusByDay: {for (final a in records) a.date.day: a.status},
              onDayTap: (date) {
                final current = records
                    .where((a) => a.date.day == date.day)
                    .map((a) => a.status)
                    .firstOrNull;
                _openDaySheet(worker, query, date, current);
              },
            ),
          ),
          const SizedBox(height: 16),
          const StatusLegend(),
          const SizedBox(height: 12),
          const Text(
            'Tap a day to set its status.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => SummaryScreen(query: query)),
            ),
            child: const Text('View monthly summary'),
          ),
        ),
      ),
    );
  }
}
