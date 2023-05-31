part of 'sync_bloc.dart';

abstract class SyncEvent {
  const SyncEvent();
}

class SyncAll extends SyncEvent {
  const SyncAll();
}

class SyncActivities extends SyncEvent {
  const SyncActivities();
}

class SyncFiles extends SyncEvent {
  const SyncFiles();
}

class SyncGenerics extends SyncEvent {
  const SyncGenerics();
}

class SyncSortables extends SyncEvent {
  const SyncSortables();
}
