import 'dart:async';

import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/utils/all.dart';

class DayEventsCubit extends Cubit<EventsState> {
  final ActivitiesBloc activitiesBloc;
  final TimerAlarmBloc timerAlarmBloc;
  final DayPickerBloc dayPickerBloc;
  late final StreamSubscription _activitiesSubscription;
  late final StreamSubscription _timerSubscription;
  late final StreamSubscription _dayPickerSubscription;
  // Makes animated page transitions possible in DayCalendar
  late EventsState previousState = state;

  DayEventsCubit({
    required this.activitiesBloc,
    required this.dayPickerBloc,
    required this.timerAlarmBloc,
  }) : super(
          EventsLoading(
            dayPickerBloc.state.day,
            dayPickerBloc.state.occasion,
          ),
        ) {
    _activitiesSubscription =
        activitiesBloc.stream.listen((state) async => _updateState());
    _dayPickerSubscription = dayPickerBloc.stream.listen(((state) async =>
        _updateState(day: state.day, occasion: state.occasion)));
    _timerSubscription = timerAlarmBloc.stream
        .listen((state) async => _updateState(timers: state.timers));
  }

  Future<void> initialize() => _updateState();

  Future<void> _updateState({
    List<TimerOccasion>? timers,
    DateTime? day,
    Occasion? occasion,
  }) async {
    previousState = state;
    final newStateDay = day ?? dayPickerBloc.state.day;
    final activities = await activitiesBloc.activityRepository.allBetween(
      newStateDay.onlyDays(),
      newStateDay.nextDay(),
    );
    emit(
      _mapToState(
        activities,
        timers ?? timerAlarmBloc.state.timers,
        newStateDay,
        occasion ?? dayPickerBloc.state.occasion,
      ),
    );
  }

  EventsState _mapToState(
    Iterable<Activity> activities,
    Iterable<TimerOccasion> timerOccasions,
    DateTime day,
    Occasion occasion,
  ) {
    final dayActivities = activities
        .expand((activity) => activity.dayActivitiesForDay(day))
        .removeAfterOccasion(occasion)
        .toList();
    final fullDayOccasion = occasion.isPast ? Occasion.past : Occasion.future;
    return EventsState(
      activities: dayActivities
          .where((activityDay) => !activityDay.activity.fullDay)
          .toList(),
      timers: timerOccasions.onDay(day),
      fullDayActivities: dayActivities
          .where((activityDay) => activityDay.activity.fullDay)
          .map((e) => ActivityOccasion(e.activity, day, fullDayOccasion))
          .toList(),
      day: day,
      occasion: occasion,
    );
  }

  @override
  Future<void> close() async {
    await _activitiesSubscription.cancel();
    await _dayPickerSubscription.cancel();
    await _timerSubscription.cancel();
    return super.close();
  }
}
