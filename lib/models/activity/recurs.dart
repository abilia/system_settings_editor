part of 'activity.dart';

enum RecurrentType { none, weekly, monthly, yearly }

extension DefaultEndDate on RecurrentType {
  DateTime? get defaultEndDate {
    switch (this) {
      case RecurrentType.weekly:
      case RecurrentType.monthly:
        return null;
      case RecurrentType.none:
      case RecurrentType.yearly:
        return Recurs.noEndDate;
    }
  }
}

enum ApplyTo { onlyThisDay, allDays, thisDayAndForward }

@immutable
class Recurs extends Equatable {
  final int type, data, endTime;
  DateTime get end => DateTime.fromMillisecondsSinceEpoch(endTime);
  bool get hasNoEnd => endTime >= noEnd;
  bool get isRecurring => type != typeNone;
  bool get weekly => type == typeWeekly;
  bool get monthly => type == typeMonthly;
  bool get yearly => type == typeYearly;
  bool get once => type == typeNone;

  @visibleForTesting
  const Recurs.raw(this.type, this.data, int? endTime)
      : assert(type >= typeNone && type <= typeYearly),
        assert(type != typeWeekly || data < 0x4000),
        assert(type != typeMonthly || data < 0x80000000),
        endTime = endTime == null || endTime > noEnd ? noEnd : endTime;

  static const not = Recurs.raw(typeNone, 0, noEnd),
      everyDay = Recurs.raw(
        typeWeekly,
        allDaysOfWeek,
        noEnd,
      );

  factory Recurs.yearly(DateTime dayOfYear, {DateTime? ends}) => Recurs.raw(
        typeYearly,
        dayOfYearData(dayOfYear),
        ends?.millisecondsSinceEpoch,
      );

  factory Recurs.monthly(int dayOfMonth, {DateTime? ends}) => Recurs.raw(
        typeMonthly,
        onDayOfMonth(dayOfMonth),
        ends?.millisecondsSinceEpoch,
      );

  factory Recurs.monthlyOnDays(Iterable<int> daysOfMonth, {DateTime? ends}) =>
      Recurs.raw(
        typeMonthly,
        onDaysOfMonth(daysOfMonth),
        ends?.millisecondsSinceEpoch,
      );

  factory Recurs.weeklyOnDay(int dayOfWeek, {DateTime? ends}) =>
      Recurs.weeklyOnDays(
        [dayOfWeek],
        ends: ends,
      );

  factory Recurs.weeklyOnDays(Iterable<int> weekdays, {DateTime? ends}) =>
      Recurs.raw(
        typeWeekly,
        onDaysOfWeek(weekdays),
        ends?.millisecondsSinceEpoch,
      );

  factory Recurs.biWeeklyOnDays({
    Iterable<int> evens = const [],
    Iterable<int> odds = const [],
    DateTime? ends,
  }) =>
      Recurs.raw(
        typeWeekly,
        biWeekly(evens: evens, odds: odds),
        ends?.millisecondsSinceEpoch,
      );

  Recurs changeEnd(DateTime endTime) =>
      Recurs.raw(type, data, endTime.millisecondsSinceEpoch);

  RecurrentType get recurrance => RecurrentType.values[type];

  bool recursOnDay(DateTime day) {
    switch (recurrance) {
      case RecurrentType.weekly:
        return _recursOnWeeklyDay(day);
      case RecurrentType.monthly:
        return _recursOnMonthDay(day);
      case RecurrentType.yearly:
        return _recursOnYearDay(day);
      default:
        return false;
    }
  }

  bool _recursOnWeeklyDay(DateTime date) {
    final isOddWeek = date.getWeekNumber().isOdd;
    final leadingZeros = date.weekday - 1 + (isOddWeek ? 7 : 0);
    return _isBitSet(data, leadingZeros);
  }

  bool _recursOnMonthDay(DateTime day) => _isBitSet(data, day.day - 1);

  bool _recursOnYearDay(DateTime date) {
    final recurringDay = data % 100;
    final recurringMonth = data ~/ 100 + 1;
    return date.month == recurringMonth && date.day == recurringDay;
  }

