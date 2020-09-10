part of 'activity.dart';

enum RecurrentType { none, weekly, monthly, yearly }

enum ApplyTo { onlyThisDay, allDays, thisDayAndForward }

@immutable
class Recurs extends Equatable {
  final int type, data, endTime;
  DateTime get end => DateTime.fromMillisecondsSinceEpoch(endTime);

  @visibleForTesting
  const Recurs.private(this.type, this.data, int endTime)
      : assert(data != null),
        assert(type != null),
        assert(type >= 0 && type <= 3),
        endTime = endTime ?? NO_END;

  static const Recurs not = Recurs.private(
        0,
        0,
        NO_END,
      ),
      everyDay = Recurs.private(
        TYPE_WEEKLY,
        everyday,
        NO_END,
      );

  factory Recurs.yearly(DateTime dayOfYear, {DateTime ends}) => Recurs.private(
        TYPE_YEARLY,
        dayOfYearData(dayOfYear),
        ends?.millisecondsSinceEpoch,
      );

  factory Recurs.monthly(int dayOfMonth, {DateTime ends}) => Recurs.private(
        TYPE_MONTHLT,
        onDayOfMonth(dayOfMonth),
        ends?.millisecondsSinceEpoch,
      );

  factory Recurs.monthlyOnDays(List<int> daysOfMonth, {DateTime ends}) =>
      Recurs.private(
        TYPE_MONTHLT,
        onDaysOfMonth(daysOfMonth),
        ends?.millisecondsSinceEpoch,
      );

  factory Recurs.weeklyOnDay(int dayOfWeek, {DateTime ends}) =>
      Recurs.weeklyOnDays(
        [dayOfWeek],
        ends: ends,
      );

  factory Recurs.weeklyOnDays(List<int> weekdays, {DateTime ends}) =>
      Recurs.private(
        TYPE_WEEKLY,
        onDaysOfWeek(weekdays),
        ends?.millisecondsSinceEpoch,
      );

  factory Recurs.biWeeklyOnDays({
    List<int> evens = const [],
    List<int> odds = const [],
    DateTime ends,
  }) =>
      Recurs.private(
        TYPE_WEEKLY,
        biWeekly(evens: evens, odds: odds),
        ends?.millisecondsSinceEpoch,
      );

  Recurs changeEnd(DateTime endTime) =>
      Recurs.private(type, data, endTime.millisecondsSinceEpoch);

  RecurrentType get recurrance =>
      RecurrentType.values[type] ?? RecurrentType.none;

  @override
  List<Object> get props => [data, type, endTime];

  @override
  bool get stringify => true;

  static const int TYPE_NONE = 0,
      TYPE_WEEKLY = 1,
      TYPE_MONTHLT = 2,
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
  static int onDayOfMonth(int dayOfMonth) => _toBitMask(dayOfMonth);

  static int onDaysOfMonth(List<int> daysOfMonth) => daysOfMonth.fold(
        0,
        (ds, d) => ds | onDayOfMonth(d),
      );

  static int dayOfYearData(DateTime date) => (date.month - 1) * 100 + date.day;

  static int onDaysOfWeek(List<int> weekDays) => biWeekly(
        evens: weekDays,
        odds: weekDays,
      );

  static int biWeekly({
    List<int> evens = const [],
    List<int> odds = const [],
  }) =>
      evens
          .followedBy(odds.map((d) => d + 7))
          .fold(0, (ds, d) => ds | _toBitMask(d));

  static int _toBitMask(int bit) => 1 << (bit - 1);

  @override
  String toString() =>
      '$recurrance; ends -> ${endTime == NO_END ? 'no end' : end}; $data';
}
