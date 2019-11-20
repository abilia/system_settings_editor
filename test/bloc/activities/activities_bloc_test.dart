import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc.dart';
import 'package:seagull/fakes/fake_activities.dart';
import 'package:seagull/models.dart';

import '../../mocks.dart';

void main() {
  group('ActivitiesBloc', () {
    ActivitiesBloc activitiesBloc;
    MockActivityRepository mockActivityRepository;
    setUp(() {
      mockActivityRepository = MockActivityRepository();
      activitiesBloc = ActivitiesBloc(
          activitiesRepository: mockActivityRepository,
          pushBloc: MockPushBloc());
    });

    test('initial state is ActivitiesNotLoaded', () {
      expect(activitiesBloc.initialState, ActivitiesNotLoaded());
    });

    test('load activities calles load activities on mockActivityRepostitory',
        () async {
      activitiesBloc.add(LoadActivities());
      await untilCalled(mockActivityRepository.loadActivities());
      verify(mockActivityRepository.loadActivities());
    });

    test('LoadActivities event returns ActivitiesLoaded state', () {
      final expected = [
        ActivitiesNotLoaded(),
        ActivitiesLoading(),
        ActivitiesLoaded([])
      ];
      when(mockActivityRepository.loadActivities())
          .thenAnswer((_) => Future.value(<Activity>[]));

      expectLater(
        activitiesBloc,
        emitsInOrder(expected),
      );
      activitiesBloc.add(LoadActivities());
    });

    test('LoadActivities event returns ActivitiesLoaded state with Activity',
        () {
      final exptectedActivity = Activity.createNew(
          title: 'title',
          startTime: 1,
          duration: 2,
          reminderBefore: [],
          alarmType: ALARM_SILENT_ONLY_ON_START,
          category: 0);
      final expectedStates = [
        ActivitiesNotLoaded(),
        ActivitiesLoading(),
        ActivitiesLoaded([exptectedActivity])
      ];
      when(mockActivityRepository.loadActivities())
          .thenAnswer((_) => Future.value(<Activity>[exptectedActivity]));

      expectLater(
        activitiesBloc,
        emitsInOrder(expectedStates),
      );
      activitiesBloc.add(LoadActivities());
    });

    test('calles add activities on mockActivityRepostitory', () async {
      when(mockActivityRepository.loadActivities())
          .thenAnswer((_) => Future.value(<Activity>[]));
      final anActivity = FakeActivity.onTime();
      activitiesBloc.add(LoadActivities());
      await activitiesBloc.firstWhere((s) => s is ActivitiesLoaded);
      activitiesBloc.add(AddActivity(anActivity));
      await untilCalled(mockActivityRepository.saveActivities(any));

      verify(mockActivityRepository.saveActivities([anActivity]));
    });

    test('AddActivity calles add activities on mockActivityRepostitory',
        () async {
      when(mockActivityRepository.loadActivities())
          .thenAnswer((_) => Future.value(<Activity>[]));
      final anActivity = FakeActivity.onTime();
      activitiesBloc.add(LoadActivities());
      await activitiesBloc.firstWhere((s) => s is ActivitiesLoaded);
      activitiesBloc.add(AddActivity(anActivity));

      await untilCalled(mockActivityRepository.saveActivities(any));
    });

    test('UpdateActivities calles save activities on mockActivityRepostitory',
        () async {
      final anActivity = FakeActivity.onTime();

      when(mockActivityRepository.loadActivities())
          .thenAnswer((_) => Future.value(<Activity>[anActivity]));
      activitiesBloc.add(LoadActivities());

      final updatedActivity = anActivity.copyWith(title: 'new title');
      activitiesBloc.add(UpdateActivity(updatedActivity));

      await untilCalled(
          mockActivityRepository.saveActivities([updatedActivity]));
    });

    test('UpdateActivities state order', () async {
      final anActivity = FakeActivity.onTime();

      when(mockActivityRepository.loadActivities())
          .thenAnswer((_) => Future.value(<Activity>[anActivity]));
      activitiesBloc.add(LoadActivities());

      final updatedActivity = anActivity.copyWith(title: 'new title');
      activitiesBloc.add(UpdateActivity(updatedActivity));

      final expectedResponse = [
        ActivitiesNotLoaded(),
        ActivitiesLoading(),
        ActivitiesLoaded([anActivity]),
        ActivitiesLoaded(
            Iterable<Activity>.empty().followedBy([updatedActivity])),
      ];

      expectLater(
        activitiesBloc,
        emitsInOrder(expectedResponse),
      );
    });

    tearDown(() {
      activitiesBloc.close();
    });
  });
}
