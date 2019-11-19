import 'dart:async';

import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:seagull/bloc.dart';
import 'package:seagull/repositories.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository userRepository;

  AuthenticationBloc({@required this.userRepository})
      : assert(userRepository != null);

  @override
  AuthenticationState get initialState => AuthenticationUninitialized();

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    yield AuthenticationLoading();
    if (event is AppStarted) {
      final String token = await userRepository.getToken();
      if (token != null) {
        yield* _tryGetUser(token);
      }
      else yield Unauthenticated();
    } 

    if (event is LoggedIn) {
      await userRepository.persistToken(event.token);
      yield* _tryGetUser(event.token);
    }

    if (event is LoggedOut) {
      await userRepository.deleteToken();
      yield Unauthenticated();
    }
  }

  Stream<AuthenticationState> _tryGetUser(String token) async* {
    try {
      final user = await userRepository.me(token);
      yield Authenticated(token: token, userId: user.id);
    } catch (_) {
      await userRepository.deleteToken();
      yield Unauthenticated();
    }
  }
}
