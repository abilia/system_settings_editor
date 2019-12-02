import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/authentication/bloc.dart';
import 'package:seagull/fakes/fake_client.dart';
import 'package:seagull/models/exceptions.dart';
import 'package:seagull/models/user.dart';
import 'package:seagull/repository/user_repository.dart';

import '../../mocks.dart';

void main() {
  group('AuthenticationBloc event order', () {
    AuthenticationBloc authenticationBloc;
    UserRepository userRepository;
    setUp(() {
      userRepository = UserRepository(
          httpClient: Fakes.client(), secureStorage: MockSecureStorage());
      authenticationBloc = AuthenticationBloc();
    });

    test('initial state is AuthenticationUninitialized', () {
      expect(authenticationBloc.initialState, AuthenticationUninitialized());
    });

    test('state change to Unauthenticated when app starts', () {
      final List<AuthenticationState> expected = [
        AuthenticationUninitialized(),
        AuthenticationLoading(userRepository),
        Unauthenticated(userRepository)
      ];

      expectLater(
        authenticationBloc,
        emitsInOrder(expected),
      );

      authenticationBloc.add(AppStarted(userRepository));
    });

    test('state change to AuthenticationAuthenticated when token provided', () {
      final List<AuthenticationState> expected = [
        AuthenticationUninitialized(),
        AuthenticationLoading(userRepository),
        Unauthenticated(userRepository),
        AuthenticationLoading(userRepository),
        Authenticated(
          token: Fakes.token,
          userId: Fakes.userId,
          userRepository: userRepository,
        ),
      ];

      expectLater(
        authenticationBloc,
        emitsInOrder(expected),
      );

      authenticationBloc.add(AppStarted(userRepository));
      authenticationBloc.add(LoggedIn(token: Fakes.token));
    });

    test('state change back to Unauthenticated when loggin out', () {
      final List<AuthenticationState> expected = [
        AuthenticationUninitialized(),
        AuthenticationLoading(userRepository),
        Unauthenticated(userRepository),
        AuthenticationLoading(userRepository),
        Authenticated(
            token: Fakes.token,
            userId: Fakes.userId,
            userRepository: userRepository),
        AuthenticationLoading(userRepository),
        Unauthenticated(userRepository),
      ];

      expectLater(
        authenticationBloc,
        emitsInOrder(expected),
      );

      authenticationBloc.add(AppStarted(userRepository));
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
      authenticationBloc = AuthenticationBloc();
      when(mockedUserRepository.getToken())
          .thenAnswer((_) => Future.value(Fakes.token));
      when(mockedUserRepository.me(any))
          .thenAnswer((_) => Future.value(User(id: 0, type: '', name: '')));
    });

    test('loggedIn event saves token', () async {
      authenticationBloc.add(AppStarted(mockedUserRepository));
      final theToken = Fakes.token;
      authenticationBloc.add(LoggedIn(token: theToken));
      await untilCalled(mockedUserRepository.persistToken(theToken));
    });

    test('loggedOut calls deletes token', () async {
      authenticationBloc.add(AppStarted(mockedUserRepository));
      authenticationBloc.add(LoggedOut());
      await untilCalled(mockedUserRepository.deleteToken());
    });

    test('unauthed token gets deleted', () async {
      authenticationBloc.add(AppStarted(mockedUserRepository));

      when(mockedUserRepository.me(any))
          .thenAnswer((_) => Future.error(UnauthorizedException()));

      await untilCalled(mockedUserRepository.deleteToken());
    });

    test('unauthed token returns state Unauthenticated', () async {
      final List<AuthenticationState> expected = [
        AuthenticationUninitialized(),
        AuthenticationLoading(mockedUserRepository),
        Unauthenticated(mockedUserRepository),
      ];
      when(mockedUserRepository.me(any))
          .thenAnswer((_) => Future.error(UnauthorizedException()));
      expectLater(
        authenticationBloc,
        emitsInOrder(expected),
      );
      authenticationBloc.add(AppStarted(mockedUserRepository));
    });

    tearDown(() {
      authenticationBloc.close();
    });
  });
}
