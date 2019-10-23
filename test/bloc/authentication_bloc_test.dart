import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/authentication/bloc.dart';
import 'package:seagull/repository/user_repository.dart';

import 'mocks.dart';

void main() {
  group('AuthenticationBloc event order', () {
    AuthenticationBloc authenticationBloc;

    setUp(() {
      authenticationBloc = AuthenticationBloc(userRepository: UserRepository(client: MockHttpClient()));
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
    UserRepository mockedUserRepository;

    setUp(() {
      mockedUserRepository = MockUserRepository();
      authenticationBloc = AuthenticationBloc(userRepository: mockedUserRepository);
      when(mockedUserRepository.hasToken()).thenAnswer((_) => Future.value(false));
    });

    test('loggedIn event saves token', () async {
      authenticationBloc.add(AppStarted());
      final theToken = 'a token';
      authenticationBloc.add(LoggedIn(token: theToken));
      await untilCalled(mockedUserRepository.persistToken(theToken));
    });

    test('loggedOut calls deletes token', () async {
      authenticationBloc.add(AppStarted());
      authenticationBloc.add(LoggedOut());
      await untilCalled(mockedUserRepository.deleteToken());
    });

    tearDown(() {
      authenticationBloc.close();
    });
  }); 
}

