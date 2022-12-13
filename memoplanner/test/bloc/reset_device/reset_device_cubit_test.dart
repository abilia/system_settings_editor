import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/repository/all.dart';

import '../../mocks/mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ResetDeviceCubit resetDeviceCubit;
  late FactoryResetRepository factoryResetRepository;

  setUp(() {
    factoryResetRepository = MockFactoryResetRepository();

    resetDeviceCubit = ResetDeviceCubit(
      factoryResetRepository: factoryResetRepository,
    );
  });

  group('ResetDeviceCubit', () {
    blocTest(
      'Initial state',
      build: () => resetDeviceCubit,
      verify: (ResetDeviceCubit cubit) => expect(
        cubit.state,
        const ResetDeviceState(resetType: null),
      ),
    );

    test('Factory reset device success', () async {
      when(() => factoryResetRepository.factoryResetDevice())
          .thenAnswer((_) => Future.value(true));
      await resetDeviceCubit.factoryResetDevice();
      expect(
        resetDeviceCubit.state,
        const FactoryResetInProgress(),
      );
    });

    test('Factory reset device fails', () async {
      when(() => factoryResetRepository.factoryResetDevice())
          .thenAnswer((_) => Future.value(false));
      await resetDeviceCubit.factoryResetDevice();
      expect(
        resetDeviceCubit.state,
        const FactoryResetFailed(),
      );
    });
  });
}
