import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../providers/shift_providers.dart';
import 'home_screen.dart';

class DutyEditScreen extends ConsumerStatefulWidget {
  const DutyEditScreen({super.key, required this.initialDate});

  final DateTime initialDate;

  @override
  ConsumerState<DutyEditScreen> createState() => _DutyEditScreenState();
}

class _DutyEditScreenState extends ConsumerState<DutyEditScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final d = widget.initialDate;
    _selectedDay = DateTime(d.year, d.month, d.day);
    _focusedDay = _selectedDay;
  }

  bool _isSameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  void _onShiftButtonPressed(String shiftTypeId) {
    ref.read(dutyEntriesProvider.notifier).setDuty(_selectedDay, shiftTypeId);
    final next = _selectedDay.add(const Duration(days: 1));
    final nextNormalized = DateTime(next.year, next.month, next.day);
    if (!_isSameMonth(nextNormalized, _selectedDay)) return;
    setState(() {
      _selectedDay = nextNormalized;
      _focusedDay = nextNormalized;
    });
  }

  void _deleteSelected() {
    final existing =
        ref.read(dutyEntriesProvider.notifier).getDuty(_selectedDay);
    if (existing == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('삭제할 근무가 없습니다')),
      );
      return;
    }
    ref.read(dutyEntriesProvider.notifier).removeDuty(_selectedDay);
  }

  @override
  Widget build(BuildContext context) {
    final shiftTypes = ref.watch(shiftTypesProvider);
    final selectedEntry = ref.watch(dutyEntryByDateProvider(_selectedDay));
    final selectedShift = selectedEntry == null
        ? null
        : shiftTypes.firstWhere(
            (s) => s.id == selectedEntry.shiftTypeId,
            orElse: () => shiftTypes.first,
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('듀티 수정'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(_selectedDay),
            child: const Text(
              '완료',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
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
            onDayLongPressed: (selected, focused) {
              setState(() {
                _selectedDay =
                    DateTime(selected.year, selected.month, selected.day);
              });
              _deleteSelected();
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
                shift: selectedShift,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Text(
              '버튼을 누르면 자동으로 다음 날로 이동합니다 (월은 고정)',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Row(
                    children: [
                      for (final shift in shiftTypes)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: SizedBox(
                              height: 64,
                              child: ElevatedButton(
                                onPressed: () =>
                                    _onShiftButtonPressed(shift.id),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(shift.colorValue),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  shift.shortName,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: () =>
                          Navigator.of(context).pop(_selectedDay),
                      icon: const Icon(Icons.check),
                      label: const Text(
                        '수정완료',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
