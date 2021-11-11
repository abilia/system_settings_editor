part of 'sync_bloc.dart';

abstract class SyncState {
  const SyncState();
}

class SyncDone extends SyncState {
  const SyncDone();
}

abstract class SyncUnavailable extends SyncState {
  const SyncUnavailable();
}

class SyncPending extends SyncUnavailable {
  const SyncPending();
}

class SyncFailed extends SyncUnavailable {
  const SyncFailed();
}
