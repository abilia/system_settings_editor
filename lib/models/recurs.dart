part of 'activity.dart';

enum RecurrentType { none, weekly, monthly, yearly }

enum ApplyTo { onlyThisDay, allDays, thisDayAndForward }

@immutable
class Recurs extends Equatable {
  final int type, data;
  const Recurs._(this.type, this.data)
      : assert(data != null),
        assert(type != null),
        assert(type >= 0 && type <= 3);

  static const Recurs not = Recurs._(0, 0),
      everyDay = Recurs._(TYPE_WEEKLY, everyday);

  factory Recurs.yearly(DateTime dayOfYear) =>
      Recurs._(TYPE_YEARLY, dayOfYearData(dayOfYear));
  factory Recurs.monthly(int dayOfMonth) =>
      Recurs._(TYPE_MONTHLT, onDayOfMonth(dayOfMonth));
  factory Recurs.monthlyOnDays(List<int> daysOfMonth) =>
      Recurs._(TYPE_MONTHLT, onDaysOfMonth(daysOfMonth));
  factory Recurs.weekly(int dayOfWeek) => Recurs._(TYPE_WEEKLY, dayOfWeek);
  factory Recurs.weeklyOnDays(List<int> daysOfWeek) =>
      Recurs._(TYPE_WEEKLY, onDaysOfWeek(daysOfWeek));

  RecurrentType get recurrance =>
      RecurrentType.values[type] ?? RecurrentType.none;

  @override
  List<Object> get props => [data, type];

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

  static final DateTime NO_END =
      DateTime.fromMillisecondsSinceEpoch(253402297199000);
  static int onDayOfMonth(int dayOfMonth) => 1 << (dayOfMonth - 1);
  static int onDaysOfMonth(List<int> daysOfMonth) =>
      daysOfMonth.fold(0, (ds, d) => ds | onDayOfMonth(d));
  static int dayOfYearData(DateTime date) => (date.month - 1) * 100 + date.day;
  static int onDaysOfWeek(List<int> daysOfMonth) =>
      daysOfMonth.fold(0, (ds, d) => ds | d);
}
