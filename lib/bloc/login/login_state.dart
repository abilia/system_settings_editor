part of 'login_bloc.dart';

class LoginState extends Equatable {
  final String username;
  final String password;

  bool get isUsernameValid => LoginBloc.usernameValid(username);
  bool get isPasswordValid => LoginBloc.passwordValid(password);
  bool get isFormValid => isUsernameValid && isPasswordValid;

  bool get credentialError => false;
  bool get passwordError => false;
  bool get usernameError => false;

  const LoginState({
    @required this.username,
    @required this.password,
  });

  factory LoginState.initial() {
    return LoginState(
      username: '',
      password: '',
    );
  }

  LoginState copyWith({
    String username,
    String password,
  }) =>
      LoginState(
        username: username ?? this.username,
        password: password ?? this.password,
      );

  LoginLoading loading() => LoginLoading._(
        username,
        password,
      );

  LoginFailure failure({
    LoginFailureCause cause,
  }) =>
      LoginFailure._(
        username,
        password,
        cause: cause,
      );

  @override
  List<Object> get props => [
        username,
        password,
      ];

  @override
  bool get stringify => true;
}

enum LoginFailureCause {
  NoUsername,
  NoPassword,
  Credentials,
  NoConnection,
  LicenseExpired,
  NoLicense,
}

class LoginSucceeded extends LoginState {
  const LoginSucceeded() : super(username: '', password: '');
}

class LoginLoading extends LoginState {
  const LoginLoading._(
    String username,
    String password,
  ) : super(
          username: username,
          password: password,
        );
}

class LoginFailure extends LoginState {
  final LoginFailureCause cause;

  const LoginFailure._(
    String username,
    String password, {
    @required this.cause,
  }) : super(
          username: username,
          password: password,
        );

  @override
  LoginFailure failure({
    LoginFailureCause cause,
  }) =>
      LoginFailure._(
        username,
        password,
        cause: cause,
      );

  bool get licenseError =>
      cause == LoginFailureCause.LicenseExpired ||
      cause == LoginFailureCause.NoLicense;

  @override
  bool get credentialError => cause == LoginFailureCause.Credentials;
  @override
  bool get usernameError =>
      cause == LoginFailureCause.NoUsername || credentialError;
  @override
  bool get passwordError =>
      cause == LoginFailureCause.NoPassword || credentialError;

  @override
  List<Object> get props => [
        ...super.props,
        cause,
      ];
}
