part of 'logout_sync_cubit.dart';

class LogoutSyncState extends Equatable {
  final LogoutWarning logoutWarning;
  final DirtyItems? dirtyItems;
  final bool isOnline;

  const LogoutSyncState({
    required this.logoutWarning,
    this.isOnline = false,
    this.dirtyItems,
  });

  @override
  List<Object?> get props => [
        logoutWarning,
        dirtyItems,
        isOnline,
      ];

  LogoutSyncState copyWith({
    LogoutWarning? logoutWarning,
    DirtyItems? dirtyItems,
    bool? isOnline,
  }) =>
      LogoutSyncState(
        logoutWarning: logoutWarning ?? this.logoutWarning,
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

enum LogoutWarning {
  firstWarningSyncFailed,
  firstWarningSyncing,
  firstWarningSuccess,
  secondWarningSyncFailed,
  secondWarningSyncing,
  secondWarningSuccess,
  licenseExpiredWarning;

  WarningStep get step {
    switch (this) {
      case LogoutWarning.firstWarningSyncFailed:
      case LogoutWarning.firstWarningSyncing:
      case LogoutWarning.firstWarningSuccess:
        return WarningStep.firstWarning;
      case LogoutWarning.secondWarningSyncFailed:
      case LogoutWarning.secondWarningSyncing:
      case LogoutWarning.secondWarningSuccess:
        return WarningStep.secondWarning;
      case LogoutWarning.licenseExpiredWarning:
        return WarningStep.licenseExpiredWarning;
    }
  }

  WarningSyncState get sync {
    switch (this) {
      case LogoutWarning.firstWarningSyncFailed:
      case LogoutWarning.secondWarningSyncFailed:
      case LogoutWarning.licenseExpiredWarning:
        return WarningSyncState.syncFailed;
      case LogoutWarning.firstWarningSyncing:
      case LogoutWarning.secondWarningSyncing:
        return WarningSyncState.syncing;
      case LogoutWarning.firstWarningSuccess:
      case LogoutWarning.secondWarningSuccess:
        return WarningSyncState.syncedSuccess;
    }
  }
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
