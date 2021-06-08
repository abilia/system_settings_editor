// @dart=2.9

part of 'create_account_bloc.dart';

class CreateAccountState extends Equatable {
  final String username, firstPassword, secondPassword;
  final bool termsOfUse, privacyPolicy;

  const CreateAccountState({
    this.username = '',
    this.firstPassword = '',
    this.secondPassword = '',
    this.termsOfUse = false,
    this.privacyPolicy = false,
  });

  CreateAccountState copyWith({
    String username,
    String firstPassword,
    String secondPassword,
    bool termsOfUse,
    bool privacyPolicy,
  }) =>
      CreateAccountState(
        username: username ?? this.username,
        firstPassword: firstPassword ?? this.firstPassword,
        secondPassword: secondPassword ?? this.secondPassword,
        termsOfUse: termsOfUse ?? this.termsOfUse,
        privacyPolicy: privacyPolicy ?? this.privacyPolicy,
      );

  CreateAccountFailed failed(CreateAccountFailure failure) =>
      CreateAccountFailed(
        failure,
        username,
        firstPassword,
        secondPassword,
        termsOfUse,
        privacyPolicy,
      );

  CreateAccountLoading loading() => CreateAccountLoading(
        username,
        firstPassword,
        secondPassword,
        termsOfUse,
        privacyPolicy,
      );

  AccountCreated success() => AccountCreated(username);

  bool get usernameFailure => false;
  bool get passwordFailure => false;
  bool get conformPasswordFailure => false;
  bool get termsOfUseFailure => false;
  bool get privacyPolicyFailure => false;

  @override
  List<Object> get props => [
        username,
        firstPassword,
        secondPassword,
        termsOfUse,
        privacyPolicy,
      ];
}

class CreateAccountLoading extends CreateAccountState {
  const CreateAccountLoading(
    String username,
    String firstPassword,
    String secondPassword,
    bool termsOfUse,
    bool privacyPolicy,
  ) : super(
          username: username,
          firstPassword: firstPassword,
          secondPassword: secondPassword,
          termsOfUse: termsOfUse,
          privacyPolicy: privacyPolicy,
        );
}

class CreateAccountFailed extends CreateAccountState {
  final CreateAccountFailure failure;

  const CreateAccountFailed(
    this.failure,
    String username,
    String firstPassword,
    String secondPassword,
    bool termsOfUse,
    bool privacyPolicy,
  ) : super(
          username: username,
          firstPassword: firstPassword,
          secondPassword: secondPassword,
          termsOfUse: termsOfUse,
          privacyPolicy: privacyPolicy,
        );

  @override
  bool get usernameFailure =>
      failure == CreateAccountFailure.UsernameToShort ||
      failure == CreateAccountFailure.NoUsername ||
      failure == CreateAccountFailure.UsernameTaken;

  bool get passwordMismatch => failure == CreateAccountFailure.PasswordMismatch;

  @override
  bool get passwordFailure =>
      passwordMismatch ||
      failure == CreateAccountFailure.NoPassword ||
      failure == CreateAccountFailure.PasswordToShort;

  @override
  bool get conformPasswordFailure =>
      passwordMismatch || failure == CreateAccountFailure.NoConfirmPassword;

  @override
  bool get termsOfUseFailure => failure == CreateAccountFailure.TermsOfUse;

  @override
  bool get privacyPolicyFailure =>
      failure == CreateAccountFailure.PrivacyPolicy;

  @override
  List<Object> get props => [failure, super.props];
}

class AccountCreated extends CreateAccountState {
  const AccountCreated(String username) : super(username: username);
}
