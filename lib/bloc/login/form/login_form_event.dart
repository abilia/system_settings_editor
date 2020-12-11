part of 'login_form_bloc.dart';

abstract class LoginFormEvent extends Equatable with Finest {
  const LoginFormEvent();

  @override
  List<Object> get props => [];
  @override
  bool get stringify => true;
}

class UsernameChanged extends LoginFormEvent {
  final String username;

  const UsernameChanged({@required this.username});

  @override
  List<Object> get props => [username];
}

class PasswordChanged extends LoginFormEvent {
  final String password;

  const PasswordChanged({@required this.password});

  @override
  List<Object> get props => [password];
}

class HidePasswordToggle extends LoginFormEvent {}

class FormSubmitted extends LoginFormEvent {}

class ResetForm extends LoginFormEvent {}
