import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shifty/data/duty_repository.dart';
import 'package:shifty/models/duty_entry.dart';
import 'package:shifty/providers/shift_providers.dart';
import 'package:shifty/screens/duty_edit_screen.dart';
import 'package:shifty/screens/home_screen.dart';

class FakeDutyRepository extends DutyRepository {
  final List<DutyEntry> saved = [];

  @override
  Future<void> init() async {}

  @override
  Future<List<DutyEntry>> loadAll() async => List.of(saved);

  @override
  Future<void> save(DutyEntry entry) async {
    saved.removeWhere((e) => e.date == entry.date);
    saved.add(entry);
  }

  @override
  Future<void> delete(DateTime date) async {
    final normalized = DateTime(date.year, date.month, date.day);
    saved.removeWhere((e) => e.date == normalized);
  }

  @override
  Future<void> clear() async => saved.clear();
}

ProviderScope _fakeScope({
  List<DutyEntry> initial = const [],
  required Widget child,
}) =>
    ProviderScope(
      overrides: [
        dutyRepositoryProvider.overrideWithValue(FakeDutyRepository()),
        initialDutyEntriesProvider.overrideWithValue(initial),
      ],
      child: child,
    );

ProviderContainer _fakeContainer([List<DutyEntry> initial = const []]) =>
    ProviderContainer(overrides: [
      dutyRepositoryProvider.overrideWithValue(FakeDutyRepository()),
      initialDutyEntriesProvider.overrideWithValue(initial),
    ]);

void main() {
  testWidgets('HomeScreen builds and starts empty', (tester) async {
    await tester.pumpWidget(
      _fakeScope(child: const MaterialApp(home: HomeScreen())),
    );
    await tester.pump();

    expect(find.text('Shifty'), findsOneWidget);
    expect(find.text('듀티 수정'), findsOneWidget);
  });

  testWidgets('DutyEditScreen D button adds duty and advances day',
      (tester) async {
    final container = _fakeContainer();
    addTearDown(container.dispose);

    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: DutyEditScreen(initialDate: todayNormalized)),
      ),
    );
    await tester.pump();

    expect(container.read(dutyEntriesProvider), isEmpty);

    await tester.tap(find.widgetWithText(ElevatedButton, 'D'));
    await tester.pump();

    final entries = container.read(dutyEntriesProvider);
    expect(entries.length, 1);
    expect(entries.first.date, todayNormalized);
    expect(entries.first.shiftTypeId, 'day');
  });

  testWidgets('setDuty overwrites on same day', (tester) async {
    final container = _fakeContainer();
    addTearDown(container.dispose);

    final today = DateTime.now();
    final normalized = DateTime(today.year, today.month, today.day);

    container.read(dutyEntriesProvider.notifier).setDuty(normalized, 'day');
    container.read(dutyEntriesProvider.notifier).setDuty(normalized, 'night');

    final entries = container.read(dutyEntriesProvider);
    expect(entries.length, 1);
    expect(entries.first.shiftTypeId, 'night');
  });

  test('DutyEntry toMap/fromMap round-trip preserves normalization', () {
    final entry = DutyEntry(
      date: DateTime(2026, 4, 13, 9, 30),
      shiftTypeId: 'day',
    );
    final restored = DutyEntry.fromMap(entry.toMap());
    expect(restored, entry);
    expect(restored.date, DateTime(2026, 4, 13));
  });
}
