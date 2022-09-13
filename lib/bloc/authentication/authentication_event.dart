part of 'authentication_bloc.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class CheckAuthentication extends AuthenticationEvent {}

class LoggedIn extends AuthenticationEvent {
  const LoggedIn();
}

enum LoggedOutReason {
  licenseExpired,
  logOut,
  unauthorized,
  noLicense,
}

class LoggedOut extends AuthenticationEvent {
  final LoggedOutReason loggedOutReason;

  const LoggedOut({this.loggedOutReason = LoggedOutReason.logOut});
}

class NotReady extends AuthenticationEvent {}
