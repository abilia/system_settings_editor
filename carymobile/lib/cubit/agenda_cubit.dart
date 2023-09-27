import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:calendar_events/calendar_events.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull_clock/clock_cubit.dart';
import 'package:utils/utils.dart';

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
  }) : super(AgendaLoading(day: clock.state.onlyDays())) {
    activitySubscription =
        onActivityUpdate.listen((event) async => _load(clock.state));
    daySubscription =
        clock.stream.where((now) => !state.day.isAtSameDay(now)).listen(_load);
    clockSubscription = clock.stream.listen((now) {
      _stateOccasion(state.occasions.values.flattened, now);
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

@immutable
sealed class AgendaState extends Equatable {
  const AgendaState({
    required this.occasions,
    required this.day,
  });
  final DateTime day;
  final Map<Occasion, List<ActivityDay>> occasions;

  List<ActivityDay> get pastActivities => occasions[Occasion.past] ?? [];
  List<ActivityDay> get notPastActivities => [
        ...occasions[Occasion.current] ?? [],
        ...occasions[Occasion.future] ?? []
      ];

  @override
  List<Object?> get props => [occasions, day];
}

@immutable
final class AgendaLoading extends AgendaState {
  const AgendaLoading({required DateTime day})
      : super(day: day, occasions: const {});
}

@immutable
final class AgendaLoaded extends AgendaState {
  const AgendaLoaded({required super.occasions, required super.day});
}
