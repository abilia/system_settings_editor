import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/authentication/bloc.dart';
import 'package:seagull/repository/user_repository.dart';

import 'mock_user_repository.dart';

void main() {
  group('AuthenticationBloc event order', () {
    AuthenticationBloc authenticationBloc;

    setUp(() {
      authenticationBloc = AuthenticationBloc(userRepository: UserRepository());
    });

    test('initial state is AuthenticationUninitialized', () {
      expect(authenticationBloc.initialState, AuthenticationUninitialized());
    });

    test('state change to Unauthenticated when app starts', () {
      final List<AuthenticationState> expected = [
        AuthenticationUninitialized(),
        AuthenticationUnauthenticated()
      ];

      expectLater(
        authenticationBloc,
        emitsInOrder(expected),
      );

      authenticationBloc.add(AppStarted());
    });

    test('state change to AuthenticationAuthenticated when token provided',
        () {
      final List<AuthenticationState> expected = [
        AuthenticationUninitialized(),
        AuthenticationUnauthenticated(),
        AuthenticationLoading(),
        AuthenticationAuthenticated(),
      ];

      expectLater(
        authenticationBloc,
        emitsInOrder(expected),
      );

      authenticationBloc.add(AppStarted());
      authenticationBloc.add(LoggedIn(token: 'atoken'));
    });

    test('state change back to Unauthenticated when loggin out', () {
      final List<AuthenticationState> expected = [
        AuthenticationUninitialized(),
        AuthenticationUnauthenticated(),
        AuthenticationLoading(),
        AuthenticationAuthenticated(),
        AuthenticationLoading(),
        AuthenticationUnauthenticated(),
      ];

      expectLater(
        authenticationBloc,
        emitsInOrder(expected),
      );

      authenticationBloc.add(AppStarted());
      authenticationBloc.add(LoggedIn(token: 'a token'));
      authenticationBloc.add(LoggedOut());
    });

    tearDown(() {
      authenticationBloc.close();
    });
  }); 

    group('AuthenticationBloc token side effect', () {
    AuthenticationBloc authenticationBloc;
    UserRepository userRepository;

    setUp(() {
      userRepository = MockUserRepository();
      authenticationBloc = AuthenticationBloc(userRepository: userRepository);
    });

    test('loggedIn event saves token', () async {
      authenticationBloc.add(AppStarted());
      final theToken = 'a token';
      authenticationBloc.add(LoggedIn(token: theToken));

      await untilCalled(userRepository.persistToken(theToken));
    });

    test('loggedOut calls deletes token', () async {
      authenticationBloc.add(AppStarted());
      authenticationBloc.add(LoggedOut());
      await untilCalled(userRepository.deleteToken());
    });

    tearDown(() {
      authenticationBloc.close();
    });
  }); 
}

