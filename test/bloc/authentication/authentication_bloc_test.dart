import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/models/exceptions.dart';
import 'package:seagull/models/user.dart';
import 'package:seagull/repository/user_repository.dart';

import '../../mocks/mocks.dart';
import '../../fakes/all.dart';

void main() {
  late AuthenticationBloc authenticationBloc;

  group('AuthenticationBloc event order', () {
    late UserRepository userRepository;
    setUp(() async {
      final prefs = await FakeSharedPreferences.getInstance(loggedIn: false);
      userRepository = UserRepository(
        client: Fakes.client(),
        tokenDb: TokenDb(prefs),
        userDb: UserDb(prefs),
        licenseDb: LicenseDb(prefs),
        baseUrl: 'fake',
      );
      authenticationBloc = AuthenticationBloc(
        userRepository,
        onLogout: () {},
      );
    });

    test('initial state is AuthenticationUninitialized', () {
      expect(authenticationBloc.state, AuthenticationLoading(userRepository));
    });

    test('state change to Unauthenticated when app starts', () {
      // Act
      authenticationBloc.add(CheckAuthentication());

      // Assert
      expectLater(
        authenticationBloc.stream,
        emits(Unauthenticated(userRepository)),
      );
    });

    test('state change to AuthenticationAuthenticated when token provided',
        () async {
      // Act
      authenticationBloc.add(CheckAuthentication());
      authenticationBloc.add(const LoggedIn(token: Fakes.token));

      // Assert
      await expectLater(
        authenticationBloc.stream,
        emitsInOrder([
          Unauthenticated(userRepository),
          Authenticated(
            token: Fakes.token,
            userId: Fakes.userId,
            userRepository: userRepository,
            newlyLoggedIn: true,
          ),
        ]),
      );
    });

    test('state change back to Unauthenticated when logging out', () async {
      // Act
      authenticationBloc.add(CheckAuthentication());
      authenticationBloc.add(const LoggedIn(token: Fakes.token));
      authenticationBloc.add(const LoggedOut());

      // Assert
      await expectLater(
        authenticationBloc.stream,
        emitsInOrder([
          Unauthenticated(userRepository),
          Authenticated(
            token: Fakes.token,
            userId: Fakes.userId,
            userRepository: userRepository,
            newlyLoggedIn: true,
          ),
          Unauthenticated(userRepository),
        ]),
      );
    });

    tearDown(() {
      authenticationBloc.close();
    });
  });

  group('AuthenticationBloc token side effect', () {
    late MockUserRepository mockedUserRepository;
    late MockNotification notificationMock;

    setUp(() async {
      mockedUserRepository = MockUserRepository();

      when(() => mockedUserRepository.logout(any()))
          .thenAnswer((_) => Future.value());
      when(() => mockedUserRepository.persistToken(any()))
          .thenAnswer((_) => Future.value());
      notificationMock = MockNotification();

      when(() => mockedUserRepository.getToken()).thenReturn(Fakes.token);
      when(() => mockedUserRepository.me(any())).thenAnswer(
          (_) => Future.value(const User(id: 0, type: '', name: '')));
      authenticationBloc = AuthenticationBloc(
        mockedUserRepository,
        onLogout: () {
          notificationMock.mockCancelAll();
        },
      );
    });

    test('loggedIn event saves token', () async {
      // Act
      authenticationBloc.add(CheckAuthentication());
      authenticationBloc.add(const LoggedIn(token: Fakes.token));
      // Assert
      await untilCalled(() => mockedUserRepository.persistToken(Fakes.token));
    });

    test('loggedOut calls deletes token', () async {
      // Act
      authenticationBloc.add(CheckAuthentication());
      authenticationBloc.add(const LoggedOut());
      // Assert
      await untilCalled(() => mockedUserRepository.logout());
    });

    test('logged out cancel all Notification Function is called', () async {
      // Act
      authenticationBloc.add(CheckAuthentication());
      authenticationBloc.add(const LoggedOut());
      // Assert
      await untilCalled(() => notificationMock.mockCancelAll());
    });

    test('unauthed token gets deleted', () async {
      // Arrange
      when(() => mockedUserRepository.me(any()))
          .thenAnswer((_) => Future.error(UnauthorizedException()));

      // Act
      authenticationBloc.add(CheckAuthentication());

      // Assert
      await untilCalled(() => mockedUserRepository.logout(any()));
    });

    test('unauthed token returns state Unauthenticated', () async {
      // Arrange
      when(() => mockedUserRepository.me(any()))
          .thenAnswer((_) => Future.error(UnauthorizedException()));

      // Act
      authenticationBloc.add(CheckAuthentication());

      // Assert
      await expectLater(
        authenticationBloc.stream,
        emits(
          Unauthenticated(mockedUserRepository),
        ),
      );
    });

    test('logged out cancel all on logout and repo in order', () async {
      // Act
      authenticationBloc.add(CheckAuthentication());
      authenticationBloc.add(const LoggedOut());
      // Assert
      await untilCalled(() => mockedUserRepository.logout());
      await untilCalled(() => notificationMock.mockCancelAll());
      verifyInOrder([
        () => notificationMock.mockCancelAll(),
        () => mockedUserRepository.logout(),
      ]);
    });

    tearDown(() {
      authenticationBloc.close();
    });
  });
}
