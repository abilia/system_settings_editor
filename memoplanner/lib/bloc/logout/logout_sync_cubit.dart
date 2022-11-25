import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';

class LogoutSyncCubit extends Cubit<LogoutSyncState> {
  LogoutSyncCubit({
    required this.syncBloc,
    required Stream<ConnectivityResult> connectivity,
  }) : super(LogoutSyncState(
          warningSyncState: _getLogoutSync(syncBloc.state),
          warningStep: WarningStep.firstWarning,
        )) {
    _fetchDirtyItems();
    _syncSubscription = syncBloc.stream.listen((syncState) {
      if (syncState is! Syncing) {
        emit(state.copyWith(warningSyncState: _getLogoutSync(syncState)));
      }
      _fetchDirtyItems();
    });
    _connectivitySubscription = connectivity.listen((cr) {
      if (cr != ConnectivityResult.none &&
          state.warningSyncState != WarningSyncState.syncing) {
        emit(state.copyWith(warningSyncState: WarningSyncState.syncing));
        syncBloc.add(const SyncAll());
      }
    });
  }

  final SyncBloc syncBloc;
  late final StreamSubscription _syncSubscription;
  late final StreamSubscription _connectivitySubscription;

  void setWarningStep(WarningStep warningStep) {
    emit(state.copyWith(warningStep: warningStep));
  }

  Future<void> _fetchDirtyItems() async {
    int dirtyActivityTemplates = 0;
    int dirtyTimerTemplates = 0;
    int dirtyPhotos = 0;

    final int dirtyActivities =
        (await syncBloc.activityRepository.db.getAllDirty()).length;

    final dirtySortables = await syncBloc.sortableRepository.db.getAllDirty();
    for (var sortable in dirtySortables) {
      if (sortable.model.data is BasicActivityData) {
        dirtyActivityTemplates++;
      } else if (sortable.model.data is BasicTimerData) {
        dirtyTimerTemplates++;
      }
    }

    final dirtyUserFiles = await syncBloc.userFileRepository.db.getAllDirty();
    for (var userFile in dirtyUserFiles) {
      if (userFile.model.isImage) {
        dirtyPhotos++;
      }
    }

    final settingsDataDirty =
        (await syncBloc.genericRepository.db.getAllDirty()).isNotEmpty;

    final dirtyItems = DirtyItems(
      activities: dirtyActivities,
      activityTemplates: dirtyActivityTemplates,
      timerTemplate: dirtyTimerTemplates,
      photos: dirtyPhotos,
      settingsData: settingsDataDirty,
    );

    if (!isClosed) {
      emit(state.copyWith(dirtyItems: dirtyItems));
    }
  }

  @override
  Future<void> close() async {
    await _syncSubscription.cancel();
    await _connectivitySubscription.cancel();
    return super.close();
  }
}

class LogoutSyncState extends Equatable {
  final DirtyItems? dirtyItems;
  final WarningSyncState warningSyncState;
  final WarningStep warningStep;

  const LogoutSyncState({
    required this.warningSyncState,
    required this.warningStep,
    this.dirtyItems,
  });

  @override
  List<Object?> get props => [
        dirtyItems,
        warningSyncState,
        warningStep,
      ];

  LogoutSyncState copyWith({
    WarningSyncState? warningSyncState,
    WarningStep? warningStep,
    DirtyItems? dirtyItems,
  }) =>
      LogoutSyncState(
        warningSyncState: warningSyncState ?? this.warningSyncState,
        warningStep: warningStep ?? this.warningStep,
        dirtyItems: dirtyItems ?? this.dirtyItems,
      );
}

class DirtyItems extends Equatable {
  const DirtyItems({
    required this.activities,
    required this.activityTemplates,
    required this.timerTemplate,
    required this.photos,
    required this.settingsData,
  });

  final int activities, activityTemplates, timerTemplate, photos;
  final bool settingsData;

  DirtyItems copyWith({
    int? activities,
    int? activityTemplates,
    int? timerTemplate,
    int? photos,
    bool? settingsData,
  }) =>
      DirtyItems(
        activities: activities ?? this.activities,
        activityTemplates: activityTemplates ?? this.activityTemplates,
        timerTemplate: timerTemplate ?? this.timerTemplate,
        photos: photos ?? this.photos,
        settingsData: settingsData ?? this.settingsData,
      );

  @override
  List<Object?> get props => [
        activities,
        activityTemplates,
        timerTemplate,
        photos,
        settingsData,
      ];
}

WarningSyncState _getLogoutSync(SyncState state) {
  return state is Synced
      ? WarningSyncState.syncedSuccess
      : WarningSyncState.syncFailed;
}

enum WarningSyncState {
  syncing,
  syncedSuccess,
  syncFailed;
}

enum WarningStep {
  firstWarning,
  secondWarning;
}
