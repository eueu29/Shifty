import 'package:flutter/material.dart';

class ShiftType {
  final String id;
  final String name;
  final String shortName;
  final TimeOfDay startTime;
  final Duration duration;
  final int colorValue;

  const ShiftType({
    required this.id,
    required this.name,
    required this.shortName,
    required this.startTime,
    required this.duration,
    required this.colorValue,
  });

  @override
  String toString() {
    final hh = startTime.hour.toString().padLeft(2, '0');
    final mm = startTime.minute.toString().padLeft(2, '0');
    final hours = duration.inMinutes / 60;
    final hoursStr = hours == hours.toInt() ? '${hours.toInt()}h' : '${hours}h';
    return 'ShiftType($shortName, $hh:$mm, $hoursStr)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ShiftType && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
