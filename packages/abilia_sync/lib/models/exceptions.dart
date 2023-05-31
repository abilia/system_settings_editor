class SyncFailedException implements Exception {
  SyncFailedException([this.e]);
  final Exception? e;
  @override
  String toString() => 'Sync failed $e';
}
