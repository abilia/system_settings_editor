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
      case firstWarningSyncFailed:
      case firstWarningSyncing:
      case firstWarningSuccess:
        return WarningStep.firstWarning;
      case secondWarningSyncFailed:
      case secondWarningSyncing:
      case secondWarningSuccess:
        return WarningStep.secondWarning;
      case licenseExpiredWarning:
        return WarningStep.licenseExpiredWarning;
    }
  }

  bool get syncing =>
      this == firstWarningSyncing || this == secondWarningSyncing;
  bool get syncedSuccess =>
      this == firstWarningSuccess || this == secondWarningSuccess;
  bool get syncedFailed =>
      this == firstWarningSyncFailed ||
      this == secondWarningSyncFailed ||
      this == licenseExpiredWarning;
}

enum WarningStep {
  firstWarning,
  secondWarning,
  licenseExpiredWarning;
}
