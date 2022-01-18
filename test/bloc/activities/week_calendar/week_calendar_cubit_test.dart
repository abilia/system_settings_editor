import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

import '../../../fakes/fakes_blocs.dart';
import '../../../mocks/mocks.dart';

void main() {
  late WeekCalendarCubit weekCalendarBloc;
  late ActivitiesBloc activitiesBloc;
  late MockActivityRepository mockActivityRepository;
  late ClockBloc clockBloc;
  late StreamController<DateTime> mockedTicker;
  final initialMinutes = DateTime(2021, 03, 12, 10, 00);
  group('WeekCalendarBlocTest', () {
    setUp(() {
      mockedTicker = StreamController<DateTime>();
      clockBloc = ClockBloc(mockedTicker.stream, initialTime: initialMinutes);
      mockActivityRepository = MockActivityRepository();
      activitiesBloc = ActivitiesBloc(
        activityRepository: mockActivityRepository,
        syncBloc: FakeSyncBloc(),
        pushBloc: FakePushBloc(),
      );
      activitiesBloc = ActivitiesBloc(
        activityRepository: mockActivityRepository,
        syncBloc: FakeSyncBloc(),
        pushBloc: FakePushBloc(),
      );
      weekCalendarBloc = WeekCalendarCubit(
        activitiesBloc: activitiesBloc,
        clockBloc: clockBloc,
      );
    });

    test('initial state is WeekCalendarInitial', () {
      expect(weekCalendarBloc.state, isA<WeekCalendarInitial>());
      expect(weekCalendarBloc.state.currentWeekStart,
          initialMinutes.firstInWeek());
    });

    test(
        'state is WeekCalendarLoaded when ActivitiesBloc activities are loaded',
        () {
      // Arrange
      when(() => mockActivityRepository.load())
          .thenAnswer((_) => Future.value(const Iterable.empty()));
      // Act
      activitiesBloc.add(LoadActivities());
      // Assert
      expectLater(
        weekCalendarBloc.stream,
        emits(
          _WeekCalendarLoadedMatcher(
            WeekCalendarLoaded(
              initialMinutes.firstInWeek(),
              const {0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: []},
            ),
          ),
        ),
      );
    });

    test('week changes with NextWeek and PreviousWeek events', () async {
      // Arrange
      when(() => mockActivityRepository.load())
          .thenAnswer((_) => Future.value(const Iterable.empty()));
      // Act

      // Assert
      final expected = expectLater(
        weekCalendarBloc.stream,
        emitsInOrder(
          [
            _WeekCalendarLoadedMatcher(WeekCalendarLoaded(
              initialMinutes.firstInWeek().nextWeek(),
              const {0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: []},
            )),
            _WeekCalendarLoadedMatcher(WeekCalendarLoaded(
              initialMinutes.firstInWeek(),
              const {0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: []},
            )),
            _WeekCalendarLoadedMatcher(WeekCalendarLoaded(
              initialMinutes.firstInWeek().previousWeek(),
              const {0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: []},
            )),
          ],
        ),
      );

      activitiesBloc.add(LoadActivities());
      weekCalendarBloc.nextWeek();
      weekCalendarBloc.previousWeek();
      weekCalendarBloc.previousWeek();

      await expected;
    });

    test('Activities updates when changing week', () async {
      final fridayActivity = FakeActivity.starts(initialMinutes);
      // Arrange
      when(() => mockActivityRepository.load())
          .thenAnswer((_) => Future.value([fridayActivity]));
      final expected = expectLater(
        weekCalendarBloc.stream,
        emitsInOrder(
          [
            _WeekCalendarLoadedMatcher(WeekCalendarLoaded(
              initialMinutes.firstInWeek(),
              {
                0: const [],
                1: const [],
                2: const [],
                3: const [],
                4: [
                  ActivityDay(
                          fridayActivity, fridayActivity.startTime.onlyDays())
                      .toOccasion(initialMinutes)
                ],
                5: const [],
                6: const []
              },
            )),
          ],
        ),
      );

      // Act
      activitiesBloc.add(LoadActivities());

      await expected;

      final expected2 = expectLater(
        weekCalendarBloc.stream,
        emitsInOrder(
          [
            _WeekCalendarLoadedMatcher(WeekCalendarLoaded(
              initialMinutes.firstInWeek().nextWeek(),
              const {0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: []},
            )),
            _WeekCalendarLoadedMatcher(WeekCalendarLoaded(
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
            )),
            _WeekCalendarLoadedMatcher(WeekCalendarLoaded(
              initialMinutes.firstInWeek().previousWeek(),
              const {0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: []},
            )),
          ],
        ),
      );

      weekCalendarBloc.nextWeek();
      weekCalendarBloc.previousWeek();
      weekCalendarBloc.previousWeek();

      await expected2;

      // Assert
    });

    test('SGC-845: Week calendar should respect remove after', () {
      final removeAfter = Activity.createNew(
        title: 'Remove after',
        startTime: DateTime(2010, 01, 01, 15, 00),
        recurs: Recurs.weeklyOnDays(const [4, 5, 6]),
        removeAfter: true,
      );
      // Arrange
      when(() => mockActivityRepository.load())
          .thenAnswer((_) => Future.value([removeAfter]));
      // Act
      activitiesBloc.add(LoadActivities());
      // Assert
      expectLater(
        weekCalendarBloc.stream,
        emitsInOrder(
          [
            _WeekCalendarLoadedMatcher(WeekCalendarLoaded(
              initialMinutes.firstInWeek(),
              {
                0: const [],
                1: const [],
                2: const [],
                3: const [], // No activity this day since remove after is true
                4: [
                  ActivityDay(
                          removeAfter, initialMinutes.firstInWeek().addDays(4))
                      .toOccasion(initialMinutes)
                ],
                5: [
                  ActivityDay(
                          removeAfter, initialMinutes.firstInWeek().addDays(5))
                      .toOccasion(initialMinutes)
                ],
                6: const []
              },
            )),
          ],
        ),
      );
    });

    test('SGC-864: Week calendar updates occasion', () async {
      final initalMinActivity = Activity.createNew(
            title: 'initalMinActivity',
            startTime: initialMinutes,
          ),
          nextMinActivity = Activity.createNew(
            title: 'nextMinActivity',
            startTime: initialMinutes.add(1.minutes()),
          );
      // Arrange
      when(() => mockActivityRepository.load()).thenAnswer(
          (_) => Future.value([initalMinActivity, nextMinActivity]));
      // Act
      activitiesBloc.add(LoadActivities());
      // Assert
      await expectLater(
        weekCalendarBloc.stream,
        emits(
          _WeekCalendarLoadedMatcher(WeekCalendarLoaded(
            initialMinutes.firstInWeek(),
            {
              0: const [],
              1: const [],
              2: const [],
              3: const [], // No activity this day since remove after is true
              4: [
                ActivityOccasion.forTest(initalMinActivity),
                ActivityOccasion.forTest(
                  nextMinActivity,
                  occasion: Occasion.future,
                ),
              ],
              5: const [],
              6: const []
            },
          )),
        ),
      );

      // Act
      mockedTicker.add(initialMinutes.add(1.minutes()));
      // Assert
      await expectLater(
        weekCalendarBloc.stream,
        emits(
          _WeekCalendarLoadedMatcher(WeekCalendarLoaded(
            initialMinutes.firstInWeek(),
            {
              0: const [],
              1: const [],
              2: const [],
              3: const [], // No activity this day since remove after is true
              4: [
                ActivityOccasion.forTest(
                  initalMinActivity,
                  occasion: Occasion.past,
                ),
                ActivityOccasion.forTest(nextMinActivity),
              ],
              5: const [],
              6: const []
            },
          )),
        ),
      );
    });
  });
}

class _WeekCalendarLoadedMatcher extends Matcher {
  const _WeekCalendarLoadedMatcher(this.value);

  final WeekCalendarLoaded value;

  @override
  Description describe(Description description) => description.add(
      'WeekCalendarLoaded { currentWeekStart: ${value.currentWeekStart}, activities: ${value.currentWeekActivities}}');

  @override
  bool matches(dynamic object, Map matchState) {
    return value.currentWeekStart == object.currentWeekStart &&
        const DeepCollectionEquality()
            .equals(value.currentWeekActivities, object.currentWeekActivities);
  }
}
