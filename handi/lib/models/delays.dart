class Delays {
  final Duration syncDelay;
  final Duration retryDelay;

  const Delays({
    this.syncDelay = const Duration(seconds: 3),
    this.retryDelay = const Duration(minutes: 1),
  });

  static const Delays zero = Delays(
    syncDelay: Duration.zero,
    retryDelay: Duration.zero,
  );
}
