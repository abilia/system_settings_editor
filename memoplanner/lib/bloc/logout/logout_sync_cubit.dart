import 'dart:async';
import 'package:collection/collection.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:memoplanner/logging/all.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/utils/myabilia_connection.dart';
part 'logout_sync_state.dart';

class LogoutSyncCubit extends Cubit<LogoutSyncState> with Finest {
  LogoutSyncCubit({
    required this.syncBloc,
    required this.syncDelay,
    required this.licenseCubit,
    required Stream<ConnectivityResult> connectivity,
    required this.myAbiliaConnection,
    required this.authenticationBloc,
  }) : super(const LogoutSyncState(
          logoutWarning: LogoutWarning.firstWarningSyncFailed,
        )) {
    _setLogoutWarning();
    _fetchDirtyItems();
    _checkConnectivity();

    _syncSubscription = syncBloc.stream
        .where((state) => state is! Syncing)
        .listen((syncState) async {
      _setLogoutWarning(
        sync: syncState is Synced
            ? licenseCubit.validLicense
                ? WarningSyncState.syncedSuccess
                : await syncBloc.hasDirty()
                    ? WarningSyncState.syncFailed
                    : WarningSyncState.syncedSuccess
            : WarningSyncState.syncFailed,
      );
      _fetchDirtyItems();
    });

    _connectivitySubscription = connectivity
        .where((cr) =>
            cr != ConnectivityResult.none &&
            state.logoutWarning.sync != WarningSyncState.syncing)
        .listen((cr) => _checkConnectivity());

    _licenseSubscription = licenseCubit.stream.listen((_) {
      _setLogoutWarning();
      _checkConnectivity();
    });
  }

  final SyncDelays syncDelay;
  final SyncBloc syncBloc;
  final LicenseCubit licenseCubit;
  final AuthenticationBloc authenticationBloc;
  final MyAbiliaConnection myAbiliaConnection;
  late final StreamSubscription _syncSubscription;
  late final StreamSubscription _connectivitySubscription;
  late final StreamSubscription _licenseSubscription;
  late final log = Logger((LogoutSyncCubit).toString());

  void next() {
    if (state.logoutWarning.sync == WarningSyncState.syncing) {
      return;
    }

    if (state.logoutWarning.sync == WarningSyncState.syncedSuccess) {
      return authenticationBloc.add(const LoggedOut());
    }

    switch (state.logoutWarning.step) {
      case WarningStep.firstWarning:
        return _setLogoutWarning(step: WarningStep.secondWarning);
      case WarningStep.secondWarning:
        if (state.isOnline == true) {
          return _setLogoutWarning(step: WarningStep.licenseExpiredWarning);
        } else {
          return authenticationBloc.add(const LoggedOut());
        }
      case WarningStep.licenseExpiredWarning:
        return authenticationBloc.add(const LoggedOut());
    }
  }

  void _setLogoutWarning({
    bool? isOnline,
    WarningStep? step,
    WarningSyncState? sync,
  }) {
    final validLicense = licenseCubit.validLicense;
    final online = isOnline ?? state.isOnline;
    final warningStep = step ?? state.logoutWarning.step;
    final warningSyncState = sync ?? state.logoutWarning.sync;

    LogoutWarning getWarning() {
      if (online == true && !validLicense) {
        return LogoutWarning.licenseExpiredWarning;
      }
      switch (warningStep) {
        case WarningStep.firstWarning:
          switch (warningSyncState) {
            case WarningSyncState.syncing:
              return LogoutWarning.firstWarningSyncing;
            case WarningSyncState.syncedSuccess:
              return LogoutWarning.firstWarningSuccess;
            case WarningSyncState.syncFailed:
              return LogoutWarning.firstWarningSyncFailed;
          }
        case WarningStep.secondWarning:
        case WarningStep.licenseExpiredWarning:
          if (!validLicense &&
              warningSyncState != WarningSyncState.syncedSuccess &&
              step == WarningStep.licenseExpiredWarning) {
            return LogoutWarning.licenseExpiredWarning;
          }
          switch (warningSyncState) {
            case WarningSyncState.syncing:
              return LogoutWarning.secondWarningSyncing;
            case WarningSyncState.syncedSuccess:
              return LogoutWarning.secondWarningSuccess;
            case WarningSyncState.syncFailed:
              return LogoutWarning.secondWarningSyncFailed;
          }
      }
    }

    emit(state.copyWith(logoutWarning: getWarning(), isOnline: online));
  }

  Future<void> _checkConnectivity() async {
    final isOnline = await myAbiliaConnection.hasConnection();
    final isSynced = state.logoutWarning.sync == WarningSyncState.syncedSuccess;
    if (isClosed) {
      return;
    }
    if (isOnline) {
      _setLogoutWarning(
        isOnline: isOnline,
        sync: isSynced ? null : WarningSyncState.syncing,
      );
      if (!isSynced) {
        log.finest(
            'Is online, adding ${(SyncAll).toString()} event to ${(SyncBloc).toString()}.');
        syncBloc.add(const SyncAll());
      }
      if (!licenseCubit.validLicense) {
        log.finest('Is online, no valid license. Reloading licenses.');
        licenseCubit.reloadLicenses();
      }
    } else {
      log.finest(
          'No connection to myAbilia, retrying in ${syncDelay.betweenSync.inSeconds} seconds.');
      emit(state.copyWith(isOnline: isOnline));
      await Future.delayed(syncDelay.betweenSync);
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
    await _licenseSubscription.cancel();
    return super.close();
  }
}
