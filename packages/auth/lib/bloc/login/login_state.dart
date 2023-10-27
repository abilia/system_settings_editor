part of 'login_cubit.dart';

class LoginState extends Equatable {
  final String username;
  final String password;
  final bool obscurePassword;

  bool get isUsernameValid => LoginCubit.usernameValid(username);

  bool get isPasswordValid => LoginCubit.passwordValid(password);

  bool get isFormValid => isUsernameValid && isPasswordValid;

  bool get credentialError => false;

  bool get passwordError => false;

  bool get usernameError => false;

  const LoginState({
    required this.username,
    required this.password,
    required this.obscurePassword,
  });

  factory LoginState.initial() => const LoginState(
        username: '',
        password: '',
        obscurePassword: true,
      );

  LoginState copyWith({
    String? username,
    String? password,
    bool? obscurePassword,
  }) =>
      LoginState(
        username: username ?? this.username,
        password: password ?? this.password,
        obscurePassword: obscurePassword ?? this.obscurePassword,
      );

  LoginLoading loading() => LoginLoading._(
        username,
        password,
        obscurePassword,
      );

  LoginFailure failure({
    required LoginFailureCause cause,
  }) =>
      LoginFailure._(
        username,
        password,
        obscurePassword,
        cause: cause,
      );

  @override
  List<Object> get props => [
        username,
        password,
        obscurePassword,
      ];
}

enum LoginFailureCause {
  noUsername,
  noPassword,
  credentials,
  noConnection,
  licenseExpired,
  noLicense,
  unsupportedUserType,
  notEmptyDatabase,
  tooManyAttempts,
}

class LoginSucceeded extends LoginState {
  const LoginSucceeded()
      : super(
          username: '',
          password: '',
          obscurePassword: true,
        );
}

class LoginLoading extends LoginState {
  const LoginLoading._(
    String username,
    String password,
    bool obscurePassword,
  ) : super(
          username: username,
          password: password,
          obscurePassword: obscurePassword,
        );
}

class LoginFailure extends LoginState {
  final LoginFailureCause cause;

  const LoginFailure._(
    String username,
    String password,
    bool obscurePassword, {
    required this.cause,
  }) : super(
          username: username,
          password: password,
          obscurePassword: obscurePassword,
        );

  @override
  LoginFailure failure({
    required LoginFailureCause cause,
  }) =>
      LoginFailure._(
        username,
        password,
        obscurePassword,
        cause: cause,
      );

  bool get noLicense => cause == LoginFailureCause.noLicense;

  bool get licenseExpired => cause == LoginFailureCause.licenseExpired;

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
