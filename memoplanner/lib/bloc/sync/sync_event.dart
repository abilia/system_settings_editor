part of 'sync_bloc.dart';

class SyncAll extends SyncEvent {
  const SyncAll() : super();
}

class ActivitySaved extends SyncEvent {
  const ActivitySaved([String? id]) : super(id);
}

class FileSaved extends SyncEvent {
  const FileSaved([String? id]) : super(id);
}

class GenericSaved extends SyncEvent {
  const GenericSaved([String? id]) : super(id);
}
