part of 'sync_bloc.dart';

abstract class SyncState {
  final DateTime? lastSynced;
  SyncState({this.lastSynced});
}

class Syncing extends SyncState {
  Syncing({super.lastSynced});
}

abstract class SyncDone extends SyncState {
  SyncDone({super.lastSynced});
}

class Synced extends SyncDone {
  Synced({super.lastSynced});
}

class SyncedFailed extends SyncDone {
  SyncedFailed({super.lastSynced});
}
