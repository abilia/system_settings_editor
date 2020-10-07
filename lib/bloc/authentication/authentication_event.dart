part of 'authentication_bloc.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

class AppStarted extends AuthenticationEvent {
  final UserRepository repository;
  AppStarted(this.repository);
}

class LoggedIn extends AuthenticationEvent {
  final String token;

  const LoggedIn({@required this.token});

  @override
  List<Object> get props => [token];

  @override
  String toString() => 'LoggedIn { token: $token }';
}

enum LoggedOutReason {
  LICENSE_EXPIRED,
  LOG_OUT,
}

class LoggedOut extends AuthenticationEvent {
  final LoggedOutReason loggedOutReason;

  LoggedOut({this.loggedOutReason = LoggedOutReason.LOG_OUT});
}
