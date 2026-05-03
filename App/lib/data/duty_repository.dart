import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/duty_entry.dart';

class DutyRepository {
  static const String boxName = 'duty_entries';

  Box<dynamic>? _box;

  String _keyFor(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return normalized.toIso8601String();
  }

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<dynamic>(boxName);
  }

  Future<List<DutyEntry>> loadAll() async {
    final box = _box;
    if (box == null) return const [];
    final result = <DutyEntry>[];
    for (final v in box.values) {
      try {
        final map = (v as Map).cast<String, dynamic>();
        result.add(DutyEntry.fromMap(map));
      } catch (e) {
        debugPrint('DutyRepository.loadAll: failed to parse $v — $e');
      }
    }
    return result;
  }

  Future<void> save(DutyEntry entry) async {
    try {
      await _box?.put(_keyFor(entry.date), entry.toMap());
    } catch (e) {
      debugPrint('DutyRepository.save failed: $e');
    }
  }

  Future<void> delete(DateTime date) async {
    try {
      await _box?.delete(_keyFor(date));
    } catch (e) {
      debugPrint('DutyRepository.delete failed: $e');
    }
  }

  Future<void> clear() async {
    try {
      await _box?.clear();
    } catch (e) {
      debugPrint('DutyRepository.clear failed: $e');
    }
  }
}
