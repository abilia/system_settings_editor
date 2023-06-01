class SyncDelays {
  final Duration betweenSync;
  final Duration retryDelay;
  final Duration scheduleNotificationsDelay;
  final Duration inactivityDelay;
  final Duration stopRemoteSoundDelay;

  const SyncDelays({
    this.betweenSync = const Duration(seconds: 3),
    this.retryDelay = const Duration(minutes: 1),
    this.scheduleNotificationsDelay = const Duration(seconds: 2),
    this.inactivityDelay = const Duration(seconds: 5),
    this.stopRemoteSoundDelay = const Duration(milliseconds: 100),
  });

  static const SyncDelays zero = SyncDelays(
    betweenSync: Duration.zero,
    retryDelay: Duration.zero,
    scheduleNotificationsDelay: Duration.zero,
    inactivityDelay: Duration.zero,
    stopRemoteSoundDelay: Duration.zero,
  );
}
