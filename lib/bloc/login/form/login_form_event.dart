import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc/mixin/mixin.dart';

@immutable
abstract class LoginFormEvent extends Equatable with Silent {
  const LoginFormEvent();

  @override
  List<Object> get props => [];
}

class UsernameChanged extends LoginFormEvent {
  final String username;

  const UsernameChanged({@required this.username});

  @override
  List<Object> get props => [username];

  @override
  String toString() => 'UsernameChanged { username: $username }';
}

class PasswordChanged extends LoginFormEvent {
  final String password;

  const PasswordChanged({@required this.password});

  @override
  List<Object> get props => [password];

  @override
  String toString() => 'PasswordChanged { password: $password }';
}

class HidePasswordToggle extends LoginFormEvent {}

class FormSubmitted extends LoginFormEvent {}
