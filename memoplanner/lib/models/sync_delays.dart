class SyncDelays {
  final Duration betweenSync;
  final Duration retryDelay;
  final Duration scheduleNotificationsDelay;

  const SyncDelays({
    this.betweenSync = const Duration(seconds: 3),
    this.retryDelay = const Duration(minutes: 1),
    this.scheduleNotificationsDelay = const Duration(seconds: 2),
  });

  static const SyncDelays zero = SyncDelays(
    betweenSync: Duration.zero,
    retryDelay: Duration.zero,
    scheduleNotificationsDelay: Duration.zero,
  );
}
