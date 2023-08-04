part of 'logout_sync_bloc.dart';

class LogoutSyncEvent {}

class FetchDirtyItemsEvent extends LogoutSyncEvent {}

class LogoutWarningEvent extends LogoutSyncEvent {
  final WarningStep? step;

  LogoutWarningEvent({this.step});
}

class CheckConnectivityEvent extends LogoutSyncEvent {}
