import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';

part 'create_account_event.dart';
part 'create_account_state.dart';

class CreateAccountBloc extends Bloc<CreateAccountEvent, CreateAccountState> {
  final CreateAccountRepository repository;
  static final _log = Logger((CreateAccountBloc).toString());

  final String languageTag;
  CreateAccountBloc({
    @required this.repository,
    @required this.languageTag,
  }) : super(CreateAccountState());

  @override
  Stream<CreateAccountState> mapEventToState(
    CreateAccountEvent event,
  ) async* {
    if (event is UsernameEmailChanged) {
      yield state.copyWith(username: event.username);
    }
    if (event is FirstPasswordChanged) {
      yield state.copyWith(firstPassword: event.password);
    }
    if (event is SecondPasswordChanged) {
      yield state.copyWith(secondPassword: event.password);
    }
    if (event is TermsOfUse) {
      yield state.copyWith(termsOfUse: event.accepted);
    }
    if (event is PrivacyPolicy) {
      yield state.copyWith(privacyPolicy: event.accepted);
    }
    if (event is CreateAccountButtonPressed) {
      yield state.loadning();
      yield* _mapCreateAccountEventToState();
    }
  }

  Stream<CreateAccountState> _mapCreateAccountEventToState() async* {
    if (state.username.isEmpty) {
      yield state.failed(CreateAccountFailure.NoUsername);
    } else if (!LoginBloc.usernameValid(state.username)) {
      yield state.failed(CreateAccountFailure.UsernameToShort);
    } else if (state.firstPassword.isEmpty) {
      yield state.failed(CreateAccountFailure.NoPassword);
    } else if (!LoginBloc.passwordValid(state.firstPassword)) {
      yield state.failed(CreateAccountFailure.PasswordToShort);
    } else if (state.secondPassword.isEmpty) {
      yield state.failed(CreateAccountFailure.NoConfirmPassword);
    } else if (state.firstPassword != state.secondPassword) {
      yield state.failed(CreateAccountFailure.PasswordMismatch);
    } else if (!state.termsOfUse) {
      yield state.failed(CreateAccountFailure.TermsOfUse);
    } else if (!state.privacyPolicy) {
      yield state.failed(CreateAccountFailure.PrivacyPolicy);
    } else {
      try {
        await repository.createAccount(
          usernameOrEmail: state.username,
          language: languageTag,
          password: state.firstPassword,
          termsOfUse: state.termsOfUse,
          privacyPolicy: state.privacyPolicy,
        );
        yield state.success();
      } on CreateAccountException catch (exception) {
        final firstError = exception.errors.firstWhere(
          (_) => true,
          orElse: () => null,
        );
        yield state.failed(
          firstError?.failure ?? CreateAccountFailure.Unknown,
          message: firstError?.message ?? exception.message,
        );
      } catch (exception) {
        _log.warning('unknown exception when creating account: $exception');
        yield state.failed(CreateAccountFailure.NoConnection);
      }
    }
  }
}
