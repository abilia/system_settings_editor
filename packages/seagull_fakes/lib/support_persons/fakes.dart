import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:collection/collection.dart';
import 'package:mocktail/mocktail.dart';
import 'package:support_persons/support_persons.dart';

class MockSupportPersonsRepository extends Mock
    implements SupportPersonsRepository {}

class MockSupportPersonsDb extends Mock implements SupportPersonsDb {}

class MockSupportPersonsCubit extends MockCubit<SupportPersonsState>
    implements SupportPersonsCubit {}

class FakeSupportPersonsCubit extends Fake implements SupportPersonsCubit {
  Set<SupportPerson>? supportPersons;

  FakeSupportPersonsCubit();

  FakeSupportPersonsCubit.withSupportPerson()
      : supportPersons = {
          const SupportPerson(
            id: 0,
            name: '',
            image: '',
          )
        };

  @override
  Stream<SupportPersonsState> get stream => const Stream.empty();

  @override
  SupportPersonsState get state => SupportPersonsState(
      UnmodifiableSetView<SupportPerson>(supportPersons ?? {}));

  @override
  Future<void> loadSupportPersons() async => Future.value();

  @override
  Future<void> close() async {}
}
