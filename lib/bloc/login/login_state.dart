part of 'login_bloc.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
  @override
  bool get stringify => true;
}

class LoginInitial extends LoginState {}

class LoginSucceeded extends LoginState {}

class LoginLoading extends LoginState {}

enum LoginFailureCause {
  Credentials,
  NoConnection,
  LicenseExpired,
  NoLicense,
}

class LoginFailure extends LoginState {
  final String error;
  final LoginFailureCause loginFailureCause;

  const LoginFailure({
    @required this.error,
    @required this.loginFailureCause,
  });

  bool get licenseError =>
      loginFailureCause == LoginFailureCause.LicenseExpired ||
      loginFailureCause == LoginFailureCause.NoLicense;

  @override
  List<Object> get props => [
        error,
        loginFailureCause,
      ];
}
