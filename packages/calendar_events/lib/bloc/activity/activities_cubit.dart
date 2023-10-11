import 'dart:async';

import 'package:abilia_sync/abilia_sync.dart';
import 'package:bloc/bloc.dart';
import 'package:calendar_events/calendar_events.dart';
import 'package:seagull_analytics/seagull_analytics.dart';

class ActivitiesChanged {}

class ActivitiesCubit extends Cubit<ActivitiesChanged> with EditRecurringMixin {
  final ActivityRepository activityRepository;
  final SyncBloc syncBloc;
  final SeagullAnalytics analytics;
  late final StreamSubscription _syncSubscription;

  ActivitiesCubit({
    required this.activityRepository,
    required this.syncBloc,
    required this.analytics,
  }) : super(ActivitiesChanged()) {
    _syncSubscription = syncBloc.stream
        .where((state) => state is Synced && state.didFetchData)
        .listen((_) => notifyChange());
  }

  void notifyChange() => emit(ActivitiesChanged());

  Future<Iterable<Activity>> getActivitiesAfter(DateTime time) {
    return activityRepository.allAfter(time);
  }

  Future<void> updateActivity(Activity activity) => _saveActivities([activity]);

  Future<void> addActivity(Activity activity) async {
    analytics.trackEvent(
      AnalyticsEvents.activityCreated,
      properties: activity.analyticsProperties,
    );
    return _saveActivities([activity]);
  }

  Future<void> updateRecurringActivity(
    ActivityDay activityDay,
    ApplyTo applyTo,
  ) async {
    final savableActivities =
        await mapUpdateRecurringToState(activityDay, applyTo);
    await _saveActivities(savableActivities);
  }

  Future<void> deleteRecurringActivity(
    ActivityDay activityDay,
    ApplyTo applyTo,
  ) async {
    final savableActivities = await mapDeleteRecurringToState(
      activityDay,
      applyTo,
    );
    await _saveActivities(savableActivities);
  }

  Future<void> _saveActivities(Iterable<Activity> savableActivities) async {
    await activityRepository.save(savableActivities);
    syncBloc.add(const SyncActivities());
    if (isClosed) return;
    emit(ActivitiesChanged());
  }

  Future<Iterable<Activity>> mapUpdateRecurringToState(
    ActivityDay activityDay,
    ApplyTo applyTo,
  ) async {
    final activity = activityDay.activity;
    final day = activityDay.day;
    final series =
        (await activityRepository.getBySeries(activity.seriesId)).toSet();
    switch (applyTo) {
      case ApplyTo.thisDayAndForward:
        return updateThisDayAndForward(
          activity: activity,
          activities: series,
          day: day,
        );
      case ApplyTo.onlyThisDay:
        return updateOnlyThisDay(
          activities: series,
          activity: activity,
          day: day,
        );
      case ApplyTo.allDays:
        throw UpdateActivityApplyToAllDaysError();
    }
  }

  Future<Iterable<Activity>> mapDeleteRecurringToState(
    ActivityDay activityDay,
    ApplyTo applyTo,
  ) async {
    final activity = activityDay.activity;
    final day = activityDay.day;
    final series =
        (await activityRepository.getBySeries(activity.seriesId)).toSet();
    switch (applyTo) {
      case ApplyTo.allDays:
        return series.map((a) => a.copyWith(deleted: true));
      case ApplyTo.thisDayAndForward:
        return deleteThisDayAndForwardToState(
          activities: series,
          activity: activity,
          day: day,
        );
      case ApplyTo.onlyThisDay:
        return deleteOnlyThisDay(
          activity: activity,
          activities: series,
          day: day,
        );
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
