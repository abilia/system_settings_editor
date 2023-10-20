import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:calendar_events/calendar_events.dart';
import 'package:equatable/equatable.dart';
import 'package:seagull_clock/clock_cubit.dart';
import 'package:utils/utils.dart';

part 'agenda_state.dart';

class AgendaCubit extends Cubit<AgendaState> {
  final ActivityRepository activityRepository;
  final ClockCubit clock;
  late final StreamSubscription activitySubscription, daySubscription;

  AgendaCubit({
    required Stream onActivityUpdate,
    required this.clock,
    required this.activityRepository,
  }) : super(const AgendaLoading()) {
    activitySubscription =
        onActivityUpdate.listen((event) async => _load(clock.state));
    daySubscription = clock.stream.where((now) {
      final s = state;
      if (s is! AgendaLoaded) return false;
      return !s.day.isAtSameDay(now);
    }).listen(_load);
    unawaited(_load(clock.state));
  }

  Future<void> _load(DateTime now) async {
    final day = now.onlyDays();
    final yesterday = day.previousDay();
    final nextDay = day.nextDay();
    final activities = await activityRepository.allBetween(
      yesterday,
      nextDay,
    );
    final dayActivities = activities
        .where(
          (activity) => activity.showInDayplan,
        )
        .expand(
          (activity) => activity.dayActivitiesForDay(day),
        )
        .toList()
      ..sort();
    emit(AgendaLoaded(activities: dayActivities, day: now.onlyDays()));
  }

  @override
  Future<void> close() {
    activitySubscription.cancel();
    daySubscription.cancel();
    return super.close();
  }
}
