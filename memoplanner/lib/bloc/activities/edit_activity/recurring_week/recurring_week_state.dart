part of 'recurring_week_cubit.dart';

class RecurringWeekState extends Equatable {
  static const allWeekdays = {1, 2, 3, 4, 5, 6, 7};
  final UnmodifiableSetView<int> weekdays;
  final bool everyOtherWeek;
  final DateTime startDate, endDate;
  const RecurringWeekState(
    this.weekdays,
    this.everyOtherWeek,
    this.startDate,
    this.endDate,
  );

  bool get containsAllWeekdays => weekdays.containsAll(allWeekdays);

  RecurringWeekState.initial(
    EditActivityState editActivityState,
  )   : weekdays =
            UnmodifiableSetView(editActivityState.activity.recurs.weekdays),
        everyOtherWeek = editActivityState.activity.recurs.everyOtherWeek,
        startDate = editActivityState.timeInterval.startDate,
        endDate = editActivityState.activity.recurs.end;

  bool get evenStartWeek => startDate.getWeekNumber().isEven;

  Recurs get recurs => everyOtherWeek
      ? evenStartWeek
          ? Recurs.biWeeklyOnDays(evens: weekdays, ends: endDate)
          : Recurs.biWeeklyOnDays(odds: weekdays, ends: endDate)
      : Recurs.weeklyOnDays(weekdays, ends: endDate);

  @override
  List<Object> get props => [
        weekdays,
        everyOtherWeek,
        startDate,
        endDate,
      ];

  @override
  bool get stringify => true;

  RecurringWeekState copyWith({
    Set<int>? weekdays,
    bool? everyOtherWeek,
    DateTime? startDate,
    DateTime? endDate,
  }) =>
      RecurringWeekState(
        weekdays != null ? UnmodifiableSetView(weekdays) : this.weekdays,
        everyOtherWeek ?? this.everyOtherWeek,
        startDate ?? this.startDate,
        endDate ?? this.endDate,
      );
}
