import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:helper_attendance/core/utils/today_provider.dart';
import 'package:helper_attendance/features/attendance/domain/entities/attendance.dart';
import 'package:helper_attendance/features/attendance/presentation/providers/attendance_providers.dart';
import 'package:helper_attendance/features/payments/domain/entities/payment.dart';
import 'package:helper_attendance/features/payments/presentation/providers/payment_providers.dart';
import 'package:helper_attendance/features/summary/presentation/screens/summary_screen.dart';
import 'package:helper_attendance/features/workers/domain/entities/worker.dart';
import 'package:helper_attendance/features/workers/presentation/providers/workers_providers.dart';

import '../attendance/fake_attendance_repository.dart';
import '../payments/fake_payment_repository.dart';
import '../workers/fake_worker_repository.dart';

const _query = (workerId: 1, year: 2026, month: 11);

// Same numbers as the mockup: marked days 1-23 of November 2026,
// absent on 4 and 15, half-day on 7 and 22, days 24 and 25 still pending.
List<Attendance> _novemberAttendance() {
  const absentDays = {4, 15};
  const halfDays = {7, 22};
  return [
    for (var day = 1; day <= 23; day++)
      Attendance(
        workerId: 1,
        date: DateTime(2026, 11, day),
        status: absentDays.contains(day)
            ? AttendanceStatus.absent
            : halfDays.contains(day)
                ? AttendanceStatus.halfDay
                : AttendanceStatus.present,
      ),
  ];
}

List<Payment> _defaultPayments() => [
      Payment(
        id: 1,
        workerId: 1,
        amount: 3000,
        date: DateTime(2026, 11, 5),
        note: 'Advance',
      ),
      Payment(
        id: 2,
        workerId: 1,
        amount: 5000,
        date: DateTime(2026, 11, 20),
      ),
    ];

Future<void> pumpSummaryScreen(
  WidgetTester tester, {
  List<Payment>? payments,
}) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  final workers = FakeWorkerRepository([
    Worker(
      id: 1,
      name: 'Shazia',
      monthlySalary: 15000,
      createdAt: DateTime(2026, 1, 1),
    ),
  ]);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        workerRepositoryProvider.overrideWithValue(workers),
        attendanceRepositoryProvider.overrideWithValue(
          FakeAttendanceRepository(_novemberAttendance()),
        ),
        paymentRepositoryProvider.overrideWithValue(
          FakePaymentRepository(payments ?? _defaultPayments()),
        ),
        todayProvider.overrideWithValue(DateTime(2026, 11, 25)),
      ],
      child: const MaterialApp(home: SummaryScreen(query: _query)),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the numbers from the mockup', (tester) async {
    await pumpSummaryScreen(tester);

    expect(find.text('Rs 5,500'), findsOneWidget); // balance due
    expect(find.text('Rs 15,000'), findsOneWidget); // monthly salary
    expect(find.text('- Rs 1,500'), findsOneWidget); // deduction
    expect(find.text('Rs 13,500'), findsOneWidget); // earned
    expect(find.text('Rs 8,000'), findsOneWidget); // total paid
    expect(
      find.text('2 days are not marked yet. Pending days are not deducted.'),
      findsOneWidget,
    );
  });

  testWidgets('lists the payments of the month', (tester) async {
    await pumpSummaryScreen(tester);

    expect(find.text('5 Nov'), findsOneWidget);
    expect(find.text('Advance'), findsOneWidget);
    expect(find.text('Rs 3,000'), findsOneWidget);
    expect(find.text('20 Nov'), findsOneWidget);
    expect(find.text('Rs 5,000'), findsNWidgets(1));
  });

  testWidgets('adding a payment updates the balance', (tester) async {
    await pumpSummaryScreen(tester);

    await tester.tap(find.text('Add payment'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('amountField')), '1000');
    await tester.tap(find.text('Save payment'));
    await tester.pumpAndSettle();

    expect(find.text('Rs 4,500'), findsOneWidget); // balance: 13,500 - 9,000
    expect(find.text('Rs 9,000'), findsOneWidget); // total paid
  });

  testWidgets('deleting a payment updates the balance', (tester) async {
    await pumpSummaryScreen(tester);

    await tester.tap(find.byTooltip('Delete payment').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Rs 3,000'), findsNothing);
    expect(find.text('Rs 8,500'), findsOneWidget); // balance: 13,500 - 5,000
  });

  testWidgets('says so when more was paid than earned', (tester) async {
    await pumpSummaryScreen(tester, payments: [
      Payment(
        id: 1,
        workerId: 1,
        amount: 20000,
        date: DateTime(2026, 11, 10),
      ),
    ]);

    expect(find.text('Paid in excess'), findsOneWidget);
    expect(find.text('Rs 6,500'), findsOneWidget); // 20,000 - 13,500
  });
}