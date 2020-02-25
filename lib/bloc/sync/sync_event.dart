part of 'sync_bloc.dart';

abstract class SyncEvent extends Equatable {
  const SyncEvent();
}

class ActivitySaved extends SyncEvent {
  @override
  List<Object> get props => null;
}