  @override
  List<Object> get props => [data, type, endTime];

  @override
  bool get stringify => true;

  static const int typeNone = 0,
      typeWeekly = 1,
      typeMonthly = 2,
      typeYearly = 3,
      evenMonday = 0x1,
      evenTuesday = 0x2,
      evenWednesday = 0x4,
      evenThursday = 0x8,
      evenFriday = 0x10,
      evenSaturday = 0x20,
      evenSunday = 0x40,
      oddMonday = 0x80,
      oddTuesday = 0x100,
      oddWednesday = 0x200,
      oddThursday = 0x400,
      oddFriday = 0x800,
      oddSaturday = 0x1000,
      oddSunday = 0x2000,
      monday = evenMonday | oddMonday,
      tuesday = evenTuesday | oddTuesday,
      wednesday = evenWednesday | oddWednesday,
      thursday = evenThursday | oddThursday,
      friday = evenFriday | oddFriday,
      saturday = evenSaturday | oddSaturday,
      sunday = evenSunday | oddSunday,
      oddWeekdays = Recurs.oddMonday |
          Recurs.oddTuesday |
          Recurs.oddWednesday |
          Recurs.oddThursday |
          Recurs.oddFriday,
      evenWeekdays = Recurs.evenMonday |
          Recurs.evenTuesday |
          Recurs.evenWednesday |
          Recurs.evenThursday |
          Recurs.evenFriday,
      allWeekdays = oddWeekdays | evenWeekdays,
      oddWeekends = Recurs.oddSaturday | Recurs.oddSunday,
      evenWeekends = Recurs.evenSaturday | Recurs.evenSunday,
      allWeekends = evenWeekends | oddWeekends,
      allDaysOfWeek = allWeekdays | allWeekends;

  static const noEnd = 253402297199000;
  static final noEndDate = DateTime.fromMillisecondsSinceEpoch(noEnd);

  @visibleForTesting
  static int onDayOfMonth(int dayOfMonth) => _toBitMask(dayOfMonth);

  @visibleForTesting
  static int onDaysOfMonth(Iterable<int> daysOfMonth) => daysOfMonth.fold(
        0,
        (ds, d) => ds | onDayOfMonth(d),
      );

  @visibleForTesting
  static int dayOfYearData(DateTime date) => (date.month - 1) * 100 + date.day;

  @visibleForTesting
  static int onDaysOfWeek(Iterable<int> weekDays) => biWeekly(
        evens: weekDays,
        odds: weekDays,
      );

  @visibleForTesting
  static int biWeekly({
    Iterable<int> evens = const [],
    Iterable<int> odds = const [],
  }) =>
      evens
          .followedBy(odds.map((d) => d + 7))
          .fold(0, (ds, d) => ds | _toBitMask(d));

  static int _toBitMask(int bit) => 1 << (bit - 1);

  Set<int> get weekDays => weekly
      ? _generateBitsSet(
          DateTime.daysPerWeek, _onlyOddWeeks ? _oddWeekBits : data)
      : {};

  Set<int> get monthDays => monthly ? _generateBitsSet(31, data) : {};
  bool get everyOtherWeek => weekly && _onEvenWeek != _onOddWeek;

  bool get _onEvenWeek => weekly && _evenWeekBits > 0;
  bool get _onOddWeek => weekly && _oddWeekBits > 0;
  bool get _onlyOddWeeks => everyOtherWeek && _onOddWeek;
  int get _oddWeekBits => data >> 7;
  int get _evenWeekBits => data & 0x7F;

  bool _isBitSet(int recurrentData, int bit) => recurrentData & (1 << bit) > 0;

  Set<int> _generateBitsSet(int bits, int data) =>
      List.generate(bits, (bit) => bit, growable: false)
          .where((bit) => _isBitSet(data, bit))
          .map((bit) => bit + 1)
          .toSet();

  @override
  String toString() =>
      '$recurrance; ends -> ${endTime == noEnd ? 'no end' : end}; ${_generateBitsSet(31, data)}';
}
