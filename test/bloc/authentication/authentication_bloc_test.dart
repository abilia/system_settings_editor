import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/models/exceptions.dart';
import 'package:seagull/models/user.dart';
import 'package:seagull/repository/user_repository.dart';

import '../../mocks.dart';

void main() {
  AuthenticationBloc authenticationBloc;

  group('AuthenticationBloc event order', () {
    UserRepository userRepository;
    setUp(() async {
      final prefs = await MockSharedPreferences.getInstance(loggedIn: false);
      userRepository = UserRepository(
        client: Fakes.client(),
        tokenDb: TokenDb(prefs),
        userDb: UserDb(prefs),
        licenseDb: LicenseDb(prefs),
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
        authenticationBloc,
        emits(Unauthenticated(userRepository)),
      );
    });

    test('state change to AuthenticationAuthenticated when token provided',
        () async {
      // Act
      authenticationBloc.add(CheckAuthentication());
      authenticationBloc.add(LoggedIn(token: Fakes.token));

      // Assert
      await expectLater(
        authenticationBloc,
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

    test('state change back to Unauthenticated when loggin out', () async {
      // Act
      authenticationBloc.add(CheckAuthentication());
      authenticationBloc.add(LoggedIn(token: Fakes.token));
      authenticationBloc.add(LoggedOut());

      // Assert
      await expectLater(
        authenticationBloc,
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
    UserRepository mockedUserRepository;
    NotificationMock notificationMock;

    setUp(() async {
      mockedUserRepository = MockUserRepository();
      notificationMock = NotificationMock();
      when(mockedUserRepository.getToken()).thenReturn(Fakes.token);
      when(mockedUserRepository.me(any))
          .thenAnswer((_) => Future.value(User(id: 0, type: '', name: '')));
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
      authenticationBloc.add(LoggedIn(token: Fakes.token));
      // Assert
      await untilCalled(mockedUserRepository.persistToken(Fakes.token));
    });

    test('loggedOut calls deletes token', () async {
      // Act
      authenticationBloc.add(CheckAuthentication());
      authenticationBloc.add(LoggedOut());
      // Assert
      await untilCalled(mockedUserRepository.logout());
    });

    test('logged out cancel all Notification Function is called', () async {
      // Act
      authenticationBloc.add(CheckAuthentication());
      authenticationBloc.add(LoggedOut());
      // Assert
      await untilCalled(notificationMock.mockCancelAll());
    });

    test('unauthed token gets deleted', () async {
      // Arrange
      when(mockedUserRepository.me(any))
          .thenAnswer((_) => Future.error(UnauthorizedException()));

      // Act
      authenticationBloc.add(CheckAuthentication());

      // Assert
      await untilCalled(mockedUserRepository.logout(any));
    });

    test('unauthed token returns state Unauthenticated', () async {
      // Arrange
      when(mockedUserRepository.me(any))
          .thenAnswer((_) => Future.error(UnauthorizedException()));

      // Act
      authenticationBloc.add(CheckAuthentication());

      // Assert
      await expectLater(
        authenticationBloc,
        emits(
          Unauthenticated(mockedUserRepository),
        ),
      );
    });

    test('logged out cancel all on logout and repo in order', () async {
      // Act
      authenticationBloc.add(CheckAuthentication());
      authenticationBloc.add(LoggedOut());
      // Assert
      await untilCalled(mockedUserRepository.logout());
      await untilCalled(notificationMock.mockCancelAll());
      verifyInOrder([
        notificationMock.mockCancelAll(),
        mockedUserRepository.logout(),
      ]);
    });

    tearDown(() {
      authenticationBloc.close();
    });
  });
}

class Notification {
  Future mockCancelAll() => Future.value();
}

class NotificationMock extends Mock implements Notification {}
