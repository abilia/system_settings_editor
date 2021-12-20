import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/models/exceptions.dart';
import 'package:seagull/models/user.dart';
import 'package:seagull/repository/user_repository.dart';

import '../../mocks/mocks.dart';
import '../../fakes/all.dart';

void main() {
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
    });

    blocTest(
      'initial state is AuthenticationUninitialized',
      build: () => AuthenticationBloc(userRepository, onLogout: () {}),
      verify: (AuthenticationBloc bloc) => expect(
        bloc.state,
        AuthenticationLoading(userRepository),
      ),
    );

    blocTest('state change to Unauthenticated when app starts',
        build: () => AuthenticationBloc(userRepository, onLogout: () {}),
        act: (AuthenticationBloc bloc) => bloc.add(CheckAuthentication()),
        expect: () => [Unauthenticated(userRepository)]);

    blocTest(
      'state change to AuthenticationAuthenticated when token provided',
      // Act
      build: () => AuthenticationBloc(userRepository, onLogout: () {}),
      act: (AuthenticationBloc bloc) => bloc
        ..add(CheckAuthentication())
        ..add(const LoggedIn(token: Fakes.token)),
      expect: () => [
        Unauthenticated(userRepository),
        Authenticated(
          token: Fakes.token,
          userId: Fakes.userId,
          userRepository: userRepository,
          newlyLoggedIn: true,
        ),
      ],
    );

    blocTest(
      'state change back to Unauthenticated when logging out',
      build: () => AuthenticationBloc(userRepository, onLogout: () {}),
      act: (AuthenticationBloc bloc) => bloc
        ..add(CheckAuthentication())
        ..add(const LoggedIn(token: Fakes.token))
        ..add(const LoggedOut()),
      expect: () => [
        Unauthenticated(userRepository),
        Authenticated(
          token: Fakes.token,
          userId: Fakes.userId,
          userRepository: userRepository,
          newlyLoggedIn: true,
        ),
        Unauthenticated(userRepository),
      ],
    );
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
      when(() => mockedUserRepository.baseUrl).thenReturn('url');
      notificationMock = MockNotification();

      when(() => mockedUserRepository.getToken()).thenReturn(Fakes.token);
      when(() => mockedUserRepository.me(any())).thenAnswer(
          (_) => Future.value(const User(id: 0, type: '', name: '')));
    });

    blocTest(
      'loggedIn event saves token',
      build: () => AuthenticationBloc(
        mockedUserRepository,
        onLogout: () {
          notificationMock.mockCancelAll();
        },
      ),
      act: (AuthenticationBloc bloc) => bloc
        ..add(CheckAuthentication())
        ..add(const LoggedIn(token: Fakes.token)),
      verify: (bloc) =>
          verify(() => mockedUserRepository.persistToken(Fakes.token))
              .called(1),
    );

    blocTest(
      'loggedOut calls deletes token',
      build: () => AuthenticationBloc(
        mockedUserRepository,
        onLogout: () {
          notificationMock.mockCancelAll();
        },
      ),
      act: (AuthenticationBloc bloc) => bloc
        ..add(CheckAuthentication())
        ..add(const LoggedOut()),
      verify: (bloc) => verify(() => mockedUserRepository.logout()).called(1),
    );

    blocTest(
      'logged out cancel all Notification Function is called',
      build: () => AuthenticationBloc(
        mockedUserRepository,
        onLogout: () {
          notificationMock.mockCancelAll();
        },
      ),
      act: (AuthenticationBloc bloc) => bloc
        ..add(CheckAuthentication())
        ..add(const LoggedOut()),
      verify: (bloc) =>
          verify(() => notificationMock.mockCancelAll()).called(1),
    );

    blocTest(
      'unauthed token gets deleted and returns state Unauthenticated',
      setUp: () => when(() => mockedUserRepository.me(any()))
          .thenAnswer((_) => Future.error(UnauthorizedException())),
      build: () => AuthenticationBloc(mockedUserRepository, onLogout: () {}),
      act: (AuthenticationBloc bloc) => bloc.add(CheckAuthentication()),
      expect: () => [Unauthenticated(mockedUserRepository)],
      verify: (bloc) => verify(
        () => mockedUserRepository.logout(any()),
      ).called(1),
    );

    blocTest(
      'logged out cancel all on logout and repo in order',
      setUp: () => when(() => mockedUserRepository.me(any()))
          .thenAnswer((_) => Future.error(UnauthorizedException())),
      build: () => AuthenticationBloc(mockedUserRepository,
          onLogout: notificationMock.mockCancelAll),
      act: (AuthenticationBloc bloc) => bloc
        ..add(CheckAuthentication())
        ..add(const LoggedOut()),
      verify: (AuthenticationBloc bloc) => verifyInOrder(
        [
          () => notificationMock.mockCancelAll(),
          () => mockedUserRepository.logout(),
        ],
      ),
    );
  });
}
