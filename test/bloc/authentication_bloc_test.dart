import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/authentication/bloc.dart';
import 'package:seagull/fakes/fake_client.dart';
import 'package:seagull/models/user.dart';
import 'package:seagull/repository/user_repository.dart';

import 'mocks.dart';

void main() {
  group('AuthenticationBloc event order', () {
    AuthenticationBloc authenticationBloc;
    setUp(() {
      authenticationBloc = AuthenticationBloc(
          userRepository: UserRepository(
              httpClient: Fakes.client, secureStorage: MockSecureStorage()));
    });

    test('initial state is AuthenticationUninitialized', () {
      expect(authenticationBloc.initialState, AuthenticationUninitialized());
    });

    test('state change to Unauthenticated when app starts', () {
      final List<AuthenticationState> expected = [
        AuthenticationUninitialized(),
        AuthenticationLoading(),
        Unauthenticated()
      ];

      expectLater(
        authenticationBloc,
        emitsInOrder(expected),
      );

      authenticationBloc.add(AppStarted());
    });

    test('state change to AuthenticationAuthenticated when token provided', () {
      final List<AuthenticationState> expected = [
        AuthenticationUninitialized(),
        AuthenticationLoading(),
        Unauthenticated(),
        AuthenticationLoading(),
        Authenticated(token: Fakes.token, userId: Fakes.userId),
      ];

      expectLater(
        authenticationBloc,
        emitsInOrder(expected),
      );

      authenticationBloc.add(AppStarted());
      authenticationBloc.add(LoggedIn(token: Fakes.token));
    });

    test('state change back to Unauthenticated when loggin out', () {
      final List<AuthenticationState> expected = [
        AuthenticationUninitialized(),
        AuthenticationLoading(),
        Unauthenticated(),
        AuthenticationLoading(),
        Authenticated(token: Fakes.token, userId: Fakes.userId),
        AuthenticationLoading(),
        Unauthenticated(),
      ];

      expectLater(
        authenticationBloc,
        emitsInOrder(expected),
      );

      authenticationBloc.add(AppStarted());
      authenticationBloc.add(LoggedIn(token: Fakes.token));
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
      authenticationBloc =
          AuthenticationBloc(userRepository: mockedUserRepository);
      when(mockedUserRepository.getToken())
          .thenAnswer((_) => Future.value(Fakes.token));
      when(mockedUserRepository.me(any))
          .thenAnswer((_) => Future.value(User(id: 0, type: '', name: '')));
    });

    test('loggedIn event saves token', () async {
      authenticationBloc.add(AppStarted());
      final theToken = Fakes.token;
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
