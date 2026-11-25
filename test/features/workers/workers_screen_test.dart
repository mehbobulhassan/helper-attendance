import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:helper_attendance/features/workers/domain/entities/worker.dart';
import 'package:helper_attendance/features/workers/presentation/providers/workers_providers.dart';
import 'package:helper_attendance/features/workers/presentation/screens/workers_screen.dart';

import 'fake_worker_repository.dart';

Future<void> pumpWorkersScreen(
  WidgetTester tester,
  FakeWorkerRepository repository,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [workerRepositoryProvider.overrideWithValue(repository)],
      child: const MaterialApp(home: WorkersScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the empty state when there are no workers',
      (tester) async {
    await pumpWorkersScreen(tester, FakeWorkerRepository());

    expect(find.text('No workers yet'), findsOneWidget);
  });

  testWidgets('shows each worker with name and monthly salary',
      (tester) async {
    final repository = FakeWorkerRepository([
      Worker(
          id: 1,
          name: 'Shazia',
          monthlySalary: 15000,
          createdAt: DateTime(2026, 1, 1)),
      Worker(
          id: 2,
          name: 'Bilal',
          monthlySalary: 25000,
          createdAt: DateTime(2026, 1, 1)),
    ]);
    await pumpWorkersScreen(tester, repository);

    expect(find.text('Shazia'), findsOneWidget);
    expect(find.text('Rs 15,000 / month'), findsOneWidget);
    expect(find.text('Bilal'), findsOneWidget);
    expect(find.text('Rs 25,000 / month'), findsOneWidget);
  });

  testWidgets('adding a worker puts it in the list', (tester) async {
    await pumpWorkersScreen(tester, FakeWorkerRepository());

    await tester.tap(find.text('Add worker'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('nameField')), 'Nasreen');
    await tester.enterText(find.byKey(const Key('salaryField')), '12000');
    await tester.tap(find.text('Save worker'));
    await tester.pumpAndSettle();

    expect(find.text('Nasreen'), findsOneWidget);
    expect(find.text('Rs 12,000 / month'), findsOneWidget);
  });

  testWidgets('the form rejects an empty name and salary', (tester) async {
    await pumpWorkersScreen(tester, FakeWorkerRepository());

    await tester.tap(find.text('Add worker'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save worker'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a name'), findsOneWidget);
    expect(find.text('Enter a salary greater than 0'), findsOneWidget);
  });
}
