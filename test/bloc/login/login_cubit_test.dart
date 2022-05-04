import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

import '../../fakes/all.dart';
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
      const username = 'username', password = 'password';
      when(() => mockUserRepository.authenticate(
            username: any(named: username),
            password: any(named: password),
            pushToken: any(named: 'pushToken'),
            time: any(named: 'time'),
          )).thenAnswer((_) => Future.value(loginInfo));
      when(() => mockUserRepository.getToken()).thenReturn('token');

      when(() => mockUserRepository.me(loginInfo.token))
          .thenAnswer((_) => Future.value(
                const User(
                  id: loggedInUserId,
                  name: 'Test',
                  type: '',
                ),
              ));

      when(() => mockUserRepository.getLicensesFromApi(any())).thenAnswer(
        (_) => Future.value([
          License(
            endTime: time.add(const Duration(hours: 24)),
            id: 1,
            product: memoplannerLicenseName,
          ),
        ]),
      );
      when(() => mockUserRepository.fetchAndSetCalendar(any(), any()))
          .thenAnswer((_) => Future.value());

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
        Authenticated(
          token: loginInfo.token,
          userId: loggedInUserId,
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
      when(() => mockedUserRepository.getToken()).thenReturn(Fakes.token);
      when(() => mockedUserRepository.me(any())).thenAnswer(
          (_) => Future.value(const User(id: 0, name: '', type: '')));
      when(() => mockedUserRepository.getLicensesFromApi(any()))
          .thenAnswer((_) => Future.value([
                License(
                    endTime: time.add(const Duration(hours: 24)),
                    id: 1,
                    product: memoplannerLicenseName)
              ]));
    });

    test('LoginButtonPressed event calls logges in and saves token', () async {
      // Arrange
      const username = 'username',
          password = 'password',
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
      await untilCalled(() => mockedUserRepository.me(any()));
      await untilCalled(() => mockedUserRepository.persistLoginInfo(any()));
    });
  });
}
