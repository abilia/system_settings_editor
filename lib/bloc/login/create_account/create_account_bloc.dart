import 'dart:async';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:logging/logging.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';

part 'create_account_event.dart';
part 'create_account_state.dart';

class CreateAccountBloc extends Bloc<CreateAccountEvent, CreateAccountState> {
  final UserRepository repository;
  static final _log = Logger((CreateAccountBloc).toString());

  final String languageTag;
  CreateAccountBloc({
    required this.repository,
    required this.languageTag,
  }) : super(const CreateAccountState());

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
      yield state.loading();
      yield* _mapCreateAccountEventToState();
    }
  }

  Stream<CreateAccountState> _mapCreateAccountEventToState() async* {
    if (state.username.isEmpty) {
      yield state.failed(CreateAccountFailure.noUsername);
    } else if (!LoginBloc.usernameValid(state.username)) {
      yield state.failed(CreateAccountFailure.usernameToShort);
    } else if (state.firstPassword.isEmpty) {
      yield state.failed(CreateAccountFailure.noPassword);
    } else if (!LoginBloc.passwordValid(state.firstPassword)) {
      yield state.failed(CreateAccountFailure.passwordToShort);
    } else if (state.secondPassword.isEmpty) {
      yield state.failed(CreateAccountFailure.noConfirmPassword);
    } else if (state.firstPassword != state.secondPassword) {
      yield state.failed(CreateAccountFailure.passwordMismatch);
    } else if (!state.termsOfUse) {
      yield state.failed(CreateAccountFailure.termsOfUse);
    } else if (!state.privacyPolicy) {
      yield state.failed(CreateAccountFailure.privacyPolicy);
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
        final firstError =
            exception.badRequest.errors.firstWhereOrNull((_) => true);
        _log.warning('creating account failed: $exception');
        yield state.failed(
          firstError?.failure ?? CreateAccountFailure.unknown,
        );
      } catch (exception) {
        _log.warning('unknown exception when creating account: $exception');
        yield state.failed(CreateAccountFailure.noConnection);
      }
    }
  }
}
