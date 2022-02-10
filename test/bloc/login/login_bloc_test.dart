import 'package:flutter_test/flutter_test.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/models/all.dart';

import '../../mocks/mocks.dart';
import '../../test_helpers/register_fallback_values.dart';

void main() {
  final time = DateTime(2033, 12, 11, 11);
  group('LoginBloc event order', () {
    late LoginBloc loginBloc;
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
      loginBloc = LoginBloc(
        authenticationBloc: authenticationBloc,
        pushService: mockFirebasePushService,
        clockBloc: ClockBloc.fixed(time),
      );
    });

    test('initial state is LoginInitial', () {
      expect(loginBloc.state, LoginState.initial());
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

      // Act
      authenticationBloc.add(CheckAuthentication());

      // Assert
      await expectLater(
        authenticationBloc.stream,
        emits(const Unauthenticated()),
      );

      // Act
      loginBloc.add(const UsernameChanged(username));
      loginBloc.add(const PasswordChanged(password));

      loginBloc.add(LoginButtonPressed());

      final s1 = LoginState.initial().copyWith(username: username);
      final s2 = s1.copyWith(password: password);

      // Assert
      await expectLater(
        loginBloc.stream,
        emitsInOrder([
          s1,
          s2,
          s2.loading(),
          const LoginSucceeded(),
        ]),
      );
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
      loginBloc.add(LoginButtonPressed());
      loginBloc.add(LoginButtonPressed());

      final l1 = LoginState.initial().loading();
      final e1 = l1.failure(cause: LoginFailureCause.noUsername);

      await expectLater(
        loginBloc.stream,
        emitsInOrder([
          l1,
          e1,
          l1,
          e1,
        ]),
      );
    });

    test('LoginButtonPressed twice still yeilds LoginFailure twice on password',
        () async {
      const username = 'username';
      loginBloc.add(const UsernameChanged(username));
      loginBloc.add(LoginButtonPressed());
      loginBloc.add(LoginButtonPressed());
      const s1 = LoginState(username: username, password: '');
      final l1 = s1.loading();
      final e1 = s1.failure(cause: LoginFailureCause.noPassword);

      await expectLater(
        loginBloc.stream,
        emitsInOrder([
          s1,
          l1,
          e1,
          l1,
          e1,
        ]),
      );
    });

    tearDown(() {
      loginBloc.close();
      authenticationBloc.close();
    });
  });

  group('LoginBloc side effect', () {
    late LoginBloc loginBloc;
    late MockUserRepository mockedUserRepository;
    late MockFirebasePushService mockFirebasePushService;

    setUp(() {
      mockedUserRepository = MockUserRepository();
      when(() => mockedUserRepository.persistLoginInfo(any()))
          .thenAnswer((_) => Future.value());
      final authenticationBloc = AuthenticationBloc(mockedUserRepository)
        ..add(CheckAuthentication());
      mockFirebasePushService = MockFirebasePushService();
      loginBloc = LoginBloc(
        authenticationBloc: authenticationBloc,
        pushService: mockFirebasePushService,
        clockBloc: ClockBloc.fixed(time),
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
      loginBloc.add(const UsernameChanged(username));
      loginBloc.add(const PasswordChanged(password));
      loginBloc.add(LoginButtonPressed());
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
