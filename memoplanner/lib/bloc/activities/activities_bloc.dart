import 'dart:async';

import 'package:abilia_sync/abilia_sync.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:seagull_analytics/seagull_analytics.dart';

part 'activities_event.dart';

class ActivitiesChanged {}

class ActivitiesBloc extends Bloc<ActivitiesEvent, ActivitiesChanged>
    with EditRecurringMixin {
  final ActivityRepository activityRepository;
  final SyncBloc syncBloc;
  late final StreamSubscription _syncSubscription;

  ActivitiesBloc({
    required this.activityRepository,
    required this.syncBloc,
  }) : super(ActivitiesChanged()) {
    _syncSubscription = syncBloc.stream
        .where((state) => state is Synced && state.didFetchData)
        .listen((_) => add(LoadActivities()));
    on<ActivitiesEvent>(_onEvent, transformer: sequential());
  }

  Future _onEvent(
    ActivitiesEvent event,
    Emitter<ActivitiesChanged> emit,
  ) async {
    if (event is ManipulateActivitiesEvent) {
      final savableActivities = await _manipulateActivity(event);
      await activityRepository.save(savableActivities);
      syncBloc.add(const SyncActivities());
    }
    emit(ActivitiesChanged());
  }

  FutureOr<Iterable<Activity>> _manipulateActivity(
    ManipulateActivitiesEvent event,
  ) {
    if (event is UpdateRecurringActivity) {
      return _mapUpdateRecurringToState(event);
    } else if (event is DeleteRecurringActivity) {
      return _mapDeleteRecurringToState(event);
    }
    return [event.activity];
  }

  Future<Iterable<Activity>> _mapDeleteRecurringToState(
    DeleteRecurringActivity event,
  ) async {
    final series =
        (await activityRepository.getBySeries(event.activity.seriesId)).toSet();
    final activity = event.activity;
    switch (event.applyTo) {
      case ApplyTo.allDays:
        return series.map((a) => a.copyWith(deleted: true));
      case ApplyTo.thisDayAndForward:
        return deleteThisDayAndForwardToState(
          activities: series,
          activity: activity,
          day: event.day,
        );
      case ApplyTo.onlyThisDay:
        return deleteOnlyThisDay(
          activity: activity,
          activities: series,
          day: event.day,
        );
    }
  }

  Future<Iterable<Activity>> _mapUpdateRecurringToState(
    UpdateRecurringActivity event,
  ) async {
    final series =
        (await activityRepository.getBySeries(event.activity.seriesId)).toSet();
    switch (event.applyTo) {
      case ApplyTo.thisDayAndForward:
        return updateThisDayAndForward(
          activity: event.activity,
          activities: series,
          day: event.day,
        );
      case ApplyTo.onlyThisDay:
        return updateOnlyThisDay(
          activities: series,
          activity: event.activity,
          day: event.day,
        );
      case ApplyTo.allDays:
        throw UpdateActivityApplyToAllDaysError();
    }
  }

  @override
  Future<void> close() async {
    await _syncSubscription.cancel();
    return super.close();
  }
}

class UpdateActivityApplyToAllDaysError extends Error {
  @override
  String toString() => 'Cannot apply a change to all days in a series';
}
