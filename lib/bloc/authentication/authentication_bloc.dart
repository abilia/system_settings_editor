import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final DatabaseRepository databaseRepository;
  final BaseUrlDb baseUrlDb;
  final CancelNotificationsFunction cancleAllNotificationsFunction;

  AuthenticationBloc(
      {@required this.databaseRepository,
      @required this.baseUrlDb,
      @required this.cancleAllNotificationsFunction})
      : super(AuthenticationUninitialized());

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
        yield* _tryGetUser(repo, event.token);
      } else if (event is LoggedOut) {
        yield AuthenticationLoading.fromInitilized(state);
        yield* _logout(repo);
      }
    }
  }

  Stream<AuthenticationState> _tryGetUser(
      UserRepository repo, String token) async* {
    try {
      final user = await repo.me(token);
      yield Authenticated(token: token, userId: user.id, userRepository: repo);
    } on UnauthorizedException {
      yield* _logout(repo, token);
    } catch (_) {
      yield Unauthenticated(repo);
      // Do nothing
    }
  }

  Stream<AuthenticationState> _logout(UserRepository repo,
      [String token]) async* {
    await repo.logout(token);
    await databaseRepository.clearAll();
    await cancleAllNotificationsFunction();
    yield Unauthenticated.fromInitilized(state);
  }
}
