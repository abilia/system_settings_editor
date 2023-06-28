class Delays {
  final Duration syncDelay;
  final Duration retryDelay;
  final Duration scheduleNotificationsDelay;
  final Duration inactivityDelay;
  final Duration stopRemoteSoundDelay;
  final Duration spamProtectionDelay;

  const Delays({
    this.syncDelay = const Duration(seconds: 3),
    this.retryDelay = const Duration(minutes: 1),
    this.scheduleNotificationsDelay = const Duration(seconds: 2),
    this.inactivityDelay = const Duration(seconds: 5),
    this.stopRemoteSoundDelay = const Duration(milliseconds: 100),
    this.spamProtectionDelay = const Duration(milliseconds: 250),
  });

  static const Delays zero = Delays(
    syncDelay: Duration.zero,
    retryDelay: Duration.zero,
    scheduleNotificationsDelay: Duration.zero,
    inactivityDelay: Duration.zero,
    stopRemoteSoundDelay: Duration.zero,
    spamProtectionDelay: Duration.zero,
  );
}
