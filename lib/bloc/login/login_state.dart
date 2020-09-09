part of 'login_bloc.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
  @override
  bool get stringify => true;
}

class LoginSucceeded extends LoginState {}

class LoginLoading extends LoginState {}

enum LoginFailureCause {
  Credentials,
  NoConnection,
  License,
}

class LoginFailure extends LoginState {
  final String error;
  final LoginFailureCause loginFailureCause;

  const LoginFailure({
    @required this.error,
    @required this.loginFailureCause,
  });

  @override
  List<Object> get props => [
        error,
        loginFailureCause,
      ];
}
