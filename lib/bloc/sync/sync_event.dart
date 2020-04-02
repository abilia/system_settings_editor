part of 'sync_bloc.dart';

abstract class SyncEvent extends Equatable {
  const SyncEvent();
  @override
  List<Object> get props => [];
}

class ActivitySaved extends SyncEvent {}

class FileSaved extends SyncEvent {}

class SortableSaved extends SyncEvent {}
