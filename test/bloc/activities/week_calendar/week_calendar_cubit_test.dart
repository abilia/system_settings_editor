import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/utils/all.dart';

import '../../../fakes/all.dart';
import '../../../mocks/mocks.dart';

void main() {
  late WeekCalendarCubit weekCalendarBloc;
  late ActivitiesBloc activitiesBloc;
  late TimerAlarmBloc timerAlarmBloc;
  late MockActivityRepository mockActivityRepository;
  late ClockBloc clockBloc;
  late StreamController<DateTime> mockedTicker;
  final initialMinutes = DateTime(2021, 03, 12, 10, 00);
  group('WeekCalendarCubitTest', () {
    setUp(() {
      mockedTicker = StreamController<DateTime>();
      clockBloc = ClockBloc(mockedTicker.stream, initialTime: initialMinutes);
      mockActivityRepository = MockActivityRepository();
      activitiesBloc = ActivitiesBloc(
        activityRepository: mockActivityRepository,
        syncBloc: FakeSyncBloc(),
        pushCubit: FakePushCubit(),
      );
      final timerDb = MockTimerDb();
      final timerCubit = TimerCubit(
        ticker: Ticker.fake(initialTime: initialMinutes),
        timerDb: timerDb,
      );
      timerAlarmBloc = TimerAlarmBloc(
        ticker: Ticker.fake(initialTime: initialMinutes),
        timerCubit: timerCubit,
      );
      activitiesBloc = ActivitiesBloc(
        activityRepository: mockActivityRepository,
        syncBloc: FakeSyncBloc(),
        pushCubit: FakePushCubit(),
      );
      weekCalendarBloc = WeekCalendarCubit(
        activitiesBloc: activitiesBloc,
        timerAlarmBloc: timerAlarmBloc,
        activityRepository: mockActivityRepository,
        clockBloc: clockBloc,
      );
    });

    tearDown(() {
      mockedTicker.close();
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
      when(() => mockActivityRepository.allBetween(any(), any()))
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
              const {0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: []},
            ),
          ),
        ),
      );
    });

    test('week changes with NextWeek and PreviousWeek events', () async {
      // Arrange
      when(() => mockActivityRepository.allBetween(any(), any()))
          .thenAnswer((_) => Future.value(const Iterable.empty()));

      // Assert
      final expected = expectLater(
        weekCalendarBloc.stream,
        emitsInOrder(
          [
            _WeekCalendarLoadedMatcher(WeekCalendarLoaded(
              initialMinutes.firstInWeek().nextWeek(),
              const {0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: []},
              const {0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: []},
            )),
            _WeekCalendarLoadedMatcher(WeekCalendarLoaded(
              initialMinutes.firstInWeek(),
              const {0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: []},
              const {0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: []},
            )),
            _WeekCalendarLoadedMatcher(WeekCalendarLoaded(
              initialMinutes.firstInWeek().previousWeek(),
              const {0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: []},
              const {0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: []},
            )),
          ],
        ),
      );

      await weekCalendarBloc.nextWeek();
      await weekCalendarBloc.previousWeek();
      await weekCalendarBloc.previousWeek();

      await expected;
    });

    test('Activities updates when changing week', () async {
      final fridayActivity = FakeActivity.starts(initialMinutes);
      // Arrange
      when(() => mockActivityRepository.allBetween(any(), any()))
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
              const {0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: []},
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
              const {0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: []},
            )),
            _WeekCalendarLoadedMatcher(WeekCalendarLoaded(
              initialMinutes.firstInWeek().previousWeek(),
              const {0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: []},
              const {0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: []},
            )),
          ],
        ),
      );

      await weekCalendarBloc.nextWeek();
      await weekCalendarBloc.previousWeek();
      await weekCalendarBloc.previousWeek();

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
      when(() => mockActivityRepository.allBetween(any(), any()))
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
              const {0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: []},
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
      when(() => mockActivityRepository.allBetween(any(), any())).thenAnswer(
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
                ActivityOccasion(
                  initalMinActivity,
                  initialMinutes.onlyDays(),
                  Occasion.current,
                ),
                ActivityOccasion(
                  nextMinActivity,
                  initialMinutes.onlyDays(),
                  Occasion.future,
                ),
              ],
              5: const [],
              6: const []
            },
            const {0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: []},
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
                ActivityOccasion(
                  initalMinActivity,
                  initialMinutes.onlyDays(),
                  Occasion.past,
                ),
                ActivityOccasion(
                  nextMinActivity,
                  initialMinutes.onlyDays(),
                  Occasion.current,
                ),
              ],
              5: const [],
              6: const []
            },
            const {0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: []},
          )),
        ),
      );
    });

    test('Adding new timer updates WeekCalendarState', () async {
      // Arrange
      when(() => mockActivityRepository.allBetween(any(), any()))
          .thenAnswer((_) => Future.value(const Iterable.empty()));
      final ticker = Ticker.fake(initialTime: initialMinutes);
      final timerCubit = TimerCubit(
        timerDb: MockTimerDb(),
        ticker: ticker,
      );
      final timerAlarmBloc = TimerAlarmBloc(
        timerCubit: timerCubit,
        ticker: ticker,
      );
      weekCalendarBloc = WeekCalendarCubit(
        activitiesBloc: activitiesBloc,
        timerAlarmBloc: timerAlarmBloc,
        activityRepository: mockActivityRepository,
        clockBloc: clockBloc,
      );

      final timerOccasion = AbiliaTimer(
              id: 'id', startTime: initialMinutes, duration: 20.minutes())
          .toOccasion(initialMinutes);
      // Act
      timerAlarmBloc.emit(TimerAlarmState.sort([timerOccasion]));
      await weekCalendarBloc.stream.first;
      expect(
        weekCalendarBloc.state,
        _WeekCalendarLoadedMatcher(
          WeekCalendarLoaded(
            initialMinutes.firstInWeek(),
            {
              0: const [],
              1: const [],
              2: const [],
              3: const [],
              4: [timerOccasion], // Day has timer
              5: const [],
              6: const []
            },
            {
              0: const [],
              1: const [],
              2: const [],
              3: const [],
              5: const [],
              6: const []
            },
          ),
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
      'WeekCalendarLoaded { currentWeekStart: ${value.currentWeekStart}, '
      'events: ${value.currentWeekEvents}}, fullday: ${value.fullDayActivities}}');

  @override
  bool matches(object, Map matchState) {
    return value.currentWeekStart == object.currentWeekStart &&
        const DeepCollectionEquality()
            .equals(value.currentWeekEvents, object.currentWeekEvents) &&
        const DeepCollectionEquality()
            .equals(value.fullDayActivities, object.fullDayActivities);
  }
}
