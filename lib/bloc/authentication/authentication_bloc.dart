// @dart=2.9

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final FutureOr<void> Function() onLogout;

  AuthenticationBloc(
    UserRepository userRepository, {
    this.onLogout,
  }) : super(AuthenticationLoading(userRepository));

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    final repo = state.userRepository;

    if (event is NotReady) {
      await Future.delayed(const Duration(milliseconds: 50));
      yield state._forceNew();
    } else if (event is ChangeRepository) {
      yield Unauthenticated(
        event.repository,
        forcedNewState: state.forcedNewState,
      );
    } else if (event is CheckAuthentication) {
      final token = state.userRepository.getToken();
      if (token != null) {
        yield* _tryGetUser(repo, token);
      } else {
        yield Unauthenticated(repo);
      }
    } else if (event is LoggedIn) {
      await repo.persistToken(event.token);
      yield* _tryGetUser(repo, event.token, newlyLoggedIn: true);
    } else if (event is LoggedOut) {
      yield* _logout(repo, loggedOutReason: event.loggedOutReason);
    }
  }

  Stream<AuthenticationState> _tryGetUser(
    UserRepository repo,
    String token, {
    bool newlyLoggedIn = false,
  }) async* {
    try {
      final user = await repo.me(token);
      yield Authenticated(
        token: token,
        userId: user.id,
        userRepository: repo,
        newlyLoggedIn: newlyLoggedIn,
      );
    } on UnauthorizedException {
      yield* _logout(
        repo,
        token: token,
      );
    } catch (_) {
      yield Unauthenticated(repo);
      // Do nothing
    }
  }

  Stream<AuthenticationState> _logout(
    UserRepository repo, {
    String token,
    LoggedOutReason loggedOutReason = LoggedOutReason.LOG_OUT,
  }) async* {
    try {
      await onLogout?.call();
    } catch (e) {
      Logger('onLogout').severe('exception when logging out: $e');
    } finally {
      yield Unauthenticated(
        state.userRepository,
        loggedOutReason: loggedOutReason,
      );
    }
    await repo.logout(token);
  }
}
