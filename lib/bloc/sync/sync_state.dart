part of 'sync_bloc.dart';

abstract class SyncState extends Equatable {
  const SyncState();
}

class SyncInitial extends SyncState {
  @override
  List<Object> get props => [];
}

class SyncDone extends SyncState {

  SyncDone();
  @override
  List<Object> get props => [];
}

class SyncPending extends SyncState {
  @override
  List<Object> get props => null;
}

class SyncFailed extends SyncState {
  @override
  List<Object> get props => null;
}
