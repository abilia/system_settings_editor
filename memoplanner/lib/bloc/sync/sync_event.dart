part of 'sync_bloc.dart';

abstract class SyncEvent {
  final String? id;

  const SyncEvent([this.id]);

  @override
  String toString() => '$runtimeType(${id ?? ''})';
}

class SyncAll extends SyncEvent {
  const SyncAll() : super();
}

class ActivitySaved extends SyncEvent {
  const ActivitySaved([String? id]) : super(id);
}

class FileSaved extends SyncEvent {
  const FileSaved([String? id]) : super(id);
}

class SortableSaved extends SyncEvent {
  const SortableSaved([String? id]) : super(id);
}

class GenericSaved extends SyncEvent {
  const GenericSaved([String? id]) : super(id);
}

class FakeSync extends SyncEvent {
  const FakeSync();
}
