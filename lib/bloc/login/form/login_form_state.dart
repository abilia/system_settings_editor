import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class LoginFormState extends Equatable {
  final String username;
  final bool isUsernameValid;
  final String password;
  final bool isPasswordValid;
  final bool hidePassword;
  final bool formSubmitted;

  bool get isFormValid => isUsernameValid && isPasswordValid;

  const LoginFormState({
    @required this.username,
    @required this.isUsernameValid,
    @required this.password,
    @required this.isPasswordValid,
    @required this.hidePassword,
    @required this.formSubmitted
  });

  factory LoginFormState.initial() {
    return LoginFormState(
      username: '',
      isUsernameValid: false,
      password: '',
      isPasswordValid: false,
      hidePassword: true,
      formSubmitted: false
    );
  }

  LoginFormState copyWith({
    String username,
    bool isUsernameValid,
    String password,
    bool isPasswordValid,
    bool hidePassword,
    bool formSubmitted,
  }) {
    return LoginFormState(
      username: username ?? this.username,
      isUsernameValid: isUsernameValid ?? this.isUsernameValid,
      password: password ?? this.password,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      hidePassword: hidePassword ?? this.hidePassword,
      formSubmitted: formSubmitted ?? this.formSubmitted
    );
  }

  @override
  List<Object> get props => [
        username,
        isUsernameValid,
        password,
        isPasswordValid,
        hidePassword,
        formSubmitted,
      ];

  @override
  String toString() {
    return '''LoginFormState {
      username: $username,
      isUserNameValid: $isUsernameValid,
      password length: ${password.length},
      isPasswordValid: $isPasswordValid,
      hidePassword: $hidePassword
      formSubmitted: $formSubmitted
    }''';
  }
}
