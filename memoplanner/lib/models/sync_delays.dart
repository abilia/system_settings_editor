class SyncDelays {
  final Duration betweenSync;
  final Duration retryDelay;
  final Duration scheduleNotificationsDelay;
  final Duration screenSaver;

  const SyncDelays({
    this.betweenSync = const Duration(seconds: 3),
    this.retryDelay = const Duration(minutes: 1),
    this.scheduleNotificationsDelay = const Duration(seconds: 2),
    this.screenSaver = const Duration(seconds: 5),
  });

  static const SyncDelays zero = SyncDelays(
      betweenSync: Duration.zero,
      retryDelay: Duration.zero,
      scheduleNotificationsDelay: Duration.zero,
      screenSaver: Duration.zero);
}
