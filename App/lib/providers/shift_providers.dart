import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/dummy_data.dart';
import '../data/duty_repository.dart';
import '../models/duty_entry.dart';
import '../models/shift_type.dart';

final shiftTypesProvider = Provider<List<ShiftType>>((ref) {
  return defaultShiftTypes();
});

final dutyRepositoryProvider = Provider<DutyRepository>((ref) {
  throw UnimplementedError('dutyRepositoryProvider must be overridden');
});

final initialDutyEntriesProvider = Provider<List<DutyEntry>>((ref) {
  return const [];
});

DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

class DutyEntriesNotifier extends Notifier<List<DutyEntry>> {
  @override
  List<DutyEntry> build() => ref.read(initialDutyEntriesProvider);

  DutyRepository get _repo => ref.read(dutyRepositoryProvider);

  void setDuty(DateTime date, String shiftTypeId) {
    final normalized = _normalize(date);
    final entry = DutyEntry(date: normalized, shiftTypeId: shiftTypeId);
    state = [
      ...state.where((e) => e.date != normalized),
      entry,
    ];
    _repo.save(entry);
  }

  void removeDuty(DateTime date) {
    final normalized = _normalize(date);
    state = state.where((e) => e.date != normalized).toList();
    _repo.delete(normalized);
  }

  DutyEntry? getDuty(DateTime date) {
    final normalized = _normalize(date);
    for (final e in state) {
      if (e.date == normalized) return e;
    }
    return null;
  }
}

final dutyEntriesProvider =
    NotifierProvider<DutyEntriesNotifier, List<DutyEntry>>(
  DutyEntriesNotifier.new,
);

final dutyEntryByDateProvider =
    Provider.family<DutyEntry?, DateTime>((ref, date) {
  ref.watch(dutyEntriesProvider);
  return ref.read(dutyEntriesProvider.notifier).getDuty(date);
});
