import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';

class LoginFormBloc extends Bloc<LoginFormEvent, LoginFormState> {
  @override
  LoginFormState get initialState => LoginFormState.initial();

  @override
  Stream<LoginFormState> mapEventToState(
    LoginFormEvent event,
  ) async* {
    if (event is UsernameChanged) {
      yield state.copyWith(
        username: event.username,
        isUsernameValid: _isUsernameValid(event.username),
      );
    }
    if (event is PasswordChanged) {
      yield state.copyWith(
        password: event.password,
        isPasswordValid: _isPasswordValid(event.password),
        hasPassword: _hasPassword(event.password)
      );
    }
    if (event is HidePasswordToggle) {
      yield state.copyWith(
        hidePassword: !state.hidePassword,
      );
    }
  }

  bool _isUsernameValid(String username) => username.length > 2;

  bool _isPasswordValid(String password) => password.length > 2;

  bool _hasPassword(String password) => password.length > 0;

}
