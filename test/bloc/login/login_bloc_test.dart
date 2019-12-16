import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc.dart';
import 'package:seagull/db/baseurl_db.dart';
import 'package:seagull/fakes/fake_client.dart';
import 'package:seagull/models/user.dart';
import 'package:seagull/repository/user_repository.dart';

import '../../mocks.dart';

void main() {
  group('LoginBloc event order', () {
    LoginBloc loginBloc;
    AuthenticationBloc authenticationBloc;
    UserRepository userRepository;
    MockFirebasePushService mockFirebasePushService;

    setUp(() {
      userRepository = UserRepository(
          httpClient: Fakes.client(),
          tokenDb: MockTokenDb(),
          userDb: MockUserDb());
      authenticationBloc = AuthenticationBloc(
          databaseRepository: MockDatabaseRepository(), baseUrlDb: BaseUrlDb());
      mockFirebasePushService = MockFirebasePushService();
      when(mockFirebasePushService.initPushToken())
          .thenAnswer((_) => Future.value('pushToken'));

      loginBloc = LoginBloc(
          authenticationBloc: authenticationBloc,
          pushService: mockFirebasePushService);
    });

    test('initial state is LoginInitial', () {
      expect(loginBloc.initialState, LoginInitial());
    });

    test('LoginState and AuthenticationState in correct order', () async {
      // Act
      authenticationBloc.add(AppStarted(userRepository));

      // Assert
      await expectLater(
        authenticationBloc,
        emitsInOrder([
          AuthenticationUninitialized(),
          AuthenticationLoading(userRepository),
          Unauthenticated(userRepository),
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
          LoginInitial(),
          LoginLoading(),
          LoginInitial(),
        ]),
      );
      await expectLater(
        authenticationBloc,
        emitsInOrder([
          AuthenticationLoading(userRepository),
          Authenticated(
              token: Fakes.token,
              userId: Fakes.userId,
              userRepository: userRepository),
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
      authenticationBloc = AuthenticationBloc(
          databaseRepository: MockDatabaseRepository(), baseUrlDb: BaseUrlDb())
        ..add(AppStarted(mockedUserRepository));
      mockFirebasePushService = MockFirebasePushService();
      loginBloc = LoginBloc(
          authenticationBloc: authenticationBloc,
          pushService: mockFirebasePushService);
      when(mockedUserRepository.getToken())
          .thenAnswer((_) => Future.value(Fakes.token));
      when(mockedUserRepository.me(any))
          .thenAnswer((_) => Future.value(User(id: 0, name: '', type: '')));
    });

    test('LoginButtonPressed event calls logges in and saves token', () async {
      // Arrange
      String username = 'username',
          password = 'password',
          fakePushToken = 'fakePushToken';
      when(mockFirebasePushService.initPushToken())
          .thenAnswer((_) => Future.value(fakePushToken));
      // Act
      loginBloc.add(LoginButtonPressed(username: username, password: password));
      // Assert
      await untilCalled(mockedUserRepository.authenticate(
          username: username, password: password, pushToken: fakePushToken));
      await untilCalled(mockedUserRepository.me(any));
      await untilCalled(mockedUserRepository.persistToken(any));
    });

    tearDown(() {
      authenticationBloc.close();
      loginBloc.close();
    });
  });
}
