import 'package:bloc_test/bloc_test.dart';
import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/activity/activity.dart';
import 'package:memoplanner/models/support_person.dart';
import 'package:memoplanner/repository/data_repository/support_persons_repository.dart';

import '../../../mocks/mocks.dart';

void main() {
  const testSupportPerson = SupportPerson(id: 0, name: 'Test', image: '');
  const testSupportPerson2 = SupportPerson(id: 1, name: 'Test 2', image: '');

  late SupportPersonsRepository supportPersonsRepository;
  late SupportPersonsCubit supportPersonsCubit;

  final initialState = AvailableForState(
    availableFor: AvailableForType.allSupportPersons,
    selectedSupportPersons: const UnmodifiableSetView.empty(),
    allSupportPersons: UnmodifiableSetView(
      {testSupportPerson, testSupportPerson2},
    ),
  );

  setUp(() {
    supportPersonsRepository = MockSupportPersonsRepository();
    when(() => supportPersonsRepository.load()).thenAnswer(
        (_) => Future.value({testSupportPerson, testSupportPerson2}));
    supportPersonsCubit =
        SupportPersonsCubit(supportPersonsRepository: supportPersonsRepository);
  });

  blocTest('Initial states, emits initialState',
      build: () => AvailableForCubit(
            supportPersonsCubit: supportPersonsCubit,
            availableFor: AvailableForType.allSupportPersons,
            selectedSupportPersons: {},
          ),
      expect: () => [initialState]);

  test('Change to private', () async {
    final availableForCubit = AvailableForCubit(
      supportPersonsCubit: supportPersonsCubit,
      availableFor: AvailableForType.allSupportPersons,
      selectedSupportPersons: {},
    );
    await expectLater(availableForCubit.state, initialState);
    availableForCubit.setAvailableFor(AvailableForType.onlyMe);
    await expectLater(availableForCubit.state,
        initialState.copyWith(availableFor: AvailableForType.onlyMe));
  });

  test(
      "Change to selected support persons and select a person. Changing to  'only me' will remove selection",
      () async {
    final availableForCubit = AvailableForCubit(
      supportPersonsCubit: supportPersonsCubit,
      availableFor: AvailableForType.allSupportPersons,
      selectedSupportPersons: {},
    );
    await expectLater(availableForCubit.state, initialState);
    availableForCubit.setAvailableFor(AvailableForType.selectedSupportPersons);
    await expectLater(
        availableForCubit.state,
        initialState.copyWith(
            availableFor: AvailableForType.selectedSupportPersons));
    availableForCubit.toggleSupportPerson(testSupportPerson2.id);
    await expectLater(
        availableForCubit.state,
        initialState.copyWith(
            availableFor: AvailableForType.selectedSupportPersons,
            selectedSupportPersons: <int>{testSupportPerson2.id}));

    availableForCubit.setAvailableFor(AvailableForType.onlyMe);
    await expectLater(availableForCubit.state,
        initialState.copyWith(availableFor: AvailableForType.onlyMe));
  });
}
