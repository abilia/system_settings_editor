import 'package:auth/auth.dart';

import 'package:auth/repository/user_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:seagull_clock/clock_bloc.dart';
import 'package:utils/utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late LicenseCubit licenseCubit;
  late UserRepository userRepository;
  final time = DateTime(2000);

  setUp(() {
    userRepository = MockUserRepository();
    licenseCubit = LicenseCubit(
      userRepository: userRepository,
      clockBloc: ClockBloc.fixed(time),
      pushCubit: FakePushCubit(),
      authenticationBloc: AuthenticationBloc(
        userRepository: userRepository,
        calendarRepository: FakesCalendarRepository(),
      ),
      licenseType: LicenseType.memoplanner,
    );
  });

  test('Test initial state', () {
    expect(licenseCubit.state, LicensesNotLoaded());
  });

  test('License is valid', () async {
    when(() => userRepository.getLicenses()).thenAnswer(
      (_) => Future.value([
        License(
          id: 1,
          key: 'licenseKey',
          endTime: time.add(24.hours()),
          product: 'memoplanner3',
        ),
      ]),
    );
    licenseCubit.reloadLicenses();
    await expectLater(
      licenseCubit.stream,
      emits(ValidLicense()),
    );
  });

  test('License has expired', () async {
    when(() => userRepository.getLicenses()).thenAnswer(
      (_) => Future.value([
        License(
          id: 1,
          key: 'licenseKey',
          endTime: time.subtract(24.hours()),
          product: 'memoplanner3',
        ),
      ]),
    );
    licenseCubit.reloadLicenses();
    await expectLater(
      licenseCubit.stream,
      emits(NoValidLicense()),
    );
  });

  test('License has been removed, or no license', () async {
    when(() => userRepository.getLicenses()).thenAnswer(
      (_) => Future.value([]),
    );
    licenseCubit.reloadLicenses();
    await expectLater(
      licenseCubit.stream,
      emits(NoLicense()),
    );
  });
}
