import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../features/alarm/dev_alarm_test_screen.dart';
import '../models/shift_type.dart';
import '../providers/shift_providers.dart';
import 'duty_edit_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDay = DateTime(now.year, now.month, now.day);
    _selectedDay = _focusedDay;
  }

  Future<void> _openEditScreen() async {
    final result = await Navigator.of(context).push<DateTime>(
      MaterialPageRoute(
        builder: (_) => DutyEditScreen(initialDate: _selectedDay),
      ),
    );
    if (result != null) {
      setState(() {
        _selectedDay = DateTime(result.year, result.month, result.day);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final shiftTypes = ref.watch(shiftTypesProvider);
    final selectedEntry = ref.watch(dutyEntryByDateProvider(_selectedDay));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shifty'),
        actions: [
          if (DevAlarmTestScreen.isAvailable)
            IconButton(
              tooltip: 'Dev: 알람 테스트',
              icon: const Icon(Icons.alarm),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const DevAlarmTestScreen(),
                  ),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay =
                    DateTime(selected.year, selected.month, selected.day);
              });
            },
            onPageChanged: (focused) {
              _focusedDay = focused;
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, _) {
                final entry = ref.watch(dutyEntryByDateProvider(day));
                if (entry == null) return const SizedBox.shrink();
                final shift = shiftTypes.firstWhere(
                  (s) => s.id == entry.shiftTypeId,
                  orElse: () => shiftTypes.first,
                );
                return Positioned(
                  bottom: 2,
                  child: Container(
                    width: 16,
                    height: 16,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Color(shift.colorValue),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      shift.shortName,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(),
          Expanded(
            child: Center(
              child: DutyInfoText(
                selectedDay: _selectedDay,
                shift: selectedEntry == null
                    ? null
                    : shiftTypes.firstWhere(
                        (s) => s.id == selectedEntry.shiftTypeId,
                        orElse: () => shiftTypes.first,
                      ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _openEditScreen,
                  icon: const Icon(Icons.edit_calendar),
                  label: const Text(
                    '듀티 수정',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DutyInfoText extends StatelessWidget {
  const DutyInfoText({
    super.key,
    required this.selectedDay,
    required this.shift,
  });

  final DateTime selectedDay;
  final ShiftType? shift;

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${selectedDay.year}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}';

    if (shift == null) {
      return Text(
        '$dateStr — 근무 정보 없음',
        style: const TextStyle(fontSize: 16),
      );
    }

    final start = shift!.startTime;
    final endMinutes =
        start.hour * 60 + start.minute + shift!.duration.inMinutes;
    final endHour = (endMinutes ~/ 60) % 24;
    final endMin = endMinutes % 60;
    final startStr =
        '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
    final endStr =
        '${endHour.toString().padLeft(2, '0')}:${endMin.toString().padLeft(2, '0')}';

    if (shift!.duration == Duration.zero) {
      return Text(
        '$dateStr — ${shift!.name}',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      );
    }

    return Text(
      '$dateStr — ${shift!.name} ($startStr ~ $endStr)',
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    );
  }
}
