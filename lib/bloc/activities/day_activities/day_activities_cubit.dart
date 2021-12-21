import 'dart:async';

import 'package:rxdart/rxdart.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

part 'day_activities_state.dart';

class DayActivitiesCubit extends Cubit<DayActivitiesState> {
  final ActivitiesBloc activitiesBloc;
  final DayPickerBloc dayPickerBloc;
  late final StreamSubscription _activitiesSubscription;
  late final StreamSubscription _dayPickerSubscription;

  DayActivitiesCubit({
    required this.activitiesBloc,
    required this.dayPickerBloc,
  }) : super(activitiesBloc.state is ActivitiesLoaded
            ? _mapToState(
                (activitiesBloc.state as ActivitiesLoaded).activities,
                dayPickerBloc.state.day,
                dayPickerBloc.state.occasion,
              )
            : DayActivitiesUninitialized()) {
    _activitiesSubscription = activitiesBloc.stream
        .whereType<ActivitiesLoaded>()
        .listen(_activitiesUpdated);
    _dayPickerSubscription = dayPickerBloc.stream.listen(_dayUpdated);
  }

  void _activitiesUpdated(final ActivitiesLoaded activityState) => emit(
        _mapToState(
          activityState.activities,
          dayPickerBloc.state.day,
          dayPickerBloc.state.occasion,
        ),
      );

  void _dayUpdated(final DayPickerState state) {
    final activityState = activitiesBloc.state;
    if (activityState is ActivitiesLoaded) {
      emit(
        _mapToState(
          activityState.activities,
          state.day,
          state.occasion,
        ),
      );
    }
  }

  static DayActivitiesState _mapToState(
    final Iterable<Activity> activities,
    final DateTime day,
    final Occasion occasion,
  ) =>
      DayActivitiesLoaded(
        activities
            .expand((activity) => activity.dayActivitiesForDay(day))
            .toList(),
        day,
        occasion,
      );

  @override
  Future<void> close() async {
    await _activitiesSubscription.cancel();
    await _dayPickerSubscription.cancel();
    return super.close();
  }
}
