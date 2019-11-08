import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc.dart';
import 'package:seagull/models.dart';

import 'mocks.dart';

void main() {
  group('ActivitiesBloc', () {
    ActivitiesBloc activitiesBloc;
    MockActivityRepository mockActivityRepository;
    setUp(() {
      mockActivityRepository = MockActivityRepository();
      activitiesBloc =
          ActivitiesBloc(activitiesRepository: mockActivityRepository);
    });

    test('initial state is AuthenticationUninitialized', () {
      expect(activitiesBloc.initialState, ActivitiesLoading());
    });

    test('load activities calles load activities on mockActivityRepostitory', () async {
      activitiesBloc.add(LoadActivities());
      await untilCalled(mockActivityRepository.loadActivities());
      verify(mockActivityRepository.loadActivities());
    });

    test('LoadActivities event returns ActivitiesLoaded state', () {
      final expected = [ActivitiesLoading(), ActivitiesLoaded([])];
      when(mockActivityRepository.loadActivities()).thenAnswer((_) => Future.value(<Activity>[]));
      
      expectLater(
        activitiesBloc,
        emitsInOrder(expected),
      );
      activitiesBloc.add(LoadActivities());
    });

    test('LoadActivities event returns ActivitiesLoaded state with Activity', () {
      final exptectedActivity = Activity.createNew(title: 'title', startTime: 1, duration: 2, reminderBefore: [], alarmType: ALARM_SILENT_ONLY_ON_START, category: 0);
      final expectedStates = [ActivitiesLoading(), ActivitiesLoaded([exptectedActivity])];
      when(mockActivityRepository.loadActivities()).thenAnswer((_) => Future.value(<Activity>[exptectedActivity]));
      
      expectLater(
        activitiesBloc,
        emitsInOrder(expectedStates),
      );
      activitiesBloc.add(LoadActivities());
    });

    tearDown(() {
      activitiesBloc.close();
    });
  });
}
