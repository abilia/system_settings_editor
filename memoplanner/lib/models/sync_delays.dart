class SyncDelays {
  final Duration betweenSync;
  final Duration retryDelay;

  const SyncDelays({
    this.betweenSync = const Duration(seconds: 3),
    this.retryDelay = const Duration(minutes: 1),
  });

  static const SyncDelays zero = SyncDelays(
    betweenSync: Duration.zero,
    retryDelay: Duration.zero,
  );
}
