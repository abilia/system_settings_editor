import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:seagull_fakes/all.dart';

import '../../fakes/all.dart';
import '../../mocks/mocks.dart';

void main() {
  late DayEventsCubit dayEventsCubit;
  late DayPickerBloc dayPickerBloc;
  late ActivitiesBloc activitiesBloc;
  late MockActivityRepository mockActivityRepository;
  final initialMinutes = DateTime(2006, 06, 06, 06, 06);
  final initialDay = initialMinutes.onlyDays();
  final nextDay = initialDay.nextDay();
  final previousDay = initialDay.previousDay();

  setUp(() {
    dayPickerBloc = DayPickerBloc(clockBloc: ClockBloc.fixed(initialMinutes));
    mockActivityRepository = MockActivityRepository();
    when(() => mockActivityRepository.allBetween(any(), any()))
        .thenAnswer((_) => Future.value([]));
    final ticker = Ticker.fake(initialTime: initialMinutes);
    activitiesBloc = ActivitiesBloc(
      activityRepository: mockActivityRepository,
      syncBloc: FakeSyncBloc(),
    );
    dayEventsCubit = DayEventsCubit(
      dayPickerBloc: dayPickerBloc,
      activitiesBloc: activitiesBloc,
      timerAlarmBloc: TimerAlarmBloc(
        timerCubit: TimerCubit(
          timerDb: MockTimerDb(),
          ticker: ticker,
          analytics: FakeSeagullAnalytics(),
        ),
        ticker: ticker,
      ),
    )..initialize();
  });

  group('dayEventsCubit', () {
    test('initial state', () {
      expect(
        dayEventsCubit.state,
        EventsState(
          activities: const [],
          day: initialDay,
          occasion: Occasion.current,
          timers: const [],
        ),
      );
    });

    test('State is reloaded when activities bloc gets new state', () {
      final activity = FakeActivity.starts(initialMinutes);
      when(() => mockActivityRepository.allBetween(any(), any()))
          .thenAnswer((_) => Future.value([activity]));
      // Act
      activitiesBloc.add(LoadActivities());
      // Assert
      expectLater(
        dayEventsCubit.stream,
        emits(
          EventsState(
            timers: const [],
            activities: [ActivityDay(activity, initialDay)],
            fullDayActivities: const [],
            day: initialDay,
            occasion: Occasion.current,
          ),
        ),
      );
    });

    test('only loads todays activities with correct occasion in correct order',
        () {
      // Arrange
      final nowActivity = FakeActivity.starts(initialMinutes);
      final pastActivity =
          FakeActivity.ends(initialMinutes.subtract(1.minutes()));
      final futureActivity =
          FakeActivity.starts(initialMinutes.add(1.minutes()));
      when(() => mockActivityRepository.allBetween(any(), any())).thenAnswer(
          (_) => Future.value([nowActivity, pastActivity, futureActivity]));

      // Act
      activitiesBloc.add(LoadActivities());

      // Assert
      expectLater(
        dayEventsCubit.stream,
        emits(
          EventsState(
            activities: [
              ActivityDay(nowActivity, initialDay),
              ActivityDay(pastActivity, initialDay),
              ActivityDay(futureActivity, initialDay),
            ],
            timers: const [],
            fullDayActivities: const [],
            day: initialDay,
            occasion: Occasion.current,
          ),
        ),
      );
    });

    test('full day activities', () {
      // Arrange
      final fullDayActivity = FakeActivity.fullDay(initialMinutes);
      final tomorrowFullDay =
          FakeActivity.fullDay(initialMinutes.add(1.days()));
      final yesterdayFullDay =
          FakeActivity.fullDay(initialMinutes.subtract(1.days()));
      when(() => mockActivityRepository.allBetween(any(), any())).thenAnswer(
        (_) => Future.value(
          [
            yesterdayFullDay,
            tomorrowFullDay,
            fullDayActivity,
          ],
        ),
      );

      // Act
      activitiesBloc.add(LoadActivities());

      // Assert
      expectLater(
        dayEventsCubit.stream,
        emits(
          EventsState(
            activities: const [],
            timers: const [],
            fullDayActivities: [
              ActivityOccasion(fullDayActivity, initialDay, Occasion.future)
            ],
            day: initialDay,
            occasion: Occasion.current,
          ),
        ),
      );
    });

    test(
        'only loads todays activities with correct occasion in correct order and fullDay activities',
        () {
      // Arrange
      final nowActivity = FakeActivity.starts(initialMinutes);
      final pastActivity =
          FakeActivity.ends(initialMinutes.subtract(1.minutes()));
      final futureActivity =
          FakeActivity.starts(initialMinutes.add(1.minutes()));
      final fullDayActivity = FakeActivity.fullDay(initialMinutes);
      final tomorrowActivity =
          FakeActivity.starts(initialMinutes.add(1.days()));
      when(() => mockActivityRepository.allBetween(any(), any())).thenAnswer(
        (_) => Future.value([
          nowActivity,
          pastActivity,
          futureActivity,
          fullDayActivity,
          tomorrowActivity,
        ]),
      );

      // Act
      activitiesBloc.add(LoadActivities());

      // Assert
      expectLater(
        dayEventsCubit.stream,
        emits(
          EventsState(
            activities: [
              ActivityDay(nowActivity, initialDay),
              ActivityDay(pastActivity, initialDay),
              ActivityDay(futureActivity, initialDay),
            ],
            timers: const [],
            fullDayActivities: [
              ActivityOccasion(fullDayActivity, initialDay, Occasion.future)
            ],
            day: initialDay,
            occasion: Occasion.current,
          ),
        ),
      );
    });

    test('fullDay activities, today, tomorrow, yesterday', () async {
      // Arrange
      final fullDayActivity = FakeActivity.fullDay(initialMinutes);
      final tomorrowFullDay =
          FakeActivity.fullDay(initialMinutes.add(1.days()));
      final yesterdayFullDay =
          FakeActivity.fullDay(initialMinutes.subtract(1.days()));
      when(() => mockActivityRepository.allBetween(any(), any()))
          .thenAnswer((_) => Future.value([
                yesterdayFullDay,
                tomorrowFullDay,
                fullDayActivity,
              ]));

      // Act
      activitiesBloc.add(LoadActivities());
      // Assert
      await expectLater(
        dayEventsCubit.stream,
        emits(
          EventsState(
            activities: const [],
            fullDayActivities: [
              ActivityOccasion(fullDayActivity, initialDay, Occasion.future)
            ],
            timers: const [],
            day: initialDay,
            occasion: Occasion.current,
          ),
        ),
      );

      // Act
      dayPickerBloc
        ..add(NextDay())
        ..add(PreviousDay())
        ..add(PreviousDay());

      // Assert
      await expectLater(
        dayEventsCubit.stream,
        emitsInOrder([
          EventsState(
            activities: const [],
            fullDayActivities: [
              ActivityOccasion(tomorrowFullDay, nextDay, Occasion.future)
            ],
            timers: const [],
            day: nextDay,
            occasion: Occasion.future,
          ),
          EventsState(
            activities: const [],
            fullDayActivities: [
              ActivityOccasion(fullDayActivity, initialDay, Occasion.future)
            ],
            timers: const [],
            day: initialDay,
            occasion: Occasion.current,
          ),
          EventsState(
            activities: const [],
            fullDayActivities: [
              ActivityOccasion(yesterdayFullDay, previousDay, Occasion.past)
            ],
            timers: const [],
            day: previousDay,
            occasion: Occasion.past,
          ),
        ]),
      );
    });

    test(
        'only loads tomorrows activities with correct occasion in correct order and tomorrows full day',
        () {
      //Arrange
      final tomorrow = initialMinutes.add(const Duration(days: 1));
      final nowActivity = FakeActivity.starts(tomorrow);
      final pastActivity = FakeActivity.ends(tomorrow.add(1.minutes()));
      final futureActivity = FakeActivity.starts(tomorrow.add(1.minutes()));
      final fullDayActivity = FakeActivity.fullDay(tomorrow);
      when(() => mockActivityRepository.allBetween(any(), any())).thenAnswer(
          (_) => Future.value(
              [nowActivity, pastActivity, futureActivity, fullDayActivity]));
      //Act
      activitiesBloc.add(LoadActivities());
      dayPickerBloc.add(NextDay());
      //Assert
      expectLater(
        dayEventsCubit.stream,
        emits(
          EventsState(
            activities: [
              ActivityDay(nowActivity, nextDay),
              ActivityDay(pastActivity, nextDay),
              ActivityDay(futureActivity, nextDay),
            ],
            timers: const [],
            fullDayActivities: [
              ActivityOccasion(fullDayActivity, nextDay, Occasion.future)
            ],
            day: nextDay,
            occasion: Occasion.future,
          ),
        ),
      );
    });

    test(
        'only loads yesterday activities with correct occasion in correct order and yesterday full day',
        () {
      //Arrange
      final yesterday = initialMinutes.subtract(const Duration(days: 1));
      final nowActivity = FakeActivity.starts(yesterday);
      final pastActivity = FakeActivity.ends(yesterday.add(1.minutes()));
      final futureActivity = FakeActivity.starts(yesterday.add(1.minutes()));
      final fullDayActivity = FakeActivity.fullDay(yesterday);
      when(() => mockActivityRepository.allBetween(any(), any())).thenAnswer(
          (_) => Future.value(
              [nowActivity, pastActivity, futureActivity, fullDayActivity]));
      //Act
      activitiesBloc.add(LoadActivities());
      dayPickerBloc.add(PreviousDay());
      //Assert
      expectLater(
        dayEventsCubit.stream,
        emits(
          EventsState(
            activities: [
              ActivityDay(nowActivity, previousDay),
              ActivityDay(pastActivity, previousDay),
              ActivityDay(futureActivity, previousDay),
            ],
            timers: const [],
            fullDayActivities: [
              ActivityOccasion(fullDayActivity, previousDay, Occasion.past)
            ],
            day: previousDay,
            occasion: Occasion.past,
          ),
        ),
      );
    });

    test('Activity ends this minute is current', () {
      // Arrange
      final endsSoon = FakeActivity.ends(initialMinutes);
      when(() => mockActivityRepository.allBetween(any(), any()))
          .thenAnswer((_) => Future.value([endsSoon]));

      // Act
      activitiesBloc.add(LoadActivities());

      expectLater(
        dayEventsCubit.stream,
        emits(
          EventsState(
            activities: [
              ActivityDay(endsSoon, initialDay),
            ],
            timers: const [],
            fullDayActivities: const [],
            day: initialDay,
            occasion: Occasion.current,
          ),
        ),
      );
    });

    test('Activity start this minute is current', () {
      // Arrange
      final startsNow = FakeActivity.starts(initialMinutes);
      when(() => mockActivityRepository.allBetween(any(), any()))
          .thenAnswer((_) => Future.value([startsNow]));

      // Act
      activitiesBloc.add(LoadActivities());

      // Assert
      expectLater(
        dayEventsCubit.stream,
        emits(
          EventsState(
            activities: [
              ActivityDay(startsNow, initialDay),
            ],
            timers: const [],
            fullDayActivities: const [],
            day: initialDay,
            occasion: Occasion.current,
          ),
        ),
      );
    });

    test('Changing now changing order', () async {
      // Arrange
      final nextMinute = initialMinutes.add(const Duration(minutes: 1));
      final nowActivity =
          FakeActivity.starts(initialMinutes.onlyDays(), duration: 16.hours());
      final endsSoonActivity = FakeActivity.ends(initialMinutes);
      final startSoonActivity =
          FakeActivity.starts(initialMinutes.add(1.minutes()));
      when(() => mockActivityRepository.allBetween(any(), any())).thenAnswer(
          (_) =>
              Future.value([nowActivity, startSoonActivity, endsSoonActivity]));

      // Act
      activitiesBloc.add(LoadActivities());

      // Assert
      await expectLater(
        dayEventsCubit.stream,
        emits(
          EventsState(
            activities: [
              ActivityDay(nowActivity, initialDay),
              ActivityDay(startSoonActivity, initialDay),
              ActivityDay(endsSoonActivity, initialDay),
            ],
            timers: const [],
            fullDayActivities: const [],
            day: initialDay,
            occasion: Occasion.current,
          ),
        ),
      );

      final dayEventsState = dayEventsCubit.state;

      final thisMinPastEvents = dayEventsState.pastEvents(initialMinutes);
      final thisMinNotPastEvents = dayEventsState.notPastEvents(initialMinutes);
      expect(thisMinPastEvents, isEmpty);
      expect(thisMinNotPastEvents, [
        ActivityOccasion(nowActivity, initialDay, Occasion.current),
        ActivityOccasion(endsSoonActivity, initialDay, Occasion.current),
        ActivityOccasion(startSoonActivity, initialDay, Occasion.future),
      ]);

      final nextMinPastEvents = dayEventsState.pastEvents(nextMinute);
      final nextMinNotPastEvents = dayEventsState.notPastEvents(nextMinute);
      expect(nextMinPastEvents, [
        ActivityOccasion(endsSoonActivity, initialDay, Occasion.past),
      ]);
      expect(nextMinNotPastEvents, [
        ActivityOccasion(nowActivity, initialDay, Occasion.current),
        ActivityOccasion(startSoonActivity, initialDay, Occasion.current),
      ]);
    });
  });

  group('dayEventsCubit recurring', () {
    test('Shows recurring past, present and future', () async {
      // Arrange
      final longAgo = initialMinutes.subtract(const Duration(days: 1111));
      final weekendActivity = FakeActivity.reoccursWeekends(longAgo);
      final tuesdayRecurring = FakeActivity.reoccursTuesdays(longAgo);
      final mondayRecurring = FakeActivity.reoccursMondays(longAgo);
      final activities = const Iterable<Activity>.empty()
          .followedBy([weekendActivity, tuesdayRecurring, mondayRecurring]);
      when(() => mockActivityRepository.allBetween(any(), any()))
          .thenAnswer((_) => Future.value(activities));

      final friday = initialDay.add(const Duration(days: 3));
      final saturday = friday.add(const Duration(days: 1));
      final sunday = saturday.add(const Duration(days: 1));
      final monday = sunday.add(const Duration(days: 1));

      // Act
      activitiesBloc.add(LoadActivities());
      await expectLater(
        dayEventsCubit.stream,
        emits(
          // Tuesday
          EventsState(
            activities: [
              ActivityDay(tuesdayRecurring, initialDay),
            ],
            timers: const [],
            fullDayActivities: const [],
            day: initialDay,
            occasion: Occasion.current,
          ),
        ),
      );
      dayPickerBloc
        ..add(PreviousDay())
        ..add(GoTo(day: friday))
        ..add(NextDay())
        ..add(NextDay())
        ..add(NextDay());

      // Assert
      await expectLater(
          dayEventsCubit.stream,
          emitsInOrder([
            // monday
            EventsState(
              activities: [
                ActivityDay(mondayRecurring,
                    initialDay.subtract(const Duration(days: 1))),
              ],
              timers: const [],
              fullDayActivities: const [],
              day: previousDay,
              occasion: Occasion.past,
            ),
            // Friday
            EventsState(
              activities: const [],
              timers: const [],
              fullDayActivities: const [],
              day: friday,
              occasion: Occasion.future,
            ),
            // Saturday
            EventsState(
              activities: [
                ActivityDay(weekendActivity, saturday),
              ],
              timers: const [],
              fullDayActivities: const [],
              day: saturday,
              occasion: Occasion.future,
            ),
            // Sunday
            EventsState(
              activities: [
                ActivityDay(weekendActivity, sunday),
              ],
              timers: const [],
              fullDayActivities: const [],
              day: sunday,
              occasion: Occasion.future,
            ),
            // Monday
            EventsState(
              activities: [
                ActivityDay(mondayRecurring, monday),
              ],
              timers: const [],
              fullDayActivities: const [],
              day: monday,
              occasion: Occasion.future,
            ),
          ]));
    });
  });

  group('Remove after', () {
    test(
        "Don't show past days remove after activities, "
        'but show present and future', () async {
      // Arrange
      final longAgo = initialMinutes.subtract(1111.days());
      final yesterday = initialDay.subtract(1.days());
      final tomorrow = initialDay.add(1.days());
      final in1Hour = initialMinutes.add(1.hours());

      final everyDayRecurring =
          FakeActivity.reoccursEveryDay(longAgo).copyWith(removeAfter: true);
      final todayActivity =
          FakeActivity.starts(in1Hour).copyWith(removeAfter: true);
      final yesterdayActivity = FakeActivity.starts(in1Hour.subtract(1.days()))
          .copyWith(removeAfter: true);
      final tomorrowActivity = FakeActivity.starts(in1Hour.add(1.days()))
          .copyWith(removeAfter: true);
      final everyDayFullDayRecurring = FakeActivity.fullDay(longAgo).copyWith(
        removeAfter: true,
        recurs: Recurs.weeklyOnDays(
          List.generate(5, (d) => d + 1),
          ends: DateTime.fromMillisecondsSinceEpoch(253402297199000),
        ),
      );

      final activities = const Iterable<Activity>.empty().followedBy([
        everyDayRecurring,
        todayActivity,
        yesterdayActivity,
        tomorrowActivity,
        everyDayFullDayRecurring
      ]);
      when(() => mockActivityRepository.allBetween(any(), any()))
          .thenAnswer((_) => Future.value(activities));

      // Act
      activitiesBloc.add(LoadActivities());

      // Assert
      await expectLater(
        dayEventsCubit.stream,
        emits(
          // Tuesday
          EventsState(
            activities: [
              ActivityDay(everyDayRecurring, initialDay),
              ActivityDay(todayActivity, initialDay),
            ],
            timers: const [],
            fullDayActivities: [
              ActivityOccasion(
                  everyDayFullDayRecurring, initialDay, Occasion.future),
            ],
            day: initialDay,
            occasion: Occasion.current,
          ),
        ),
      );
      dayPickerBloc
        ..add(PreviousDay())
        ..add(NextDay())
        ..add(NextDay());

      // Assert
      await expectLater(
          dayEventsCubit.stream,
          emitsInOrder([
            // Monday
            EventsState(
                activities: const [],
                timers: const [],
                fullDayActivities: const [],
                day: yesterday,
                occasion: Occasion.past),
            // Tuesday
            EventsState(
              activities: [
                ActivityDay(everyDayRecurring, initialDay),
                ActivityDay(todayActivity, initialDay),
              ],
              timers: const [],
              fullDayActivities: [
                ActivityOccasion(
                    everyDayFullDayRecurring, initialDay, Occasion.future),
              ],
              day: initialDay,
              occasion: Occasion.current,
            ),
            // Wednesday
            EventsState(
              activities: [
                ActivityDay(everyDayRecurring, tomorrow),
                ActivityDay(tomorrowActivity, tomorrow),
              ],
              timers: const [],
              fullDayActivities: [
                ActivityOccasion(
                  everyDayFullDayRecurring,
                  tomorrow,
                  Occasion.future,
                ),
              ],
              day: tomorrow,
              occasion: Occasion.future,
            ),
          ]));
    });
  });

  group('activities spanning multiple days', () {
    test('Shows into this day', () async {
      // Arrange
      final longAgo = initialMinutes.subtract(1111.days());
      final yesterday = initialDay.previousDay();
      final dayBeforeYesterday = yesterday.previousDay();
      final tomorrow = initialDay.nextDay();

      final everyDayRecurring = Activity.createNew(
        title: 'title',
        startTime: longAgo,
        duration: 48.hours(),
        recurs: Recurs.everyDay,
      );

      final activities = const Iterable<Activity>.empty().followedBy([
        everyDayRecurring,
      ]);
      when(() => mockActivityRepository.allBetween(any(), any()))
          .thenAnswer((_) => Future.value(activities));

      // Act
      activitiesBloc.add(LoadActivities());

      // Assert
      await expectLater(
        dayEventsCubit.stream,
        emits(
          // Tuesday
          EventsState(
            activities: [
              ActivityDay(everyDayRecurring, initialDay),
              ActivityDay(everyDayRecurring, yesterday),
              ActivityDay(everyDayRecurring, dayBeforeYesterday),
            ],
            timers: const [],
            fullDayActivities: const [],
            day: initialDay,
            occasion: Occasion.current,
          ),
        ),
      );

      // Act
      dayPickerBloc.add(NextDay());

      // Assert
      await expectLater(
        dayEventsCubit.stream,
        emits(
          // Monday
          EventsState(
            activities: [
              ActivityDay(everyDayRecurring, tomorrow),
              ActivityDay(everyDayRecurring, initialDay),
              ActivityDay(everyDayRecurring, yesterday),
            ],
            timers: const [],
            fullDayActivities: const [],
            day: tomorrow,
            occasion: Occasion.future,
          ),
        ),
      );
    });

    test('overlapping into this day before starting early today', () async {
      // Arrange
      final longAgo = initialMinutes.copyWith(hour: 23).subtract(1111.days());
      final monday = initialDay.previousDay();

      final mondayRecurring = Activity.createNew(
        title: 'Recurs.MONDAY',
        startTime: longAgo,
        duration: 10.hours(),
        recurs: Recurs.weeklyOnDay(DateTime.monday),
      );
      final earlyActivity = Activity.createNew(
        title: 'earlyActivity',
        startTime: initialMinutes.copyWith(hour: 00, minute: 00),
      );
      final earlyCurrent = Activity.createNew(
        title: 'earlyCurrent',
        startTime: initialMinutes.copyWith(hour: 00, minute: 00),
        duration: 9.hours(),
      );

      final activities = const Iterable<Activity>.empty().followedBy([
        mondayRecurring,
        earlyActivity,
        earlyCurrent,
      ]);
      when(() => mockActivityRepository.allBetween(any(), any()))
          .thenAnswer((_) => Future.value(activities));

      // Act
      activitiesBloc.add(LoadActivities());

      // Assert
      await expectLater(
          dayEventsCubit.stream,
          emitsInOrder([
            // Tuesday
            EventsState(
              activities: [
                ActivityDay(mondayRecurring, monday),
                ActivityDay(earlyActivity, initialDay),
                ActivityDay(earlyCurrent, initialDay),
              ],
              timers: const [],
              fullDayActivities: const [],
              day: initialDay,
              occasion: Occasion.current,
            ),
          ]));
    });
  });

  final today = DateTime(2020, 01, 01);
  final yesterday = today.previousDay();
  final tomorrow = today.nextDay();
  group('Test from old DayActivitiesBloc', () {
    setUp(() {
      dayPickerBloc = DayPickerBloc(
        clockBloc: ClockBloc.fixed(today),
      );
      mockActivityRepository = MockActivityRepository();
      when(() => mockActivityRepository.allBetween(any(), any()))
          .thenAnswer((_) => Future.value([]));

      activitiesBloc = ActivitiesBloc(
        activityRepository: mockActivityRepository,
        syncBloc: FakeSyncBloc(),
      );
      final ticker = Ticker.fake(initialTime: initialMinutes);

      dayEventsCubit = DayEventsCubit(
        dayPickerBloc: dayPickerBloc,
        activitiesBloc: activitiesBloc,
        timerAlarmBloc: TimerAlarmBloc(
          timerCubit: TimerCubit(
            timerDb: MockTimerDb(),
            ticker: ticker,
            analytics: FakeSeagullAnalytics(),
          ),
          ticker: ticker,
        ),
      )..initialize();
    });

    test('EventsOccasionLoaded only loads todays activities', () {
      // Arrange
      final activitiesNow = [FakeActivity.starts(today)];
      final expected = activitiesNow.map((a) => ActivityDay(a, today)).toList();
      final activitiesTomorrow = [FakeActivity.starts(today.add(1.days()))];

      when(() => mockActivityRepository.allBetween(any(), any())).thenAnswer(
          (_) => Future.value(activitiesNow.followedBy(activitiesTomorrow)));

      // Act
      activitiesBloc.add(LoadActivities());

      // Assert
      expectLater(
        dayEventsCubit.stream,
        emits(
          EventsState(
            activities: expected,
            timers: const [],
            day: today,
            occasion: Occasion.current,
          ),
        ),
      );
    });

    test('next day loads next days activities', () async {
      // Arrange
      final activitiesNow = [FakeActivity.starts(today)];
      final expectedToday =
          activitiesNow.map((a) => ActivityDay(a, today)).toList();
      final activitiesTomorrow = [FakeActivity.starts(tomorrow)];
      final expectedTomorrow = activitiesTomorrow
          .map((a) => ActivityDay(a, today.nextDay()))
          .toList();
      when(() => mockActivityRepository.allBetween(any(), any())).thenAnswer(
          (_) => Future.value(activitiesNow.followedBy(activitiesTomorrow)));

      // Act
      activitiesBloc.add(LoadActivities());
      // Assert
      await expectLater(
        dayEventsCubit.stream,
        emits(
          EventsState(
            activities: expectedToday,
            timers: const [],
            day: today,
            occasion: Occasion.current,
          ),
        ),
      );

      // Act
      dayPickerBloc.add(NextDay());
      // Assert
      await expectLater(
        dayEventsCubit.stream,
        emits(
          EventsState(
            activities: expectedTomorrow,
            timers: const [],
            day: tomorrow,
            occasion: Occasion.future,
          ),
        ),
      );
    });

    test('previous day loads previous days activities', () async {
      // Arrange
      final activitiesNow = [(FakeActivity.starts(today))];
      final expectedNow =
          activitiesNow.map((a) => ActivityDay(a, today)).toList();
      final activitiesYesterDay = [
        FakeActivity.starts(today.subtract(1.days()))
      ];
      final expectedYesterday = activitiesYesterDay
          .map((e) => ActivityDay(e, today.previousDay()))
          .toList();
      when(() => mockActivityRepository.allBetween(any(), any())).thenAnswer(
          (_) => Future.value(activitiesNow.followedBy(activitiesYesterDay)));

      // Act
      activitiesBloc.add(LoadActivities());
      // Assert
      await expectLater(
        dayEventsCubit.stream,
        emits(
          EventsState(
            activities: expectedNow,
            timers: const [],
            day: today,
            occasion: Occasion.current,
          ),
        ),
      );

      // Act
      dayPickerBloc.add(PreviousDay());
      // Assert
      await expectLater(
        dayEventsCubit.stream,
        emits(
          EventsState(
            activities: expectedYesterday,
            timers: const [],
            day: yesterday,
            occasion: Occasion.past,
          ),
        ),
      );
    });

    test('does not show next years activities', () async {
      // Arrange
      final nextYear = today.add(const Duration(days: 365));

      when(() => mockActivityRepository.allBetween(any(), any()))
          .thenAnswer((_) => Future.value([
                FakeActivity.starts(nextYear),
                FakeActivity.starts(nextYear.add(1.days())),
                FakeActivity.starts(nextYear.subtract(1.days())),
              ]));

      // Act
      dayPickerBloc
        ..add(NextDay())
        ..add(PreviousDay())
        ..add(PreviousDay());

      // Assert
      await expectLater(
        dayEventsCubit.stream,
        emitsInOrder([
          EventsState(
            activities: const [],
            timers: const [],
            day: tomorrow,
            occasion: Occasion.future,
          ),
          EventsState(
            activities: const [],
            timers: const [],
            day: today,
            occasion: Occasion.current,
          ),
          EventsState(
            activities: const [],
            timers: const [],
            day: yesterday,
            occasion: Occasion.past,
          ),
        ]),
      );
    });

    test('adding activities shows', () async {
      // Arrange
      final todayActivity = [
        FakeActivity.starts(today),
      ];
      final expectedActivity =
          todayActivity.map((a) => ActivityDay(a, today)).toList();
      final activitiesAdded = todayActivity.followedBy([
        FakeActivity.starts(today.add(1.days())),
        FakeActivity.starts(today.subtract(1.days())),
      ]).followedBy({});

      // Arrange
      when(() => mockActivityRepository.allBetween(any(), any()))
          .thenAnswer((_) => Future.value(activitiesAdded));

      // Act
      activitiesBloc.add(LoadActivities());

      // Assert
      await expectLater(
        dayEventsCubit.stream,
        emits(
          EventsState(
            activities: expectedActivity,
            timers: const [],
            day: today,
            occasion: Occasion.current,
          ),
        ),
      );
    });

    tearDown(() {
      dayPickerBloc.close();
      activitiesBloc.close();
    });

    group('Recurring tests activity', () {
      final firstDay = DateTime(2006, 06, 01); // 2006-06-01 was a Thursday
      setUp(() {
        dayPickerBloc = DayPickerBloc(clockBloc: ClockBloc.fixed(firstDay));
        mockActivityRepository = MockActivityRepository();
        when(() => mockActivityRepository.allBetween(any(), any()))
            .thenAnswer((_) => Future.value([]));
        activitiesBloc = ActivitiesBloc(
          activityRepository: mockActivityRepository,
          syncBloc: FakeSyncBloc(),
        );
        final ticker = Ticker.fake(initialTime: today);
        dayEventsCubit = DayEventsCubit(
          dayPickerBloc: dayPickerBloc,
          activitiesBloc: activitiesBloc,
          timerAlarmBloc: TimerAlarmBloc(
            timerCubit: TimerCubit(
              timerDb: MockTimerDb(),
              ticker: ticker,
              analytics: FakeSeagullAnalytics(),
            ),
            ticker: ticker,
          ),
        )..initialize();
      });

      test('Shows recurring weekends', () async {
        // Arrange
        final weekendActivity = [
          FakeActivity.reoccursWeekends(DateTime(2000, 01, 01))
        ];
        when(() => mockActivityRepository.allBetween(any(), any()))
            .thenAnswer((_) => Future.value(weekendActivity));
        // Act
        activitiesBloc.add(LoadActivities());

        dayPickerBloc
          ..add(NextDay())
          ..add(NextDay())
          ..add(NextDay())
          ..add(NextDay());
        // Assert
        await expectLater(
            dayEventsCubit.stream,
            emitsInOrder([
              EventsState(
                activities: const [],
                timers: const [],
                day: firstDay.add(const Duration(days: 1)),
                occasion: Occasion.future,
              ), // friday
              EventsState(
                activities: weekendActivity
                    .map((a) =>
                        ActivityDay(a, firstDay.add(const Duration(days: 2))))
                    .toList(),
                timers: const [],
                day: firstDay.add(const Duration(days: 2)),
                occasion: Occasion.future,
              ),

              // saturday
              EventsState(
                activities: weekendActivity
                    .map((a) =>
                        ActivityDay(a, firstDay.add(const Duration(days: 3))))
                    .toList(),
                timers: const [],
                day: firstDay.add(const Duration(days: 3)),
                occasion: Occasion.future,
              ), // sunday
              EventsState(
                activities: const [],
                timers: const [],
                day: firstDay.add(const Duration(days: 4)),
                occasion: Occasion.future,
              ), // monday
            ]));
      });

      test('Shows recurring christmas', () async {
        // Arrange
        final boxingDay = DateTime(2000, 12, 23);
        final christmasEve = DateTime(2000, 12, 24);
        final christmasDay = DateTime(2000, 12, 25);
        final christmas = [
          FakeActivity.reoccursOnDate(christmasEve, DateTime(2000, 01, 01))
        ];
        when(() => mockActivityRepository.allBetween(any(), any()))
            .thenAnswer((_) => Future.value(christmas));
        // Act
        activitiesBloc.add(LoadActivities());

        dayPickerBloc
          ..add(GoTo(day: boxingDay))
          ..add(NextDay())
          ..add(NextDay());
        // Assert
        await expectLater(
            dayEventsCubit.stream,
            emitsInOrder([
              EventsState(
                activities: const [],
                timers: const [],
                day: boxingDay,
                occasion: Occasion.past,
              ),
              EventsState(
                activities:
                    christmas.map((a) => ActivityDay(a, christmasEve)).toList(),
                timers: const [],
                day: christmasEve,
                occasion: Occasion.past,
              ),
              EventsState(
                activities: const [],
                timers: const [],
                day: christmasDay,
                occasion: Occasion.past,
              ),
            ]));
      });

      test('Does not show recurring christmas after endTime', () async {
        // Arrange
        final boxingDay = DateTime(2022, 12, 23);
        final christmasEve = DateTime(2022, 12, 24);
        final christmasDay = DateTime(2022, 12, 25);
        final christmas = const Iterable<Activity>.empty().followedBy([
          FakeActivity.reoccursOnDate(
              christmasEve, DateTime(2012, 01, 01), DateTime(2021, 01, 01))
        ]);
        when(() => mockActivityRepository.allBetween(any(), any()))
            .thenAnswer((_) => Future.value(christmas));
        // Act
        activitiesBloc.add(LoadActivities());

        dayPickerBloc
          ..add(GoTo(day: boxingDay))
          ..add(NextDay())
          ..add(NextDay());
        // Assert
        await expectLater(
            dayEventsCubit.stream,
            emitsInOrder([
              EventsState(
                activities: const [],
                timers: const [],
                day: boxingDay,
                occasion: Occasion.future,
              ),
              EventsState(
                activities: const [],
                timers: const [],
                day: christmasEve,
                occasion: Occasion.future,
              ),
              EventsState(
                activities: const [],
                timers: const [],
                day: christmasDay,
                occasion: Occasion.future,
              ),
            ]));
      });

      test('Show first of month during one year', () async {
        // Arrange
        final startTime = DateTime(2031, 12, 31);
        final endTime = DateTime(2032, 12, 31);
        final monthStartActivity = [
          FakeActivity.reoccursOnDay(1, startTime, endTime)
        ];
        final allOtherDays = List.generate(
            300, (i) => startTime.add(Duration(days: i)).onlyDays());
        when(() => mockActivityRepository.allBetween(any(), any()))
            .thenAnswer((_) => Future.value(monthStartActivity));

        // Act
        activitiesBloc.add(LoadActivities());

        dayPickerBloc.add(GoTo(day: startTime));
        for (var i = 0; i < allOtherDays.length; i++) {
          dayPickerBloc.add(NextDay());
        }

        // Assert
        await expectLater(
          dayEventsCubit.stream,
          emitsInOrder(
            allOtherDays.map(
              (day) => EventsState(
                activities: day.day == 1
                    ? monthStartActivity
                        .map((a) => ActivityDay(a, day))
                        .toList()
                    : [],
                timers: const [],
                day: day,
                occasion: Occasion.future,
              ),
            ),
          ),
        );
      });

      test('Split up activity shows on day it was split up on ( bug test )',
          () async {
        // Arrange
        final preSplitStartTime = 1573513200000.fromMillisecondsSinceEpoch(),
            preSplitEndTime = 1574377199999.fromMillisecondsSinceEpoch(),
            splitStartTime = 1574380800000.fromMillisecondsSinceEpoch(),
            splitEndTime = 253402297199000.fromMillisecondsSinceEpoch();

        final dayBeforeSplit = preSplitEndTime.onlyDays();
        final dayOnSplit = splitStartTime.onlyDays();

        final preSplitRecurring = Activity.createNew(
          title: 'Pre Split Recurring',
          recurs: Recurs.raw(
            Recurs.typeWeekly,
            16383,
            preSplitEndTime.millisecondsSinceEpoch,
          ),
          alarmType: 104,
          duration: 86399999.milliseconds(),
          startTime: preSplitStartTime,
          fullDay: true,
        );

        final splitRecurring = Activity.createNew(
          title: 'Split recurring ',
          recurs: Recurs.raw(
            Recurs.typeWeekly,
            16383,
            splitEndTime.millisecondsSinceEpoch,
          ),
          alarmType: 104,
          duration: 86399999.milliseconds(),
          startTime: splitStartTime,
          fullDay: true,
        );

        when(() => mockActivityRepository.allBetween(any(), any())).thenAnswer(
            (_) => Future.value([preSplitRecurring, splitRecurring]));

        // Act
        dayPickerBloc
          ..add(GoTo(day: dayBeforeSplit))
          ..add(NextDay())
          ..add(NextDay());

        // Assert
        await expectLater(
          dayEventsCubit.stream,
          emitsInOrder([
            EventsState(
              activities: const [],
              fullDayActivities: [preSplitRecurring]
                  .map((a) =>
                      ActivityOccasion(a, dayBeforeSplit, Occasion.future))
                  .toList(),
              timers: const [],
              day: dayBeforeSplit,
              occasion: Occasion.future,
            ),
            EventsState(
              activities: const [],
              fullDayActivities: [splitRecurring]
                  .map((a) => ActivityOccasion(a, dayOnSplit, Occasion.future))
                  .toList(),
              timers: const [],
              day: dayOnSplit,
              occasion: Occasion.future,
            ),
            EventsState(
              activities: const [],
              fullDayActivities: [splitRecurring]
                  .map((e) => ActivityOccasion(e,
                      dayOnSplit.add(const Duration(days: 1)), Occasion.future))
                  .toList(),
              timers: const [],
              day: dayOnSplit.add(const Duration(days: 1)),
              occasion: Occasion.future,
            ),
          ]),
        );
      });
    });
  });

  tearDown(() {
    dayPickerBloc.close();
    activitiesBloc.close();
    dayEventsCubit.close();
  });
}
