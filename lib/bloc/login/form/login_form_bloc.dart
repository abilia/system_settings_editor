import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/logging.dart';

part 'login_form_event.dart';
part 'login_form_state.dart';

class LoginFormBloc extends Bloc<LoginFormEvent, LoginFormState> {
  LoginFormBloc() : super(LoginFormState.initial());

  @override
  Stream<LoginFormState> mapEventToState(
    LoginFormEvent event,
  ) async* {
    if (event is UsernameChanged && event.username != state.username) {
      yield state.copyWith(
        username: event.username,
        isUsernameValid: _isUsernameValid(event.username),
        formSubmitted: false,
      );
    }
    if (event is PasswordChanged && event.password != state.password) {
      yield state.copyWith(
        password: event.password,
        isPasswordValid: _isPasswordValid(event.password),
        formSubmitted: false,
      );
    }
    if (event is HidePasswordToggle) {
      yield state.copyWith(
        hidePassword: !state.hidePassword,
      );
    }
    if (event is FormSubmitted) {
      yield state.copyWith(formSubmitted: true);
    }
  }

  bool _isUsernameValid(String username) => username.length > 2;

  bool _isPasswordValid(String password) => password.length > 2;
}
