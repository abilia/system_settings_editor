import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/utils/all.dart';

import '../../mocks.dart';
import '../authentication/authentication_bloc_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  LicenseBloc licenseBloc;
  UserRepository userRepository;
  final authenticationBloc = AuthenticationBloc(
    database: MockDatabase(),
    baseUrlDb: MockBaseUrlDb(),
    seagullLogger: MockSeagullLogger(),
    cancleAllNotificationsFunction: NotificationMock().mockCancleAll,
  );

  setUp(() {
    userRepository = MockUserRepository();
    licenseBloc = LicenseBloc(
        userRepository: userRepository,
        clockBloc: ClockBloc(StreamController<DateTime>().stream),
        pushBloc: MockPushBloc(),
        authenticationBloc: authenticationBloc);
  });

  test('Test initial state', () {
    expect(licenseBloc.state, LicensesNotLoaded());
  });

  test('License is valid', () async {
    when(userRepository.getLicenses()).thenAnswer(
      (_) => Future.value([
        License(
            id: 1,
            endTime: DateTime.now().add(24.hours()),
            product: 'memoplanner3'),
      ]),
    );
    licenseBloc.add(ReloadLicenses());
    await expectLater(
      licenseBloc,
      emits(ValidLicense()),
    );
  });

  test('License has expired', () async {
    when(userRepository.getLicenses()).thenAnswer(
      (_) => Future.value([
        License(
            id: 1,
            endTime: DateTime.now().subtract(24.hours()),
            product: 'memoplanner3'),
      ]),
    );
    licenseBloc.add(ReloadLicenses());
    await expectLater(
      licenseBloc,
      emits(NoValidLicense()),
    );
  });
}
