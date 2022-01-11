part of 'sync_bloc.dart';

abstract class SyncEvent {
  final String? id;

  const SyncEvent([this.id]);

  String toString() => '$runtimeType(${id ?? ''})';
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
