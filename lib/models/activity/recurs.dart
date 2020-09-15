part of 'activity.dart';

enum RecurrentType { none, weekly, monthly, yearly }

enum ApplyTo { onlyThisDay, allDays, thisDayAndForward }

@immutable
class Recurs extends Equatable {
  final int type, data, endTime;
  DateTime get end => DateTime.fromMillisecondsSinceEpoch(endTime);
  bool get hasNoEnd => endTime == NO_END;

  @visibleForTesting
  const Recurs.raw(this.type, this.data, int endTime)
      : assert(data != null),
        assert(type != null),
        assert(type >= 0 && type <= 3),
        assert(type != TYPE_WEEKLY || data < 0x4000),
        assert(type != TYPE_MONTHLY || data < 0x80000000),
        endTime = endTime ?? NO_END;

  static const Recurs not = Recurs.raw(
        0,
        0,
        NO_END,
      ),
      everyDay = Recurs.raw(
        TYPE_WEEKLY,
        everyday,
        NO_END,
      );

  factory Recurs.yearly(DateTime dayOfYear, {DateTime ends}) => Recurs.raw(
        TYPE_YEARLY,
        dayOfYearData(dayOfYear),
        ends?.millisecondsSinceEpoch,
      );

  factory Recurs.monthly(int dayOfMonth, {DateTime ends}) => Recurs.raw(
        TYPE_MONTHLY,
        onDayOfMonth(dayOfMonth),
        ends?.millisecondsSinceEpoch,
      );

  factory Recurs.monthlyOnDays(Iterable<int> daysOfMonth, {DateTime ends}) =>
      Recurs.raw(
        TYPE_MONTHLY,
        onDaysOfMonth(daysOfMonth),
        ends?.millisecondsSinceEpoch,
      );

  factory Recurs.weeklyOnDay(int dayOfWeek, {DateTime ends}) =>
      Recurs.weeklyOnDays(
        [dayOfWeek],
        ends: ends,
      );

  factory Recurs.weeklyOnDays(Iterable<int> weekdays, {DateTime ends}) =>
      Recurs.raw(
        TYPE_WEEKLY,
        onDaysOfWeek(weekdays),
        ends?.millisecondsSinceEpoch,
      );

  factory Recurs.biWeeklyOnDays({
    Iterable<int> evens = const [],
    Iterable<int> odds = const [],
    DateTime ends,
  }) =>
      Recurs.raw(
        TYPE_WEEKLY,
        biWeekly(evens: evens, odds: odds),
        ends?.millisecondsSinceEpoch,
      );

  Recurs changeEnd(DateTime endTime) =>
      Recurs.raw(type, data, endTime.millisecondsSinceEpoch);

  RecurrentType get recurrance =>
      RecurrentType.values[type] ?? RecurrentType.none;

  bool recursOnDay(DateTime day) {
    switch (recurrance) {
      case RecurrentType.weekly:
        return _recursOnWeeklyDay(data, day);
      case RecurrentType.monthly:
        return _recursOnMonthDay(data, day);
      case RecurrentType.yearly:
        return _recursOnYearDay(data, day);
      default:
        return false;
    }
  }

  bool _recursOnWeeklyDay(int recurrentData, DateTime date) {
    final isOddWeek = date.getWeekNumber().isOdd;
    final leadingZeros = date.weekday - 1 + (isOddWeek ? 7 : 0);
    return isBitSet(recurrentData, leadingZeros);
  }

  bool _recursOnMonthDay(int recurrentData, DateTime day) =>
      isBitSet(recurrentData, day.day - 1);

  bool _recursOnYearDay(int recurrentData, DateTime date) {
    final recurringDay = recurrentData % 100;
    final recurringMonth = recurrentData ~/ 100 + 1;
    return date.month == recurringMonth && date.day == recurringDay;
  }

  @override
  List<Object> get props => [data, type, endTime];

  @override
  bool get stringify => true;

  static const int TYPE_NONE = 0,
      TYPE_WEEKLY = 1,
      TYPE_MONTHLY = 2,
      TYPE_YEARLY = 3,
      EVEN_MONDAY = 0x1,
      EVEN_TUESDAY = 0x2,
      EVEN_WEDNESDAY = 0x4,
      EVEN_THURSDAY = 0x8,
      EVEN_FRIDAY = 0x10,
      EVEN_SATURDAY = 0x20,
      EVEN_SUNDAY = 0x40,
      ODD_MONDAY = 0x80,
      ODD_TUESDAY = 0x100,
      ODD_WEDNESDAY = 0x200,
      ODD_THURSDAY = 0x400,
      ODD_FRIDAY = 0x800,
      ODD_SATURDAY = 0x1000,
      ODD_SUNDAY = 0x2000,
      MONDAY = EVEN_MONDAY | ODD_MONDAY,
      TUESDAY = EVEN_TUESDAY | ODD_TUESDAY,
      WEDNESDAY = EVEN_WEDNESDAY | ODD_WEDNESDAY,
      THURSDAY = EVEN_THURSDAY | ODD_THURSDAY,
      FRIDAY = EVEN_FRIDAY | ODD_FRIDAY,
      SATURDAY = EVEN_SATURDAY | ODD_SATURDAY,
      SUNDAY = EVEN_SUNDAY | ODD_SUNDAY,
      oddWeekdays = Recurs.ODD_MONDAY |
          Recurs.ODD_TUESDAY |
          Recurs.ODD_WEDNESDAY |
          Recurs.ODD_THURSDAY |
          Recurs.ODD_FRIDAY,
      evenWeekdays = Recurs.EVEN_MONDAY |
          Recurs.EVEN_TUESDAY |
          Recurs.EVEN_WEDNESDAY |
          Recurs.EVEN_THURSDAY |
          Recurs.EVEN_FRIDAY,
      allWeekdays = oddWeekdays | evenWeekdays,
      oddWeekends = Recurs.ODD_SATURDAY | Recurs.ODD_SUNDAY,
      evenWeekends = Recurs.EVEN_SATURDAY | Recurs.EVEN_SUNDAY,
      allWeekends = evenWeekends | oddWeekends,
      everyday = allWeekdays | allWeekends;

  static const NO_END = 253402297199000;
  static final noEndDate = DateTime.fromMillisecondsSinceEpoch(NO_END);

  static int onDayOfMonth(int dayOfMonth) => _toBitMask(dayOfMonth);

  static int onDaysOfMonth(Iterable<int> daysOfMonth) => daysOfMonth.fold(
        0,
        (ds, d) => ds | onDayOfMonth(d),
      );

  static int dayOfYearData(DateTime date) => (date.month - 1) * 100 + date.day;

  static int onDaysOfWeek(Iterable<int> weekDays) => biWeekly(
        evens: weekDays,
        odds: weekDays,
      );

  static int biWeekly({
    Iterable<int> evens = const [],
    Iterable<int> odds = const [],
  }) =>
      evens
          .followedBy(odds.map((d) => d + 7))
          .fold(0, (ds, d) => ds | _toBitMask(d));

  static int _toBitMask(int bit) => 1 << (bit - 1);

  static bool isBitSet(int recurrentData, int bit) =>
      recurrentData & (1 << bit) > 0;

  @override
  String toString() =>
      '$recurrance; ends -> ${endTime == NO_END ? 'no end' : end}; $data';
}
