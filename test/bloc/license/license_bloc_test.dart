import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/utils/all.dart';

import '../../mocks_and_fakes/fakes_blocs.dart';
import '../../mocks_and_fakes/shared.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late LicenseBloc licenseBloc;
  late UserRepository userRepository;

  setUp(() {
    userRepository = MockUserRepository();
    licenseBloc = LicenseBloc(
      userRepository: userRepository,
      clockBloc: ClockBloc(StreamController<DateTime>().stream),
      pushBloc: FakePushBloc(),
      authenticationBloc: AuthenticationBloc(userRepository),
    );
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
      licenseBloc.stream,
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
      licenseBloc.stream,
      emits(NoValidLicense()),
    );
  });
}
