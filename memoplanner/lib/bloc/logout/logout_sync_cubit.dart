import 'dart:async';
import 'package:collection/collection.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/utils/myabilia_connection.dart';

class LogoutSyncCubit extends Cubit<LogoutSyncState> {
  LogoutSyncCubit({
    required this.syncBloc,
    required this.licenseCubit,
    required Stream<ConnectivityResult> connectivity,
    required this.myAbiliaConnection,
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
        _checkConnectivity();
      }
    });
  }

  static const _retryCheckConnectivityDelay = Duration(seconds: 5);
  final SyncBloc syncBloc;
  final LicenseCubit licenseCubit;
  final MyAbiliaConnection myAbiliaConnection;
  late final StreamSubscription _syncSubscription;
  late final StreamSubscription _connectivitySubscription;

  void setWarningStep(WarningStep warningStep) {
    emit(state.copyWith(warningStep: warningStep));
  }

  Future<void> _checkConnectivity() async {
    final isOnline = await myAbiliaConnection.hasConnection();
    if (isClosed) {
      return;
    }
    if (isOnline) {
      emit(state.copyWith(
        warningSyncState: WarningSyncState.syncing,
        isOnline: isOnline,
      ));
      syncBloc.add(const SyncAll());
      if (!licenseCubit.validLicense) {
        licenseCubit.reloadLicenses();
      }
    } else {
      emit(state.copyWith(isOnline: isOnline));
      await Future.delayed(_retryCheckConnectivityDelay);
      _checkConnectivity();
    }
  }

  Future<void> _fetchDirtyItems() async {
    final dirtyActivities =
        await syncBloc.activityRepository.db.countAllDirty();

    final dirtySortables = groupBy(
      await syncBloc.sortableRepository.db.getAllDirty(),
      (sortable) => sortable.model.type,
    );
    final dirtyActivityTemplates =
        dirtySortables[SortableType.basicActivity]?.length ?? 0;
    final dirtyTimerTemplates =
        dirtySortables[SortableType.basicTimer]?.length ?? 0;

    final dirtyPhotos = (await syncBloc.userFileRepository.db.getAllDirty())
        .where((userFile) => userFile.model.isImage)
        .length;

    final settingsDataDirty =
        await syncBloc.genericRepository.db.countAllDirty() > 0;

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
  final bool? isOnline;

  const LogoutSyncState({
    required this.warningSyncState,
    required this.warningStep,
    this.isOnline,
    this.dirtyItems,
  });

  @override
  List<Object?> get props => [
        dirtyItems,
        warningSyncState,
        warningStep,
        isOnline,
      ];

  LogoutSyncState copyWith({
    WarningSyncState? warningSyncState,
    WarningStep? warningStep,
    DirtyItems? dirtyItems,
    bool? isOnline,
  }) =>
      LogoutSyncState(
        warningSyncState: warningSyncState ?? this.warningSyncState,
        warningStep: warningStep ?? this.warningStep,
        dirtyItems: dirtyItems ?? this.dirtyItems,
        isOnline: isOnline ?? this.isOnline,
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
  secondWarning,
  licenseExpiredWarning;
}
