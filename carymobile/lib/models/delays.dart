class Delays {
  final Duration syncDelay;
  final Duration retryDelay;
  final Duration scheduleNotificationsDelay;

  const Delays({
    this.syncDelay = const Duration(seconds: 3),
    this.retryDelay = const Duration(minutes: 1),
    this.scheduleNotificationsDelay = const Duration(seconds: 2),
  });

  static const Delays zero = Delays(
    syncDelay: Duration.zero,
    retryDelay: Duration.zero,
    scheduleNotificationsDelay: Duration.zero,
  );
}
