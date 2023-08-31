import 'package:auth/auth.dart';
import 'package:auth/repository/user_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:seagull_clock/clock_cubit.dart';
import 'package:seagull_fakes/all.dart';
import 'package:utils/utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late UserRepository userRepository;
  final time = DateTime(2000);

  setUpAll(() {
    registerFallbackValue(Product.unknown);
  });

  setUp(() {
    userRepository = MockUserRepository();
  });

  blocTest(
    'Test initial state',
    build: () => LicenseCubit(
      userRepository: userRepository,
      clockCubit: ClockCubit.fixed(time),
      pushCubit: FakePushCubit(),
      authenticationBloc: AuthenticationBloc(
        userRepository: userRepository,
        onLogout: () {},
        client: FakeListenableClient.client(),
      ),
      product: Product.memoplanner,
    ),
    verify: (bloc) => expect(bloc.state, LicensesNotLoaded()),
  );

  blocTest(
    'License is valid',
    setUp: () => when(() => userRepository.getLicenses(any())).thenAnswer(
      (_) => Future.value([
        License(
          id: 1,
          key: 'licenseKey',
          endTime: time.add(24.hours()),
          product: Product.memoplanner3,
        ),
      ]),
    ),
    build: () => LicenseCubit(
      userRepository: userRepository,
      clockCubit: ClockCubit.fixed(time),
      pushCubit: FakePushCubit(),
      authenticationBloc: AuthenticationBloc(
        userRepository: userRepository,
        onLogout: () {},
        client: FakeListenableClient.client(),
      ),
      product: Product.memoplanner,
    ),
    act: (bloc) => bloc.reloadLicenses(),
    expect: () => [ValidLicense()],
  );

  blocTest(
    'License has expired',
    setUp: () => when(() => userRepository.getLicenses(any())).thenAnswer(
      (_) => Future.value([
        License(
          id: 1,
          key: 'licenseKey',
          endTime: time.subtract(24.hours()),
          product: Product.memoplanner3,
        ),
      ]),
    ),
    build: () => LicenseCubit(
      userRepository: userRepository,
      clockCubit: ClockCubit.fixed(time),
      pushCubit: FakePushCubit(),
      authenticationBloc: AuthenticationBloc(
        userRepository: userRepository,
        onLogout: () {},
        client: FakeListenableClient.client(),
      ),
      product: Product.memoplanner,
    ),
    act: (bloc) => bloc.reloadLicenses(),
    expect: () => [NoValidLicense()],
  );

  blocTest(
    'License has been removed, or no license',
    setUp: () => when(() => userRepository.getLicenses(any())).thenAnswer(
      (_) => Future.value([]),
    ),
    build: () => LicenseCubit(
      userRepository: userRepository,
      clockCubit: ClockCubit.fixed(time),
      pushCubit: FakePushCubit(),
      authenticationBloc: AuthenticationBloc(
        userRepository: userRepository,
        onLogout: () {},
        client: FakeListenableClient.client(),
      ),
      product: Product.memoplanner,
    ),
    act: (bloc) => bloc.reloadLicenses(),
    expect: () => [NoLicense()],
    verify: (bloc) => bloc.state is! NoValidLicense,
  );
}
