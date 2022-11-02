import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:logging/logging.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';

part 'create_account_state.dart';

class CreateAccountCubit extends Cubit<CreateAccountState> {
  final UserRepository repository;
  static final _log = Logger((CreateAccountCubit).toString());

  final String languageTag;
  CreateAccountCubit({
    required this.repository,
    required this.languageTag,
  }) : super(const CreateAccountState());

  void usernameEmailChanged(String username) {
    emit(state.copyWith(username: username));
  }

  void firstPasswordChanged(String password) {
    emit(state.copyWith(firstPassword: password));
  }

  void secondPasswordChanged(String password) {
    emit(state.copyWith(secondPassword: password));
  }

  void termsOfUseAccepted(bool accepted) {
    emit(state.copyWith(termsOfUse: accepted));
  }

  void privacyPolicyAccepted(bool accepted) {
    emit(state.copyWith(privacyPolicy: accepted));
  }

  void createAccountButtonPressed() async {
    emit(state.loading());
    if (state.username.isEmpty) {
      emit(state.failed(CreateAccountFailure.noUsername));
    } else if (!LoginCubit.usernameValid(state.username)) {
      emit(state.failed(CreateAccountFailure.usernameToShort));
    } else if (state.firstPassword.isEmpty) {
      emit(state.failed(CreateAccountFailure.noPassword));
    } else if (!CreateAccountCubit.passwordValid(state.firstPassword)) {
      emit(state.failed(CreateAccountFailure.passwordToShort));
    } else if (state.secondPassword.isEmpty) {
      emit(state.failed(CreateAccountFailure.noConfirmPassword));
    } else if (state.firstPassword != state.secondPassword) {
      emit(state.failed(CreateAccountFailure.passwordMismatch));
    } else if (!state.termsOfUse) {
      emit(state.failed(CreateAccountFailure.termsOfUse));
    } else if (!state.privacyPolicy) {
      emit(state.failed(CreateAccountFailure.privacyPolicy));
    } else {
      try {
        await repository.createAccount(
          usernameOrEmail: state.username,
          language: languageTag,
          password: state.firstPassword,
          termsOfUse: state.termsOfUse,
          privacyPolicy: state.privacyPolicy,
        );
        emit(state.success());
      } on CreateAccountException catch (exception) {
        final firstError =
            exception.badRequest.errors.firstWhereOrNull((_) => true);
        _log.warning('creating account failed: $exception');
        emit(state.failed(
          firstError?.failure ?? CreateAccountFailure.unknown,
        ));
      } catch (exception) {
        _log.warning('unknown exception when creating account: $exception');
        emit(state.failed(CreateAccountFailure.noConnection));
      }
    }
  }

  static const minPasswordCreateLength = 12;
  static bool passwordValid(String password) =>
      password.length >= minPasswordCreateLength;
}
