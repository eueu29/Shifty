class DutyEntry {
  final DateTime date;
  final String shiftTypeId;

  DutyEntry._internal({required this.date, required this.shiftTypeId});

  factory DutyEntry({required DateTime date, required String shiftTypeId}) {
    return DutyEntry._internal(
      date: DateTime(date.year, date.month, date.day),
      shiftTypeId: shiftTypeId,
    );
  }

  @override
  String toString() {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return 'DutyEntry($y-$m-$d, $shiftTypeId)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DutyEntry &&
          other.date == date &&
          other.shiftTypeId == shiftTypeId);

  @override
  int get hashCode => Object.hash(date, shiftTypeId);

  Map<String, dynamic> toMap() => {
        'date': date.toIso8601String(),
        'shiftTypeId': shiftTypeId,
      };

  factory DutyEntry.fromMap(Map<String, dynamic> map) => DutyEntry(
        date: DateTime.parse(map['date'] as String),
        shiftTypeId: map['shiftTypeId'] as String,
      );
}
