part of 'create_account_bloc.dart';

abstract class CreateAccountEvent extends Equatable {
  const CreateAccountEvent();

  @override
  List<Object> get props => [];
}

class UsernameEmailChanged extends CreateAccountEvent {
  final String username;

  const UsernameEmailChanged(this.username);
  @override
  List<Object> get props => [username];
}

class _PasswordChanged extends CreateAccountEvent {
  final String password;

  const _PasswordChanged(this.password);
  @override
  List<Object> get props => [password];
}

class FirstPasswordChanged extends _PasswordChanged {
  const FirstPasswordChanged(String password) : super(password);
}

class SecondPasswordChanged extends _PasswordChanged {
  const SecondPasswordChanged(String password) : super(password);
}

class _Policy extends CreateAccountEvent {
  final bool accepted;

  const _Policy(this.accepted);
  @override
  List<Object> get props => [accepted];
}

class TermsOfUse extends _Policy {
  const TermsOfUse(bool accepted) : super(accepted);
}

class PrivacyPolicy extends _Policy {
  const PrivacyPolicy(bool accepted) : super(accepted);
}

class CreateAccountButtonPressed extends CreateAccountEvent {}
