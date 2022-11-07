import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';

part 'activities_event.dart';

part 'activities_state.dart';

class ActivitiesBloc extends Bloc<ActivitiesEvent, ActivitiesState>
    with EditRecurringMixin {
  final ActivityRepository activityRepository;
  final SyncBloc syncBloc;
  late final StreamSubscription _syncSubscription;

  ActivitiesBloc({
    required this.activityRepository,
    required this.syncBloc,
  }) : super(ActivitiesNotLoaded()) {
    _syncSubscription =
        syncBloc.stream.listen((state) => add(LoadActivities()));
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
      emit(ActivitiesLoaded());
    } catch (_) {
      emit(ActivitiesLoadedFailed());
    }
  }

  Future _mapAddActivityToState(
    AddActivity event,
    Emitter<ActivitiesState> emit,
  ) async {
    await _saveActivities([event.activity]);
    emit(ActivitiesLoaded());
  }

  Future _mapDeleteActivityToState(
    DeleteActivity event,
    Emitter<ActivitiesState> emit,
  ) async {
    await _saveActivities([event.activity.copyWith(deleted: true)]);
    emit(ActivitiesLoaded());
  }

  Future _mapUpdateActivityToState(
    UpdateActivity event,
    Emitter<ActivitiesState> emit,
  ) async {
    await _saveActivities([event.activity]);
    emit(ActivitiesLoaded());
  }

  Future _mapDeleteRecurringToState(
    DeleteRecurringActivity event,
    Emitter<ActivitiesState> emit,
  ) async {
    final series =
        (await activityRepository.getBySeries(event.activity.seriesId)).toSet();
    final activity = event.activity;
    switch (event.applyTo) {
      case ApplyTo.allDays:
        await _saveActivities(series.map((a) => a.copyWith(deleted: true)));
        emit(ActivitiesLoaded());
        break;
      case ApplyTo.thisDayAndForward:
        await _handleResult(
          deleteThisDayAndForwardToState(
            activities: series,
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
            activities: series,
            day: event.day,
          ),
          emit,
        );
        break;
    }
  }

  Future<void> _mapUpdateRecurringToState(
    UpdateRecurringActivity event,
    Emitter<ActivitiesState> emit,
  ) async {
    final series =
        (await activityRepository.getBySeries(event.activity.seriesId)).toSet();
    switch (event.applyTo) {
      case ApplyTo.thisDayAndForward:
        await _handleResult(
          updateThisDayAndForward(
            activity: event.activity,
            activities: series,
            day: event.day,
          ),
          emit,
        );
        break;
      case ApplyTo.onlyThisDay:
        await _handleResult(
          updateOnlyThisDay(
            activities: series,
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
    emit(ActivitiesLoaded());
  }

  Future<void> _saveActivities(Iterable<Activity> activities) async {
    await activityRepository.save(activities);
    syncBloc.add(const ActivitySaved());
  }

  @override
  Future<void> close() async {
    await _syncSubscription.cancel();
    return super.close();
  }
}
