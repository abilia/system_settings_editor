import 'package:auth/auth.dart';
import 'package:auth/repository/user_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repository_base/repository_base.dart';
import 'package:seagull_fakes/all.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(
        const LoginInfo(token: '', endDate: 1, renewToken: ''));
  });

  group('AuthenticationBloc event order', () {
    late UserRepository userRepository;
    setUp(() async {
      final prefs = await FakeSharedPreferences.getInstance(loggedIn: false);
      userRepository = UserRepository(
        client: FakeListenableClient.client(),
        loginDb: LoginDb(prefs),
        userDb: UserDb(prefs),
        licenseDb: LicenseDb(prefs),
        baseUrlDb: BaseUrlDb(prefs),
        deviceDb: DeviceDb(prefs),
        app: 'app',
        name: 'name',
      );
    });

    blocTest(
      'initial state is AuthenticationUninitialized',
      build: () => AuthenticationBloc(
        userRepository: userRepository,
        onLogout: () {},
      ),
      verify: (AuthenticationBloc bloc) => expect(
        bloc.state,
        const AuthenticationLoading(),
      ),
    );

    blocTest(
      'state change to Unauthenticated when app starts',
      build: () => AuthenticationBloc(
        userRepository: userRepository,
        onLogout: () {},
      ),
      act: (AuthenticationBloc bloc) => bloc.add(CheckAuthentication()),
      expect: () => [const Unauthenticated()],
    );

    blocTest(
      'state change to AuthenticationAuthenticated when token provided',
      // Act
      build: () => AuthenticationBloc(
        userRepository: userRepository,
        onLogout: () {},
      ),
      act: (AuthenticationBloc bloc) => bloc
        ..add(CheckAuthentication())
        ..add(
          const LoggedIn(),
        ),
      expect: () => [
        const Unauthenticated(),
        const Authenticated(
          user: FakeListenableClient.user,
          newlyLoggedIn: true,
        ),
      ],
    );

    blocTest(
      'state change back to Unauthenticated when logging out',
      build: () => AuthenticationBloc(
        userRepository: userRepository,
        onLogout: () {},
      ),
      act: (AuthenticationBloc bloc) => bloc
        ..add(CheckAuthentication())
        ..add(
          const LoggedIn(),
        )
        ..add(const LoggedOut()),
      expect: () => [
        const Unauthenticated(),
        const Authenticated(
          user: FakeListenableClient.user,
          newlyLoggedIn: true,
        ),
        const Unauthenticated(),
      ],
    );
  });

  group('AuthenticationBloc token side effect', () {
    late MockUserRepository mockedUserRepository;
    late MockNotification notificationMock;

    setUp(() async {
      notificationMock = MockNotification();
      mockedUserRepository = MockUserRepository();

      when(() => mockedUserRepository.logout())
          .thenAnswer((_) => Future.value());
      when(() => mockedUserRepository.persistLoginInfo(any()))
          .thenAnswer((_) => Future.value());
      when(() => mockedUserRepository.baseUrl).thenReturn('url');
      when(() => mockedUserRepository.me()).thenAnswer(
          (_) => Future.value(const User(id: 0, type: '', name: '')));
      when(() => mockedUserRepository.isLoggedIn()).thenReturn(true);
    });

    blocTest(
      'loggedOut calls deletes token',
      build: () => AuthenticationBloc(
        userRepository: mockedUserRepository,
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
        userRepository: mockedUserRepository,
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
      'unauthenticated token gets deleted and returns state Unauthenticated',
      setUp: () => when(() => mockedUserRepository.me())
          .thenAnswer((_) => Future.error(UnauthorizedException())),
      build: () => AuthenticationBloc(
        userRepository: mockedUserRepository,
        onLogout: () {},
      ),
      act: (AuthenticationBloc bloc) => bloc.add(CheckAuthentication()),
      expect: () => [const Unauthenticated()],
      verify: (bloc) => verify(
        () => mockedUserRepository.logout(),
      ).called(1),
    );

    blocTest(
      'logged out cancel all on logout and repo in order',
      setUp: () => when(() => mockedUserRepository.me())
          .thenAnswer((_) => Future.error(UnauthorizedException())),
      build: () => AuthenticationBloc(
        userRepository: mockedUserRepository,
        onLogout: notificationMock.mockCancelAll,
      ),
      act: (AuthenticationBloc bloc) => bloc
        ..add(CheckAuthentication())
        ..add(const LoggedOut()),
      verify: (AuthenticationBloc bloc) => verifyInOrder(
        [
          () => mockedUserRepository.logout(),
          () => notificationMock.mockCancelAll(),
        ],
      ),
    );
  });
}
