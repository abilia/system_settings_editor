import 'package:equatable/equatable.dart';

abstract class SyncState extends Equatable {
  final DateTime? lastSynced;
  const SyncState({this.lastSynced});
  @override
  List<Object?> get props => [lastSynced];
}

class Syncing extends SyncState {
  const Syncing({super.lastSynced});
}

abstract class SyncDone extends SyncState {
  const SyncDone({super.lastSynced});
}

class Synced extends SyncDone {
  final bool didFetchData;
  const Synced({required this.didFetchData, super.lastSynced});
  @override
  List<Object?> get props => [lastSynced, didFetchData];
}

class SyncedFailed extends SyncDone {
  const SyncedFailed({super.lastSynced});
}
