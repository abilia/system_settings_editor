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
  UserRepository _userRepository;

  AuthenticationBloc(
      {@required this.databaseRepository,
      @required this.baseUrlDb,
      @required this.cancleAllNotificationsFunction});

  @override
  AuthenticationState get initialState => AuthenticationUninitialized();

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (event is AppStarted) {
      yield AuthenticationLoading(event.repository);
      await baseUrlDb.setBaseUrl(event.repository.baseUrl);
      _userRepository = event.repository;
      final String token = await _userRepository.getToken();
      if (token != null) {
        yield* _tryGetUser(token);
      } else {
        yield Unauthenticated(event.repository);
      }
    }

    if (event is LoggedIn) {
      yield AuthenticationLoading.fromInitilized(state);
      await _userRepository.persistToken(event.token);
      yield* _tryGetUser(event.token);
    }
    if (event is LoggedOut) {
      yield AuthenticationLoading.fromInitilized(state);
      yield* _logout();
    }
  }

  Stream<AuthenticationState> _tryGetUser(String token) async* {
    try {
      final user = await _userRepository.me(token);
      yield Authenticated(
          token: token, userId: user.id, userRepository: _userRepository);
    } on UnauthorizedException {
      yield* _logout(token);
    } catch (_) {
      // Do nothing
    }
  }

  Stream<AuthenticationState> _logout([String token]) async* {
    await _userRepository.logout(token);
    await databaseRepository.clearAll();
    await cancleAllNotificationsFunction();
    yield Unauthenticated.fromInitilized(state);
  }
}
