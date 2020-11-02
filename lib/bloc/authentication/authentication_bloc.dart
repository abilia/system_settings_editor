import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final Database database;
  final BaseUrlDb baseUrlDb;
  final CancelNotificationsFunction cancleAllNotificationsFunction;
  final SeagullLogger seagullLogger;

  AuthenticationBloc({
    @required this.database,
    @required this.baseUrlDb,
    @required this.cancleAllNotificationsFunction,
    @required this.seagullLogger,
  }) : super(AuthenticationUninitialized());

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (event is AppStarted) {
      final repo = event.repository;
      yield AuthenticationLoading(repo);
      await baseUrlDb.setBaseUrl(repo.baseUrl);
      final token = await repo.getToken();
      if (token != null) {
        yield* _tryGetUser(repo, token);
      } else {
        yield Unauthenticated(repo);
      }
    }

    final thisState = state;
    if (thisState is AuthenticationInitialized) {
      final repo = thisState.userRepository;

      if (event is LoggedIn) {
        yield AuthenticationLoading.fromInitilized(state);
        await repo.persistToken(event.token);
        yield* _tryGetUser(repo, event.token, newlyLoggedIn: true);
      } else if (event is LoggedOut) {
        yield AuthenticationLoading.fromInitilized(state);
        yield* _logout(repo, loggedOutReason: event.loggedOutReason);
      }
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
    await seagullLogger.sendLogsToBackend();
    await repo.logout(token);
    await DatabaseRepository.clearAll(database);
    await cancleAllNotificationsFunction();
    yield Unauthenticated.fromInitilized(
      state,
      loggedOutReason: loggedOutReason,
    );
  }
}
