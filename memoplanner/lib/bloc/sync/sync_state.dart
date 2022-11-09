part of 'sync_bloc.dart';

abstract class SyncState {}

class Syncing extends SyncState {}

abstract class SyncDone extends SyncState {}

class Synced extends SyncDone {}

class SyncedFailed extends SyncDone {}
