// @dart=2.9

part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable with Finest {
  const LoginEvent();

  @override
  List<Object> get props => [];
  @override
  bool get stringify => true;
}

class UsernameChanged extends LoginEvent {
  final String username;

  const UsernameChanged(this.username);

  @override
  List<Object> get props => [username];
}

class PasswordChanged extends LoginEvent {
  final String password;

  const PasswordChanged(this.password);

  @override
  List<Object> get props => [password];
}

class ClearFailure extends LoginEvent {}

class LoginButtonPressed extends LoginEvent {}
