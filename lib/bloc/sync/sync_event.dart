part of 'sync_bloc.dart';

abstract class SyncEvent {
  const SyncEvent();
}

class ActivitySaved extends SyncEvent {
  const ActivitySaved();
}

class FileSaved extends SyncEvent {
  const FileSaved();
}

class SortableSaved extends SyncEvent {
  const SortableSaved();
}

class GenericSaved extends SyncEvent {
  const GenericSaved();
}
