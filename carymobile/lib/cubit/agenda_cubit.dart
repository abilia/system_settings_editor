import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:calendar_events/calendar_events.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:seagull_clock/clock_cubit.dart';
import 'package:utils/utils.dart';

part 'agenda_state.dart';

class AgendaCubit extends Cubit<AgendaState> {
  final ActivityRepository activityRepository;
  final ClockCubit clock;
  late final StreamSubscription activitySubscription,
      daySubscription,
      clockSubscription;

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
    clockSubscription = clock.stream.listen((now) {
      switch (state) {
        case AgendaLoaded(occasions: final occasions):
          _stateOccasion(occasions.values.flattened, now);
        case AgendaLoading():
      }
    });
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
    final dayActivities = activities.expand(
      (activity) => activity.dayActivitiesForDay(day),
    );
    _stateOccasion(dayActivities, now);
  }

  void _stateOccasion(
    Iterable<ActivityDay> dayActivities,
    DateTime now,
  ) {
    final occasions = dayActivities.map(
      (dayActivity) => dayActivity.toOccasion(now),
    );
    final grouped = groupBy(occasions, (o) => o.occasion);
    emit(AgendaLoaded(occasions: grouped, day: now.onlyDays()));
  }

  @override
  Future<void> close() {
    activitySubscription.cancel();
    daySubscription.cancel();
    clockSubscription.cancel();
    return super.close();
  }
}
