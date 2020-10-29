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

    final pushToken = 'pushToken';

    setUp(() {
      authenticationBloc = AuthenticationBloc(
        database: MockDatabase(),
        baseUrlDb: MockBaseUrlDb(),
      );
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
      expect(loginBloc.state, LoginSucceeded());
    });

    test('LoginState and AuthenticationState in correct order', () async {
      // Arrange
      final mockUserRepository = MockUserRepository();
      final loginToken = 'loginToken';
      final loggedInUserId = 1;

      when(mockUserRepository.authenticate(
        username: anyNamed('username'),
        password: anyNamed('password'),
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
      authenticationBloc.add(AppStarted(mockUserRepository));

      // Assert
      await expectLater(
        authenticationBloc,
        emitsInOrder([
          AuthenticationLoading(mockUserRepository),
          Unauthenticated(mockUserRepository),
        ]),
      );

      // Act
      loginBloc.add(LoginButtonPressed(
        username: 'username',
        password: 'password',
      ));

      // Assert
      await expectLater(
        loginBloc,
        emitsInOrder([
          LoginLoading(),
          LoginSucceeded(),
        ]),
      );
      await expectLater(
        authenticationBloc,
        emits(
          Authenticated(
            token: loginToken,
            userId: loggedInUserId,
            userRepository: mockUserRepository,
          ),
        ),
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
      authenticationBloc = AuthenticationBloc(
        database: MockDatabase(),
        baseUrlDb: MockBaseUrlDb(),
      )..add(AppStarted(mockedUserRepository));
      mockFirebasePushService = MockFirebasePushService();
      loginBloc = LoginBloc(
        authenticationBloc: authenticationBloc,
        pushService: mockFirebasePushService,
        clockBloc: ClockBloc(StreamController<DateTime>().stream),
      );
      when(mockedUserRepository.getToken())
          .thenAnswer((_) => Future.value(Fakes.token));
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
      loginBloc.add(LoginButtonPressed(username: username, password: password));
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
