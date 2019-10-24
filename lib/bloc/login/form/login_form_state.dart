import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class LoginFormState extends Equatable {
  final String username;
  final bool isUsernameValid;
  final String password;
  final bool isPasswordValid;
  final bool hasPassword;
  final bool hidePassword;

  bool get isFormValid => isUsernameValid && isPasswordValid;

  const LoginFormState({
    @required this.username,
    @required this.isUsernameValid,
    @required this.password,
    @required this.isPasswordValid,
    @required this.hasPassword,
    @required this.hidePassword,
  });

  factory LoginFormState.initial() {
    return LoginFormState(
      username: '',
      isUsernameValid: false,
      password: '',
      isPasswordValid: false,
      hasPassword: false,
      hidePassword: true,
    );
  }

  LoginFormState copyWith({
    String username,
    bool isUsernameValid,
    String password,
    bool isPasswordValid,
    bool hasPassword,
    bool hidePassword,
  }) {
    return LoginFormState(
      username: username ?? this.username,
      isUsernameValid: isUsernameValid ?? this.isUsernameValid,
      password: password ?? this.password,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      hasPassword: hasPassword ?? this.hasPassword,
      hidePassword: hidePassword ?? this.hidePassword,
    );
  }

  @override
  List<Object> get props => [
        username,
        isUsernameValid,
        password,
        isPasswordValid,
        hasPassword,
        hidePassword,
      ];

  @override
  String toString() {
    return '''LoginFormState {
      username: $username,
      isUserNameValid: $isUsernameValid,
      password length: ${password.length},
      isPasswordValid: $isPasswordValid,
      hasPassword: $hasPassword
      hidePassword: $hidePassword
    }''';
  }
}
