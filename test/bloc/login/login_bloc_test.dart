import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/models/user.dart';
import 'package:seagull/repository/user_repository.dart';

import '../../mocks.dart';

void main() {
  group('LoginBloc event order', () {
    LoginBloc loginBloc;
    AuthenticationBloc authenticationBloc;
    MockFirebasePushService mockFirebasePushService;
    final mockUserRepository = MockUserRepository();

    final pushToken = 'pushToken';

    setUp(() {
      authenticationBloc = AuthenticationBloc(mockUserRepository);
      mockFirebasePushService = MockFirebasePushService();
      when(mockFirebasePushService.initPushToken())
          .thenAnswer((_) => Future.value(pushToken));

      loginBloc = LoginBloc(
        authenticationBloc: authenticationBloc,
        pushService: mockFirebasePushService,
        clockBloc: ClockBloc(StreamController<DateTime>().stream),
      );
    });

    test('initial state is LoginInitial', () {
      expect(loginBloc.state, LoginState.initial());
    });

    test('LoginState and AuthenticationState in correct order', () async {
      // Arrange
      final loginToken = 'loginToken';
      final loggedInUserId = 1;
      final username = 'username', password = 'password';
      when(mockUserRepository.authenticate(
        username: anyNamed(username),
        password: anyNamed(password),
        pushToken: anyNamed('pushToken'),
        time: anyNamed('time'),
      )).thenAnswer((_) => Future.value(loginToken));

      when(mockUserRepository.me(loginToken)).thenAnswer((_) => Future.value(
            User(
              id: loggedInUserId,
              name: 'Test',
              type: '',
            ),
          ));

      when(mockUserRepository.getLicensesFromApi(any)).thenAnswer(
        (_) => Future.value([
          License(
            endTime: DateTime.now().add(Duration(hours: 24)),
            id: 1,
            product: MEMOPLANNER_LICENSE_NAME,
          ),
        ]),
      );

      // Act
      authenticationBloc.add(CheckAuthentication());

      // Assert
      await expectLater(
        authenticationBloc.stream,
        emits(
          Unauthenticated(mockUserRepository),
        ),
      );

      // Act
      loginBloc.add(UsernameChanged(username));
      loginBloc.add(PasswordChanged(password));

      loginBloc.add(LoginButtonPressed());

      final s1 = LoginState.initial().copyWith(username: username);
      final s2 = s1.copyWith(password: password);

      // Assert
      await expectLater(
        loginBloc.stream,
        emitsInOrder([
          s1,
          s2,
          s2.loadning(),
          LoginSucceeded(),
        ]),
      );
      expect(
        authenticationBloc.state,
        Authenticated(
          token: loginToken,
          userId: loggedInUserId,
          userRepository: mockUserRepository,
          newlyLoggedIn: true,
        ),
      );
    });

    test('LoginButtonPressed twice still yeilds LoginFailure twice on username',
        () async {
      loginBloc.add(LoginButtonPressed());
      loginBloc.add(LoginButtonPressed());

      final l1 = LoginState.initial().loadning();
      final e1 = l1.failure(cause: LoginFailureCause.NoUsername);

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
      final username = 'username';
      loginBloc.add(UsernameChanged(username));
      loginBloc.add(LoginButtonPressed());
      loginBloc.add(LoginButtonPressed());
      final s1 = LoginState(username: username, password: '');
      final l1 = s1.loadning();
      final e1 = s1.failure(cause: LoginFailureCause.NoPassword);

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
    LoginBloc loginBloc;
    AuthenticationBloc authenticationBloc;
    UserRepository mockedUserRepository;
    MockFirebasePushService mockFirebasePushService;

    setUp(() {
      mockedUserRepository = MockUserRepository();
      authenticationBloc = AuthenticationBloc(mockedUserRepository)
        ..add(CheckAuthentication());
      mockFirebasePushService = MockFirebasePushService();
      loginBloc = LoginBloc(
        authenticationBloc: authenticationBloc,
        pushService: mockFirebasePushService,
        clockBloc: ClockBloc(StreamController<DateTime>().stream),
      );
      when(mockedUserRepository.getToken()).thenReturn(Fakes.token);
      when(mockedUserRepository.me(any))
          .thenAnswer((_) => Future.value(User(id: 0, name: '', type: '')));
      when(mockedUserRepository.getLicensesFromApi(any))
          .thenAnswer((_) => Future.value([
                License(
                    endTime: DateTime.now().add(Duration(hours: 24)),
                    id: 1,
                    product: MEMOPLANNER_LICENSE_NAME)
              ]));
    });

    test('LoginButtonPressed event calls logges in and saves token', () async {
      // Arrange
      final username = 'username',
          password = 'password',
          fakePushToken = 'pushToken';
      final loginToken = 'loginToken';
      when(mockFirebasePushService.initPushToken())
          .thenAnswer((_) => Future.value(fakePushToken));
      when(mockedUserRepository.authenticate(
        username: anyNamed('username'),
        password: anyNamed('password'),
        pushToken: anyNamed('pushToken'),
        time: anyNamed('time'),
      )).thenAnswer((_) => Future.value(loginToken));

      // Act
      loginBloc.add(UsernameChanged(username));
      loginBloc.add(PasswordChanged(password));
      loginBloc.add(LoginButtonPressed());
      // Assert
      await untilCalled(mockedUserRepository.authenticate(
        username: anyNamed('username'),
        password: anyNamed('password'),
        pushToken: anyNamed('pushToken'),
        time: anyNamed('time'),
      ));
      await untilCalled(mockedUserRepository.me(any));
      await untilCalled(mockedUserRepository.persistToken(any));
    });

    tearDown(() {
      authenticationBloc.close();
      loginBloc.close();
    });
  });
}
