part of 'authentication_bloc.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class ChangeRepository extends AuthenticationEvent {
  final UserRepository repository;
  const ChangeRepository(this.repository);

  @override
  List<Object> get props => [repository];
}

class CheckAuthentication extends AuthenticationEvent {}

class LoggedIn extends AuthenticationEvent {
  final String token;

  const LoggedIn({required this.token});

  @override
  List<Object> get props => [token];
}

enum LoggedOutReason {
  LICENSE_EXPIRED,
  LOG_OUT,
}

class LoggedOut extends AuthenticationEvent {
  final LoggedOutReason loggedOutReason;

  const LoggedOut({this.loggedOutReason = LoggedOutReason.LOG_OUT});
}

class NotReady extends AuthenticationEvent {}
