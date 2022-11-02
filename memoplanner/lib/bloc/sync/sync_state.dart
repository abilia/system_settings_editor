part of 'sync_bloc.dart';

abstract class SyncState {}

abstract class SyncPerformed extends SyncState {}

class OneWaySyncPerformed extends SyncPerformed {}

class TwoWaySyncPerformed extends SyncPerformed {}

class SyncNotPerformed extends SyncState {}
