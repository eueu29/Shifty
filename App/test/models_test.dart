import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shifty/models/shift_type.dart';
import 'package:shifty/models/duty_entry.dart';

void main() {
  group('ShiftType', () {
    final day = ShiftType(
      id: 'day',
      name: 'Day',
      shortName: 'D',
      startTime: const TimeOfDay(hour: 7, minute: 0),
      duration: const Duration(hours: 8),
      colorValue: 0xFF2196F3,
    );
    final evening = ShiftType(
      id: 'evening',
      name: 'Evening',
      shortName: 'E',
      startTime: const TimeOfDay(hour: 15, minute: 0),
      duration: const Duration(hours: 8),
      colorValue: 0xFFFF9800,
    );
    final night = ShiftType(
      id: 'night',
      name: 'Night',
      shortName: 'N',
      startTime: const TimeOfDay(hour: 23, minute: 0),
      duration: const Duration(hours: 8),
      colorValue: 0xFF673AB7,
    );
    final off = ShiftType(
      id: 'off',
      name: 'Off',
      shortName: 'O',
      startTime: const TimeOfDay(hour: 0, minute: 0),
      duration: Duration.zero,
      colorValue: 0xFF9E9E9E,
    );

    test('creates 4 shift types with correct fields', () {
      expect(day.id, 'day');
      expect(day.shortName, 'D');
      expect(day.duration, const Duration(hours: 8));

      expect(evening.shortName, 'E');
      expect(night.shortName, 'N');
      expect(off.duration, Duration.zero);
    });

    test('toString returns non-empty string', () {
      for (final s in [day, evening, night, off]) {
        expect(s.toString().isNotEmpty, true);
      }
    });

    test('equality by id', () {
      final dayCopy = ShiftType(
        id: 'day',
        name: 'Different Name',
        shortName: 'X',
        startTime: const TimeOfDay(hour: 0, minute: 0),
        duration: const Duration(hours: 1),
        colorValue: 0,
      );
      expect(day == dayCopy, true);
      expect(day.hashCode == dayCopy.hashCode, true);
      expect(day == evening, false);
    });
  });

  group('DutyEntry', () {
    test('normalizes date to midnight', () {
      final entry = DutyEntry(
        date: DateTime(2026, 1, 1, 14, 30, 45, 123),
        shiftTypeId: 'day',
      );
      expect(entry.date, DateTime(2026, 1, 1, 0, 0, 0));
    });

    test('works as Map key with normalized date', () {
      final map = <DateTime, DutyEntry>{};
      final entry = DutyEntry(
        date: DateTime(2026, 1, 1, 9, 15),
        shiftTypeId: 'day',
      );
      map[entry.date] = entry;

      final lookup = DutyEntry(
        date: DateTime(2026, 1, 1, 22, 45),
        shiftTypeId: 'day',
      );
      expect(map[lookup.date], entry);
    });

    test('equality by date and shiftTypeId', () {
      final a = DutyEntry(date: DateTime(2026, 1, 1, 10), shiftTypeId: 'day');
      final b = DutyEntry(date: DateTime(2026, 1, 1, 20), shiftTypeId: 'day');
      final c = DutyEntry(date: DateTime(2026, 1, 1), shiftTypeId: 'night');
      expect(a == b, true);
      expect(a == c, false);
    });

    test('creates a week of entries with D,D,E,E,N,N,O pattern', () {
      const pattern = ['day', 'day', 'evening', 'evening', 'night', 'night', 'off'];
      final entries = <DutyEntry>[
        for (var i = 0; i < 7; i++)
          DutyEntry(
            date: DateTime(2026, 1, 1 + i),
            shiftTypeId: pattern[i],
          ),
      ];
      expect(entries.length, 7);
      for (var i = 0; i < 7; i++) {
        expect(entries[i].shiftTypeId, pattern[i]);
        expect(entries[i].date, DateTime(2026, 1, 1 + i));
      }
    });
  });
}
