part of 'sync_bloc.dart';

abstract class SyncState extends Equatable {
  const SyncState();
  @override
  List<Object> get props => [];
}

class SyncInitial extends SyncState {}

class SyncDone extends SyncState {}

class SyncPending extends SyncState {}

class SyncFailed extends SyncState {}
