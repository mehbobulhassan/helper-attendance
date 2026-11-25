import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:helper_attendance/features/attendance/presentation/providers/attendance_providers.dart';
import 'package:helper_attendance/features/attendance/presentation/screens/attendance_screen.dart';
import 'package:helper_attendance/features/workers/domain/entities/worker.dart';
import 'package:helper_attendance/features/workers/presentation/providers/workers_providers.dart';

import '../workers/fake_worker_repository.dart';
import 'fake_attendance_repository.dart';

Future<void> pumpAttendanceScreen(WidgetTester tester) async {
  // Phone-sized screen, so the whole calendar is on screen and tappable.
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
          FakeAttendanceRepository(),
        ),
      ],
      child: MaterialApp(
        home: AttendanceScreen(workerId: 1, today: DateTime(2026, 11, 25)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the worker, the month and every day', (tester) async {
    await pumpAttendanceScreen(tester);

    expect(find.text('Shazia'), findsOneWidget);
    expect(find.text('Rs 15,000 / month'), findsOneWidget);
    expect(find.text('November 2026'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
  });

  testWidgets('cannot go past the current month', (tester) async {
    await pumpAttendanceScreen(tester);

    final next = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.chevron_right),
    );
    expect(next.onPressed, isNull);
  });

  testWidgets('previous month shows October', (tester) async {
    await pumpAttendanceScreen(tester);

    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();

    expect(find.text('October 2026'), findsOneWidget);
  });

  testWidgets('marking a day absent shows its letter', (tester) async {
    await pumpAttendanceScreen(tester);

    await tester.tap(find.text('25'));
    await tester.pumpAndSettle();
    expect(find.text('Wednesday, 25 November'), findsOneWidget);

    await tester.tap(find.text('Absent'));
    await tester.pumpAndSettle();

    expect(find.text('Wednesday, 25 November'), findsNothing);
    expect(find.text('A'), findsOneWidget);
  });

  testWidgets('clearing a marked day makes it pending again', (tester) async {
    await pumpAttendanceScreen(tester);

    await tester.tap(find.text('25'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Absent'));
    await tester.pumpAndSettle();
    expect(find.text('A'), findsOneWidget);

    await tester.tap(find.text('25'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Unmarked (clear)'));
    await tester.pumpAndSettle();

    expect(find.text('A'), findsNothing);
  });

  testWidgets('future days cannot be marked', (tester) async {
    await pumpAttendanceScreen(tester);

    await tester.tap(find.text('26'));
    await tester.pumpAndSettle();

    expect(find.text('Thursday, 26 November'), findsNothing);
  });
}
