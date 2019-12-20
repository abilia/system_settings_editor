import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/fakes/all.dart';
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
          httpClient: Fakes.client(),
          tokenDb: MockTokenDb(),
          userDb: MockUserDb());
      authenticationBloc = AuthenticationBloc(
        databaseRepository: MockDatabaseRepository(),
        baseUrlDb: MockBaseUrlDb(),
        cancleAllNotificationsFunction: () => Future.value(),
      );
    });

    test('initial state is AuthenticationUninitialized', () {
      expect(authenticationBloc.initialState, AuthenticationUninitialized());
    });

    test('state change to Unauthenticated when app starts', () {
      // Act
      authenticationBloc.add(AppStarted(userRepository));

      // Assert
      expectLater(
        authenticationBloc,
        emitsInOrder([
          AuthenticationUninitialized(),
          AuthenticationLoading(userRepository),
          Unauthenticated(userRepository)
        ]),
      );
    });

    test('state change to AuthenticationAuthenticated when token provided',
        () async {
      // Act
      authenticationBloc.add(AppStarted(userRepository));
      authenticationBloc.add(LoggedIn(token: Fakes.token));

      // Assert
      await expectLater(
        authenticationBloc,
        emitsInOrder([
          AuthenticationUninitialized(),
          AuthenticationLoading(userRepository),
          Unauthenticated(userRepository),
          AuthenticationLoading(userRepository),
          Authenticated(
            token: Fakes.token,
            userId: Fakes.userId,
            userRepository: userRepository,
          ),
        ]),
      );
    });

    test('state change back to Unauthenticated when loggin out', () async {
      // Act
      authenticationBloc.add(AppStarted(userRepository));
      authenticationBloc.add(LoggedIn(token: Fakes.token));
      authenticationBloc.add(LoggedOut());

      // Assert
      await expectLater(
        authenticationBloc,
        emitsInOrder([
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
        ]),
      );
    });

    tearDown(() {
      authenticationBloc.close();
    });
  });

  group('AuthenticationBloc token side effect', () {
    AuthenticationBloc authenticationBloc;
    UserRepository mockedUserRepository;
    NotificationMock notificationMock;

    setUp(() {
      mockedUserRepository = MockUserRepository();
      notificationMock = NotificationMock();
      authenticationBloc = AuthenticationBloc(
        databaseRepository: MockDatabaseRepository(),
        baseUrlDb: MockBaseUrlDb(),
        cancleAllNotificationsFunction: notificationMock.mockCancleAll,
      );
      when(mockedUserRepository.getToken())
          .thenAnswer((_) => Future.value(Fakes.token));
      when(mockedUserRepository.me(any))
          .thenAnswer((_) => Future.value(User(id: 0, type: '', name: '')));
    });

    test('loggedIn event saves token', () async {
      // Act
      authenticationBloc.add(AppStarted(mockedUserRepository));
      authenticationBloc.add(LoggedIn(token: Fakes.token));
      // Assert
      await untilCalled(mockedUserRepository.persistToken(Fakes.token));
    });

    test('loggedOut calls deletes token', () async {
      // Act
      authenticationBloc.add(AppStarted(mockedUserRepository));
      authenticationBloc.add(LoggedOut());
      // Assert
      await untilCalled(mockedUserRepository.logout());
    });

    test('logged out cancel all Notification Function is called', () async {
      // Act
      authenticationBloc.add(AppStarted(mockedUserRepository));
      authenticationBloc.add(LoggedOut());
      // Assert
      await untilCalled(notificationMock.mockCancleAll());
    });

    test('unauthed token gets deleted', () async {
      // Arrange
      when(mockedUserRepository.me(any))
          .thenAnswer((_) => Future.error(UnauthorizedException()));

      // Act
      authenticationBloc.add(AppStarted(mockedUserRepository));

      // Assert
      await untilCalled(mockedUserRepository.logout());
    });

    test('unauthed token returns state Unauthenticated', () async {
      // Arrange
      when(mockedUserRepository.me(any))
          .thenAnswer((_) => Future.error(UnauthorizedException()));

      // Act
      authenticationBloc.add(AppStarted(mockedUserRepository));

      // Assert
      await expectLater(
        authenticationBloc,
        emitsInOrder([
          AuthenticationUninitialized(),
          AuthenticationLoading(mockedUserRepository),
          Unauthenticated(mockedUserRepository),
        ]),
      );
    });

    tearDown(() {
      authenticationBloc.close();
    });
  });
}

class Notification {
  Future mockCancleAll() => Future.value();
}

class NotificationMock extends Mock implements Notification {}
