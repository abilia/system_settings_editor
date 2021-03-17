import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

import '../../../mocks.dart';

void main() {
  WeekCalendarBloc weekCalendarBloc;
  ActivitiesBloc activitiesBloc;
  MockActivityRepository mockActivityRepository;
  ClockBloc clockBloc;
  final initialMinutes = DateTime(2021, 03, 12, 10, 00);
  StreamController<DateTime> mockedTicker;
  group('WeekCalendarBlocTest', () {
    setUp(() {
      mockedTicker = StreamController<DateTime>();
      clockBloc = ClockBloc(mockedTicker.stream, initialTime: initialMinutes);
      mockActivityRepository = MockActivityRepository();
      activitiesBloc = ActivitiesBloc(
        activityRepository: mockActivityRepository,
        syncBloc: MockSyncBloc(),
        pushBloc: MockPushBloc(),
      );
      activitiesBloc = ActivitiesBloc(
        activityRepository: mockActivityRepository,
        syncBloc: MockSyncBloc(),
        pushBloc: MockPushBloc(),
      );
      weekCalendarBloc = WeekCalendarBloc(
        activitiesBloc: activitiesBloc,
        clockBloc: clockBloc,
      );
    });

    test('initial state is DayActivitiesUninitialized', () {
      expect(weekCalendarBloc.state,
          WeekCalendarInitial(initialMinutes.firstInWeek()));
    });

    test(
        'state is WeekCalendarLoaded when ActivitiesBloc activities are loaded',
        () {
      // Arrange
      when(mockActivityRepository.load())
          .thenAnswer((_) => Future.value(Iterable.empty()));
      // Act
      activitiesBloc.add(LoadActivities());
      // Assert
      expectLater(
        weekCalendarBloc,
        emits(
          WeekCalendarLoaded(
            initialMinutes.firstInWeek(),
            {0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: []},
          ),
        ),
      );
    });

    test('week changes with NextWeek and PreviousWeek events', () {
      // Arrange
      when(mockActivityRepository.load())
          .thenAnswer((_) => Future.value(Iterable.empty()));
      // Act
      activitiesBloc.add(LoadActivities());
      weekCalendarBloc.add(NextWeek());
      weekCalendarBloc.add(PreviousWeek());
      weekCalendarBloc.add(PreviousWeek());
      // Assert
      expectLater(
        weekCalendarBloc,
        emitsInOrder(
          [
            WeekCalendarLoaded(
              initialMinutes.firstInWeek().nextWeek(),
              {0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: []},
            ),
            WeekCalendarLoaded(
              initialMinutes.firstInWeek(),
              {0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: []},
            ),
            WeekCalendarLoaded(
              initialMinutes.firstInWeek().previousWeek(),
              {0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: []},
            ),
          ],
        ),
      );
    });

    test('Activities updates when changing week', () {
      final fridayActivity = FakeActivity.starts(initialMinutes);
      // Arrange
      when(mockActivityRepository.load())
          .thenAnswer((_) => Future.value([fridayActivity]));
      // Act
      activitiesBloc.add(LoadActivities());
      weekCalendarBloc.add(NextWeek());
      weekCalendarBloc.add(PreviousWeek());
      weekCalendarBloc.add(PreviousWeek());
      // Assert
      expectLater(
        weekCalendarBloc,
        emitsInOrder(
          [
            WeekCalendarLoaded(
              initialMinutes.firstInWeek().nextWeek(),
              {0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: []},
            ),
            WeekCalendarLoaded(
              initialMinutes.firstInWeek(),
              {
                0: [],
                1: [],
                2: [],
                3: [],
                4: [
                  ActivityDay(
                          fridayActivity, fridayActivity.startTime.onlyDays())
                      .toOccasion(initialMinutes)
                ],
                5: [],
                6: []
              },
            ),
            WeekCalendarLoaded(
              initialMinutes.firstInWeek().previousWeek(),
              {0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: []},
            ),
          ],
        ),
      );
    });
  });
}
