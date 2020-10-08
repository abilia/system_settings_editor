part of 'recurring_week_bloc.dart';

abstract class RecurringWeekEvent extends Equatable {
  const RecurringWeekEvent();
  @override
  bool get stringify => true;
}

class AddOrRemoveWeekday extends RecurringWeekEvent {
  final int day;
  const AddOrRemoveWeekday(this.day)
      : assert(day >= DateTime.monday),
        assert(day <= DateTime.sunday);
  @override
  List<Object> get props => [day];
}

class ChangeEveryOtherWeek extends RecurringWeekEvent {
  final bool everyOtherWeek;

  ChangeEveryOtherWeek(this.everyOtherWeek) : assert(everyOtherWeek != null);
  @override
  List<Object> get props => [everyOtherWeek];
}

class ChangeStartDate extends RecurringWeekEvent {
  final DateTime startDate;
  ChangeStartDate(this.startDate) : assert(startDate != null);
  @override
  List<Object> get props => [startDate];
}

class ChangeEndDate extends RecurringWeekEvent {
  final DateTime endDate;
  ChangeEndDate(this.endDate) : assert(endDate != null);
  @override
  List<Object> get props => [endDate];
}
