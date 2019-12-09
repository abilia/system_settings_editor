import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc.dart';
import 'package:seagull/db/baseurl_db.dart';
import 'package:seagull/db/sqflite.dart';
import 'package:seagull/models/exceptions.dart';
import 'package:seagull/repositories.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final DatabaseRepository databaseRepository;
  final BaseUrlDb baseUrlDb;
  UserRepository _userRepository;

  AuthenticationBloc(
      {@required this.databaseRepository, @required this.baseUrlDb});

  @override
  AuthenticationState get initialState => AuthenticationUninitialized();

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (event is AppStarted) {
      yield AuthenticationLoading(event.repository);
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
      yield* _logout();
    } catch (_) {
      // Do nothing
    }
  }

  Stream<AuthenticationState> _logout() async* {
    await _userRepository.logout();
    await databaseRepository.clearAll();
    yield Unauthenticated.fromInitilized(state);
  }
}
