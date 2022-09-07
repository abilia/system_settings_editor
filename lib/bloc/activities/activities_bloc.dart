import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';

part 'activities_event.dart';
part 'activities_state.dart';

class ActivitiesBloc extends Bloc<ActivitiesEvent, ActivitiesState>
    with EditRecurringMixin {
  final ActivityRepository activityRepository;
  late final StreamSubscription pushSubscription;
  final SyncBloc syncBloc;

  ActivitiesBloc({
    required this.activityRepository,
    required this.syncBloc,
    required PushCubit pushCubit,
  }) : super(ActivitiesNotLoaded()) {
    pushSubscription = pushCubit.stream.listen((state) {
      if (state is PushReceived) {
        add(LoadActivities());
      }
    });
    on<ActivitiesEvent>(_onEvent, transformer: sequential());
  }

  Future _onEvent(
    ActivitiesEvent event,
    Emitter<ActivitiesState> emit,
  ) async {
    if (event is LoadActivities) {
      await _mapLoadActivitiesToState(event, emit);
    } else if (event is ManipulateActivitiesEvent) {
      if (event is AddActivity) {
        await _mapAddActivityToState(event, emit);
      } else if (event is UpdateActivity) {
        await _mapUpdateActivityToState(event, emit);
      } else if (event is DeleteActivity) {
        await _mapDeleteActivityToState(event, emit);
      } else if (event is UpdateRecurringActivity) {
        await _mapUpdateRecurringToState(event, emit);
      } else if (event is DeleteRecurringActivity) {
        await _mapDeleteRecurringToState(event, emit);
      }
    }
  }

  Future _mapLoadActivitiesToState(
    LoadActivities event,
    Emitter<ActivitiesState> emit,
  ) async {
    try {
      final activities = await activityRepository.load();
      emit(ActivitiesLoaded(activities));
    } catch (_) {
      emit(ActivitiesLoadedFailed());
    }
  }

  Future _mapAddActivityToState(
    AddActivity event,
    Emitter<ActivitiesState> emit,
  ) async {
    final activities = state.activities;
    await _saveActivities([event.activity]);
    emit(ActivitiesLoaded(activities.followedBy([event.activity])));
  }

  Future _mapDeleteActivityToState(
    DeleteActivity event,
    Emitter<ActivitiesState> emit,
  ) async {
    final activities = state.activities.toSet();
    if (activities.remove(event.activity)) {
      await _saveActivities([event.activity.copyWith(deleted: true)]);
      emit(ActivitiesLoaded(activities));
    }
  }

  Future _mapUpdateActivityToState(
    UpdateActivity event,
    Emitter<ActivitiesState> emit,
  ) async {
    final activities = state.activities;
    final activity = event.activity;
    final updatedActivities = activities.map<Activity>((a) {
      return a.id == activity.id ? activity : a;
    }).toList(growable: false);
    await _saveActivities([activity]);
    emit(ActivitiesLoaded(updatedActivities));
  }

  Future _mapDeleteRecurringToState(
    DeleteRecurringActivity event,
    Emitter<ActivitiesState> emit,
  ) async {
    final activities = state.activities.toSet();
    final activity = event.activity;
    switch (event.applyTo) {
      case ApplyTo.allDays:
        final series =
            activities.where((a) => a.seriesId == activity.seriesId).toSet();
        await _saveActivities(series.map((a) => a.copyWith(deleted: true)));
        emit(ActivitiesLoaded(activities.difference(series)));
        break;
      case ApplyTo.thisDayAndForward:
        await _handleResult(
          deleteThisDayAndForwardToState(
            activities: activities,
            activity: activity,
            day: event.day,
          ),
          emit,
        );
        break;
      case ApplyTo.onlyThisDay:
        await _handleResult(
          deleteOnlyThisDay(
            activity: activity,
            activities: activities,
            day: event.day,
          ),
          emit,
        );
        break;
    }
  }

  Future _mapUpdateRecurringToState(
    UpdateRecurringActivity event,
    Emitter<ActivitiesState> emit,
  ) async {
    final activities = state.activities.toSet();
    switch (event.applyTo) {
      case ApplyTo.thisDayAndForward:
        _handleResult(
          updateThisDayAndForward(
            activity: event.activity,
            activities: activities,
            day: event.day,
          ),
          emit,
        );
        break;
      case ApplyTo.onlyThisDay:
        _handleResult(
          updateOnlyThisDay(
            activities: activities,
            activity: event.activity,
            day: event.day,
          ),
          emit,
        );
        break;
      default:
    }
  }

  Future _handleResult(
    ActivityMappingResult res,
    Emitter<ActivitiesState> emit,
  ) async {
    await _saveActivities(res.save);
    emit(ActivitiesLoaded(res.state));
  }

  Future<void> _saveActivities(Iterable<Activity> activities) async {
    syncBloc.add(const ActivitySaved());
    await activityRepository.save(activities);
  }

  @override
  Future<void> close() async {
    await pushSubscription.cancel();
    return super.close();
  }
}
