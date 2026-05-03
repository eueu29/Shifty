import 'package:flutter/material.dart';

import '../models/duty_entry.dart';
import '../models/shift_type.dart';

List<ShiftType> defaultShiftTypes() {
  return [
    ShiftType(
      id: 'day',
      name: 'Day',
      shortName: 'D',
      startTime: const TimeOfDay(hour: 7, minute: 0),
      duration: const Duration(hours: 8),
      colorValue: Colors.blue.toARGB32(),
    ),
    ShiftType(
      id: 'evening',
      name: 'Evening',
      shortName: 'E',
      startTime: const TimeOfDay(hour: 14, minute: 0),
      duration: const Duration(hours: 8),
      colorValue: Colors.orange.toARGB32(),
    ),
    ShiftType(
      id: 'night',
      name: 'Night',
      shortName: 'N',
      startTime: const TimeOfDay(hour: 22, minute: 0),
      duration: const Duration(hours: 9),
      colorValue: Colors.purple.toARGB32(),
    ),
    ShiftType(
      id: 'off',
      name: 'Off',
      shortName: 'O',
      startTime: const TimeOfDay(hour: 0, minute: 0),
      duration: Duration.zero,
      colorValue: Colors.grey.toARGB32(),
    ),
  ];
}

List<DutyEntry> dummyDutyEntries() {
  const pattern = ['day', 'day', 'evening', 'evening', 'night', 'night', 'off'];
  final now = DateTime.now();
  return [
    for (var i = 0; i < 14; i++)
      DutyEntry(
        date: DateTime(now.year, now.month, 1 + i),
        shiftTypeId: pattern[i % pattern.length],
      ),
  ];
}
