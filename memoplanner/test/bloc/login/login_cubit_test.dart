import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/config.dart';
import 'package:memoplanner/models/all.dart';

import '../../mocks/mocks.dart';
import '../../test_helpers/register_fallback_values.dart';

void main() {
  final time = DateTime(2033, 12, 11, 11);
  group('LoginBloc event order', () {
    late LoginCubit loginCubit;
    late AuthenticationBloc authenticationBloc;
    late MockUserRepository mockUserRepository;

    const pushToken = 'pushToken';

    setUp(() {
      registerFallbackValues();
      final mockFirebasePushService = MockFirebasePushService();
      mockUserRepository = MockUserRepository();
      when(() => mockFirebasePushService.initPushToken())
          .thenAnswer((_) => Future.value(pushToken));

      when(() => mockUserRepository.persistLoginInfo(any()))
          .thenAnswer((_) => Future.value());
      when(() => mockUserRepository.baseUrl).thenReturn('url');

      authenticationBloc = AuthenticationBloc(mockUserRepository);
      loginCubit = LoginCubit(
        authenticationBloc: authenticationBloc,
        pushService: mockFirebasePushService,
        clockBloc: ClockBloc.fixed(time),
        userRepository: mockUserRepository,
      );
    });

    test('initial state is LoginInitial', () {
      expect(loginCubit.state, LoginState.initial());
    });

    test('LoginState and AuthenticationState in correct order', () async {
      // Arrange
      const loginInfo =
          LoginInfo(token: 'loginToken', endDate: 1111, renewToken: 'renew');
      const loggedInUserId = 1;
      const username = 'username', password = 'my long password';
      when(() => mockUserRepository.authenticate(
            username: any(named: 'username'),
            password: any(named: 'password'),
            pushToken: any(named: 'pushToken'),
            time: any(named: 'time'),
          )).thenAnswer((_) => Future.value(loginInfo));

      when(() => mockUserRepository.me()).thenAnswer((_) => Future.value(
            const User(
              id: loggedInUserId,
              name: 'Test',
              type: '',
            ),
          ));

      when(() => mockUserRepository.getLicensesFromApi()).thenAnswer(
        (_) => Future.value([
          License(
            id: 1,
            key: 'licenseKey',
            endTime: time.add(const Duration(hours: 24)),
            product: memoplannerLicenseName,
          ),
        ]),
      );
      when(() => mockUserRepository.fetchAndSetCalendar(any()))
          .thenAnswer((_) => Future.value());

      when(() => mockUserRepository.isLoggedIn()).thenReturn(false);

      // Act
      authenticationBloc.add(CheckAuthentication());

      // Assert
      await expectLater(
        authenticationBloc.stream,
        emits(const Unauthenticated()),
      );

      final s1 = LoginState.initial().copyWith(username: username);
      final s2 = s1.copyWith(password: password);

      final expected = expectLater(
        loginCubit.stream,
        emitsInOrder([
          s1,
          s2,
          s2.loading(),
          const LoginSucceeded(),
        ]),
      );

      // Act
      loginCubit.usernameChanged(username);
      loginCubit.passwordChanged(password);

      loginCubit.loginButtonPressed();

      // Assert
      await expected;

      expect(
        authenticationBloc.state,
        const Authenticated(
          user: User(id: loggedInUserId, type: 'type', name: 'name'),
          newlyLoggedIn: true,
        ),
      );
    });

    test('LoginButtonPressed twice still yeilds LoginFailure twice on username',
        () async {
      final l1 = LoginState.initial().loading();
      final e1 = l1.failure(cause: LoginFailureCause.noUsername);

      final expected = expectLater(
        loginCubit.stream,
        emitsInOrder([
          l1,
          e1,
          l1,
          e1,
        ]),
      );

      loginCubit.loginButtonPressed();
      loginCubit.loginButtonPressed();

      await expected;
    });

    test('LoginButtonPressed twice still yeilds LoginFailure twice on password',
        () async {
      const username = 'username';

      const s1 = LoginState(username: username, password: '');
      final l1 = s1.loading();
      final e1 = s1.failure(cause: LoginFailureCause.noPassword);

      final expected = expectLater(
        loginCubit.stream,
        emitsInOrder([
          s1,
          l1,
          e1,
          l1,
          e1,
        ]),
      );

      loginCubit.usernameChanged(username);
      loginCubit.loginButtonPressed();
      loginCubit.loginButtonPressed();

      await expected;
    });

    tearDown(() {
      loginCubit.close();
      authenticationBloc.close();
    });
  });

  group('LoginCubit side effect', () {
    late LoginCubit loginCubit;
    late MockUserRepository mockedUserRepository;
    late MockFirebasePushService mockFirebasePushService;

    setUpAll(registerFallbackValues);

    setUp(() {
      mockedUserRepository = MockUserRepository();
      when(() => mockedUserRepository.persistLoginInfo(any()))
          .thenAnswer((_) => Future.value());
      final authenticationBloc = AuthenticationBloc(mockedUserRepository)
        ..add(CheckAuthentication());
      mockFirebasePushService = MockFirebasePushService();
      loginCubit = LoginCubit(
        authenticationBloc: authenticationBloc,
        pushService: mockFirebasePushService,
        clockBloc: ClockBloc.fixed(time),
        userRepository: mockedUserRepository,
      );
      when(() => mockedUserRepository.baseUrl).thenReturn('url');
      when(() => mockedUserRepository.isLoggedIn()).thenReturn(false);
      when(() => mockedUserRepository.me()).thenAnswer(
          (_) => Future.value(const User(id: 0, name: '', type: '')));
      when(() => mockedUserRepository.getLicensesFromApi())
          .thenAnswer((_) => Future.value([
                License(
                    id: 1,
                    key: 'licenseKey',
                    endTime: time.add(const Duration(hours: 24)),
                    product: memoplannerLicenseName)
              ]));
    });

    test('LoginButtonPressed event loggs in and saves token', () async {
      // Arrange
      const username = 'username',
          password = 'long enough password',
          fakePushToken = 'pushToken';
      const loginInfo =
          LoginInfo(token: 'loginToken', endDate: 1111, renewToken: 'renew');
      when(() => mockFirebasePushService.initPushToken())
          .thenAnswer((_) => Future.value(fakePushToken));
      when(() => mockedUserRepository.authenticate(
            username: any(named: 'username'),
            password: any(named: 'password'),
            pushToken: any(named: 'pushToken'),
            time: any(named: 'time'),
          )).thenAnswer((_) => Future.value(loginInfo));

      // Act
      loginCubit.usernameChanged(username);
      loginCubit.passwordChanged(password);
      loginCubit.loginButtonPressed();
      // Assert
      await untilCalled(() => mockedUserRepository.authenticate(
            username: any(named: 'username'),
            password: any(named: 'password'),
            pushToken: any(named: 'pushToken'),
            time: any(named: 'time'),
          ));
      await untilCalled(() => mockedUserRepository.me());
      await untilCalled(() => mockedUserRepository.persistLoginInfo(any()));
    });
  });

  group('login license states', () {
    late LoginCubit loginCubit;
    late AuthenticationBloc authenticationBloc;
    late MockUserRepository mockUserRepository;

    late License expiredLicense;

    const pushToken = 'pushToken';

    const loginInfo =
        LoginInfo(token: 'loginToken', endDate: 1111, renewToken: 'renew');
    const loggedInUserId = 1;
    const username = 'username', password = 'my long password';

    setUp(() {
      registerFallbackValues();
      final mockFirebasePushService = MockFirebasePushService();
      mockUserRepository = MockUserRepository();
      when(() => mockFirebasePushService.initPushToken())
          .thenAnswer((_) => Future.value(pushToken));

      when(() => mockUserRepository.persistLoginInfo(any()))
          .thenAnswer((_) => Future.value());
      when(() => mockUserRepository.baseUrl).thenReturn('url');

      when(() => mockUserRepository.authenticate(
            username: any(named: 'username'),
            password: any(named: 'password'),
            pushToken: any(named: 'pushToken'),
            time: any(named: 'time'),
          )).thenAnswer((_) => Future.value(loginInfo));

      when(() => mockUserRepository.me()).thenAnswer((_) => Future.value(
            const User(
              id: loggedInUserId,
              name: 'Test',
              type: '',
            ),
          ));

      when(() => mockUserRepository.fetchAndSetCalendar(any()))
          .thenAnswer((_) => Future.value());

      when(() => mockUserRepository.isLoggedIn()).thenReturn(false);

      authenticationBloc = AuthenticationBloc(mockUserRepository);
      loginCubit = LoginCubit(
        authenticationBloc: authenticationBloc,
        pushService: mockFirebasePushService,
        clockBloc: ClockBloc.fixed(time),
        userRepository: mockUserRepository,
      );

      expiredLicense = License(
        id: 1,
        key: 'licenseKey',
        endTime: time.add(const Duration(hours: -24)),
        product: memoplannerLicenseName,
      );
    });

    test('Login fails when no license', () async {
      // Arrange

      when(() => mockUserRepository.getLicensesFromApi()).thenAnswer(
        (_) => Future.value([
          // No license
        ]),
      );

      final expected = expectLater(
        loginCubit.stream,
        emitsThrough(
          const LoginState(username: username, password: password)
              .loading()
              .failure(cause: LoginFailureCause.noLicense),
        ),
      );

      // Act
      loginCubit.usernameChanged(username);
      loginCubit.passwordChanged(password);

      loginCubit.loginButtonPressed();

      // Assert
      await expected;
    });

    test('Login failure when expired license on MpGO', () async {
      // Arrange

      when(() => mockUserRepository.getLicensesFromApi()).thenAnswer(
        (_) => Future.value([
          expiredLicense,
        ]),
      );
      final expected = expectLater(
        loginCubit.stream,
        emitsThrough(
          const LoginState(username: username, password: password)
              .loading()
              .failure(cause: LoginFailureCause.noLicense),
        ),
      );

      // Act
      loginCubit.usernameChanged(username);
      loginCubit.passwordChanged(password);

      loginCubit.loginButtonPressed();

      // Assert
      await expected;
    }, skip: Config.isMP);

    test('Login succeeds when expired license on MP', () async {
      // Arrange

      when(() => mockUserRepository.getLicensesFromApi()).thenAnswer(
        (_) => Future.value([
          expiredLicense,
        ]),
      );
      final expected = expectLater(
        loginCubit.stream,
        emitsThrough(
          const LoginSucceeded(),
        ),
      );

      // Act
      loginCubit.usernameChanged(username);
      loginCubit.passwordChanged(password);

      loginCubit.loginButtonPressed();
      loginCubit.confirmLicenseExpiredWarning();

      // Assert
      await expected;
    }, skip: Config.isMPGO);
  });
}
