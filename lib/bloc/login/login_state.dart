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
    required this.username,
    required this.password,
  });

  factory LoginState.initial() {
    return LoginState(
      username: '',
      password: '',
    );
  }

  LoginState copyWith({
    String? username,
    String? password,
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
    required LoginFailureCause cause,
  }) =>
      LoginFailure._(
        username,
        password,
        cause: cause,
      );

  @override
  List<Object> get props => [username, password];

  @override
  bool get stringify => true;
}

enum LoginFailureCause {
  noUsername,
  noPassword,
  credentials,
  noConnection,
  licenseExpired,
  noLicense,
  unsupportedUserType,
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
    required this.cause,
  }) : super(
          username: username,
          password: password,
        );

  @override
  LoginFailure failure({
    required LoginFailureCause cause,
  }) =>
      LoginFailure._(
        username,
        password,
        cause: cause,
      );

  bool get licenseError =>
      cause == LoginFailureCause.licenseExpired ||
      cause == LoginFailureCause.noLicense;

  @override
  bool get credentialError => cause == LoginFailureCause.credentials;
  @override
  bool get usernameError =>
      cause == LoginFailureCause.noUsername || credentialError;
  @override
  bool get passwordError =>
      cause == LoginFailureCause.noPassword || credentialError;

  @override
  List<Object> get props => [
        ...super.props,
        cause,
      ];
}
