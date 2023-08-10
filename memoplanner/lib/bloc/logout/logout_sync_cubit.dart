import 'dart:async';

import 'package:abilia_sync/abilia_sync.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/utils/myabilia_connection.dart';
import 'package:seagull_logging/seagull_logging.dart';

part 'logout_sync_state.dart';

class LogoutSyncCubit extends Cubit<LogoutSyncState> with Finest {
  LogoutSyncCubit({
    required this.syncBloc,
    required this.syncDelay,
    required this.licenseCubit,
    required Stream<ConnectivityResult> connectivity,
    required this.myAbiliaConnection,
    required this.authenticationBloc,
    required this.activityDb,
    required this.userFileDb,
    required this.sortableDb,
    required this.genericDb,
  }) : super(const LogoutSyncState(
          logoutWarning: LogoutWarning.firstWarningSyncFailed,
        )) {
    unawaited(_setLogoutWarning());
    unawaited(_fetchDirtyItems());
    unawaited(_checkConnectivity());

    _syncSubscription = syncBloc.stream.listen((_) async {
      await _setLogoutWarning();
      await _fetchDirtyItems();
    });

    _connectivitySubscription =
        connectivity.listen((cr) async => _checkConnectivity());

    _licenseSubscription = licenseCubit.stream.listen((_) async {
      await _setLogoutWarning();
      await _checkConnectivity();
    });
  }

  final Duration syncDelay;
  final SyncBloc syncBloc;
  final LicenseCubit licenseCubit;
  final AuthenticationBloc authenticationBloc;
  final MyAbiliaConnection myAbiliaConnection;
  late final StreamSubscription _syncSubscription;
  late final StreamSubscription _connectivitySubscription;
  late final StreamSubscription _licenseSubscription;
  late final log = Logger((LogoutSyncCubit).toString());
  final ActivityDb activityDb;
  final UserFileDb userFileDb;
  final SortableDb sortableDb;
  final GenericDb genericDb;

  Future<void> next() async {
    if (state.logoutWarning.syncedSuccess) {
      return authenticationBloc.add(const LoggedOut());
    }

    switch (state.logoutWarning.step) {
      case WarningStep.firstWarning:
        return _setLogoutWarning(step: WarningStep.secondWarning);
      case WarningStep.secondWarning:
        if (state.isOnline && !licenseCubit.validLicense) {
          return _setLogoutWarning(step: WarningStep.licenseExpiredWarning);
        }
        return authenticationBloc.add(const LoggedOut());
      case WarningStep.licenseExpiredWarning:
        return authenticationBloc.add(const LoggedOut());
    }
  }

  Future<void> _setLogoutWarning({
    WarningStep? step,
    bool forceSyncing = false,
  }) async {
    Future<LogoutWarning> getWarning({
      required WarningStep warningStep,
      required bool forcedSyncing,
    }) async {
      final hasDirtyItems = await syncBloc.hasDirty();

      final validLicense = licenseCubit.validLicense;
      if (state.isOnline && !validLicense) {
        return LogoutWarning.licenseExpiredWarning;
      }

      final syncing =
          syncBloc.state is! SyncedFailed && state.isOnline && hasDirtyItems;

      switch (warningStep) {
        case WarningStep.firstWarning:
          if (!hasDirtyItems) return LogoutWarning.firstWarningSuccess;
          if (syncing) return LogoutWarning.firstWarningSyncing;
          return LogoutWarning.firstWarningSyncFailed;
        case WarningStep.secondWarning:
        case WarningStep.licenseExpiredWarning:
          if (!validLicense &&
              hasDirtyItems &&
              warningStep == WarningStep.licenseExpiredWarning) {
            return LogoutWarning.licenseExpiredWarning;
          }
          if (!hasDirtyItems) return LogoutWarning.secondWarningSuccess;
          if (syncing) return LogoutWarning.secondWarningSyncing;
          return LogoutWarning.secondWarningSyncFailed;
      }
    }

    final logoutWarning = await getWarning(
      warningStep: step ?? state.logoutWarning.step,
      forcedSyncing: forceSyncing,
    );
    if (isClosed) return;
    emit(state.copyWith(logoutWarning: logoutWarning));
  }

  Future<void> _checkConnectivity({int retry = 0}) async {
    final isOnline = await myAbiliaConnection.hasConnection();
    if (isClosed) return;
    emit(state.copyWith(isOnline: isOnline));
    if (!isOnline) {
      if (retry > 3) return;
      log.warning(
        'No connection to myAbilia, retrying in ${syncDelay.inSeconds} seconds.',
      );
      await Future.delayed(
        syncDelay,
        () => _checkConnectivity(retry: retry + 1),
      );
    }

    final hasDirtyItems = await syncBloc.hasDirty();
    if (isClosed) return;
    if (hasDirtyItems && !state.logoutWarning.syncing) {
      log.warning(
          'Is online, adding ${(SyncAll).toString()} event to ${(SyncBloc).toString()}.');
      syncBloc.add(const SyncAll());
      await _setLogoutWarning(forceSyncing: true);
    }

    if (!licenseCubit.validLicense) {
      log.warning('Is online, no valid license. Reloading licenses.');
      await licenseCubit.reloadLicenses();
    }
  }

  Future<void> _fetchDirtyItems() async {
    final dirtyActivities = await activityDb.countAllDirty();

    final dirtySortables = groupBy(
      await sortableDb.getAllDirty(),
      (sortable) => sortable.model.type,
    );
    final dirtyActivityTemplates =
        dirtySortables[SortableType.basicActivity]?.length ?? 0;
    final dirtyTimerTemplates =
        dirtySortables[SortableType.basicTimer]?.length ?? 0;

    final dirtyPhotos = (await userFileDb.getAllDirty())
        .where((userFile) => userFile.model.isImage)
        .length;

    final settingsDataDirty = await genericDb.countAllDirty() > 0;

    final dirtyItems = DirtyItems(
      activities: dirtyActivities,
      activityTemplates: dirtyActivityTemplates,
      timerTemplate: dirtyTimerTemplates,
      photos: dirtyPhotos,
      settingsData: settingsDataDirty,
    );

    if (isClosed) return;
    emit(state.copyWith(dirtyItems: dirtyItems));
  }

  @override
  Future<void> close() async {
    await _syncSubscription.cancel();
    await _connectivitySubscription.cancel();
    await _licenseSubscription.cancel();
    return super.close();
  }
}
