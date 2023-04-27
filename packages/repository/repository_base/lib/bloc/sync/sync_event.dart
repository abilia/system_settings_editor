abstract class SyncEvent {
  final String? id;

  const SyncEvent([this.id]);

  @override
  String toString() => '$runtimeType(${id ?? ''})';
}


