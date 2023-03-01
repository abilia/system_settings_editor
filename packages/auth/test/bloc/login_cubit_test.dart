import 'package:auth/auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:seagull_clock/clock_bloc.dart';

import '../fakes_and_mocks.dart';

void main() {
  final time = DateTime(2033, 12, 11, 11);
  group('LoginBloc event order', () {
    late LoginCubit loginCubit;
    late AuthenticationBloc authenticationBloc;
    late MockUserRepository mockUserRepository;
    late MockCalendarRepository mockCalendarRepository;

    const pushToken = 'pushToken';
    final mockDb = MockDatabase();
    setUpAll(() {
      registerFallbackValue(
          const LoginInfo(token: '', endDate: 1, renewToken: ''));
    });

    setUp(() async {
      final mockFirebasePushService = MockFirebasePushService();
      mockUserRepository = MockUserRepository();
      when(() => mockFirebasePushService.initPushToken())
          .thenAnswer((_) => Future.value(pushToken));

      when(() => mockUserRepository.persistLoginInfo(any()))
          .thenAnswer((_) => Future.value());
      when(() => mockUserRepository.baseUrl).thenReturn('url');

      when(() => mockDb.rawQuery(any())).thenAnswer((_) => Future.value([
            {'count(*)': 0}
          ]));

      mockCalendarRepository = MockCalendarRepository();
      authenticationBloc = AuthenticationBloc(
        userRepository: mockUserRepository,
        calendarRepository: mockCalendarRepository,
      );
      loginCubit = LoginCubit(
        authenticationBloc: authenticationBloc,
        pushService: mockFirebasePushService,
        clockBloc: ClockBloc.fixed(time),
        userRepository: mockUserRepository,
        database: mockDb,
        allowExiredLicense: false,
        licenseType: LicenseType.memoplanner,
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
      when(() => mockCalendarRepository.fetchAndSetCalendar(any()))
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

      await loginCubit.loginButtonPressed();
      await loginCubit.loginButtonPressed();

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
      await loginCubit.loginButtonPressed();
      await loginCubit.loginButtonPressed();

      await expected;
    });

    test('Not empty database gives login failure', () async {
      when(() => mockDb.rawQuery(any())).thenAnswer((_) => Future.value([
            {'count(*)': 1}
          ]));
      final batch = MockBatch();
      when(() => batch.commit()).thenAnswer((_) => Future.value([]));
      when(() => mockDb.batch()).thenReturn(batch);

      loginCubit.usernameChanged('username');
      loginCubit.passwordChanged('password');
      loginCubit.loginButtonPressed();

      await expectLater(
        loginCubit.stream,
        emitsInOrder([
          const LoginState(username: 'username', password: 'password')
              .loading()
              .failure(cause: LoginFailureCause.notEmptyDatabase),
        ]),
      );
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

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      mockedUserRepository = MockUserRepository();
      when(() => mockedUserRepository.persistLoginInfo(any()))
          .thenAnswer((_) => Future.value());
      final authenticationBloc = AuthenticationBloc(
        userRepository: mockedUserRepository,
        calendarRepository: FakesCalendarRepository(),
      )..add(CheckAuthentication());
      mockFirebasePushService = MockFirebasePushService();
      final mockDb = MockDatabase();
      when(() => mockDb.rawQuery(any())).thenAnswer((_) => Future.value([
            {'count(*)': 0}
          ]));
      loginCubit = LoginCubit(
        authenticationBloc: authenticationBloc,
        pushService: mockFirebasePushService,
        clockBloc: ClockBloc.fixed(time),
        userRepository: mockedUserRepository,
        database: mockDb,
        allowExiredLicense: false,
        licenseType: LicenseType.memoplanner,
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

    tearDown(() {});

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
    late MockCalendarRepository mockCalendarRepository;

    late License expiredLicense;

    const pushToken = 'pushToken';

    const loginInfo =
        LoginInfo(token: 'loginToken', endDate: 1111, renewToken: 'renew');
    const loggedInUserId = 1;
    const username = 'username', password = 'my long password';

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final mockFirebasePushService = MockFirebasePushService();
      mockUserRepository = MockUserRepository();
      mockCalendarRepository = MockCalendarRepository();
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

      when(() => mockCalendarRepository.fetchAndSetCalendar(any()))
          .thenAnswer((_) => Future.value());

      when(() => mockUserRepository.isLoggedIn()).thenReturn(false);

      authenticationBloc = AuthenticationBloc(
        userRepository: mockUserRepository,
        calendarRepository: mockCalendarRepository,
      );
      final mockDb = MockDatabase();
      when(() => mockDb.rawQuery(any())).thenAnswer((_) => Future.value([
            {'count(*)': 0}
          ]));
      loginCubit = LoginCubit(
        authenticationBloc: authenticationBloc,
        pushService: mockFirebasePushService,
        clockBloc: ClockBloc.fixed(time),
        userRepository: mockUserRepository,
        database: mockDb,
        allowExiredLicense: false,
        licenseType: LicenseType.memoplanner,
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

    test('Login failure when expired license and not allowed', () async {
      // Arrange

      final mockDb = MockDatabase();
      when(() => mockDb.rawQuery(any())).thenAnswer((_) => Future.value([
            {'count(*)': 0}
          ]));
      final mockFirebasePushService = MockFirebasePushService();
      when(() => mockFirebasePushService.initPushToken())
          .thenAnswer((_) => Future.value(pushToken));

      loginCubit = LoginCubit(
        authenticationBloc: authenticationBloc,
        pushService: mockFirebasePushService,
        clockBloc: ClockBloc.fixed(time),
        userRepository: mockUserRepository,
        database: mockDb,
        allowExiredLicense: false,
        licenseType: LicenseType.memoplanner,
      );

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
    });

    test('Login succeeds when expired license and expired licensed allowed',
        () async {
      // Arrange

      final mockDb = MockDatabase();
      when(() => mockDb.rawQuery(any())).thenAnswer((_) => Future.value([
            {'count(*)': 0}
          ]));
      final mockFirebasePushService = MockFirebasePushService();
      when(() => mockFirebasePushService.initPushToken())
          .thenAnswer((_) => Future.value(pushToken));

      loginCubit = LoginCubit(
        authenticationBloc: authenticationBloc,
        pushService: mockFirebasePushService,
        clockBloc: ClockBloc.fixed(time),
        userRepository: mockUserRepository,
        database: mockDb,
        allowExiredLicense: true,
        licenseType: LicenseType.memoplanner,
      );

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
      loginCubit.licenseExpiredWarningConfirmed();

      // Assert
      await expected;
    });
  });
}
