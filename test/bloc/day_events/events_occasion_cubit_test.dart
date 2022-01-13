import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

import '../../fakes/fakes_blocs.dart';
import '../../mocks/mocks.dart';

void main() {
  late DayEventsCubit dayEventsCubit;
  late DayPickerBloc dayPickerBloc;
  late ClockBloc clockBloc;
  late ActivitiesBloc activitiesBloc;
  late TimerCubit timerCubit;
  late EventsOccasionCubit eventsOccasionCubit;
  late MockActivityRepository mockActivityRepository;
  late MockTimerDb mockTimerDb;
  late StreamController<DateTime> mockedTicker;
  final initialMinutes = DateTime(2006, 06, 06, 06, 06);
  final initialDay = initialMinutes.onlyDays();
  final nextDay = initialDay.nextDay();
  final previusDay = initialDay.previousDay();

  setUp(() {
    mockedTicker = StreamController<DateTime>();
    clockBloc = ClockBloc(mockedTicker.stream, initialTime: initialMinutes);
    dayPickerBloc = DayPickerBloc(clockBloc: clockBloc);
    mockActivityRepository = MockActivityRepository();
    mockTimerDb = MockTimerDb();
    activitiesBloc = ActivitiesBloc(
      activityRepository: mockActivityRepository,
      syncBloc: FakeSyncBloc(),
      pushBloc: FakePushBloc(),
    );
    timerCubit = TimerCubit(timerDb: mockTimerDb);
    dayEventsCubit = DayEventsCubit(
      dayPickerBloc: dayPickerBloc,
      activitiesBloc: activitiesBloc,
      timerCubit: timerCubit,
    );
    eventsOccasionCubit = EventsOccasionCubit(
      dayEventsCubit: dayEventsCubit,
    );
  });
  group('EventsOccasionCubit', () {
    test('initial state is Loading', () {
      expect(eventsOccasionCubit.state, const EventsOccasionLoading());
    });

    test('state is EventsOccasionLoaded when ActivitiesBloc loadeds activities',
        () {
      // Arrange
      when(() => mockActivityRepository.load())
          .thenAnswer((_) => Future.value(const Iterable.empty()));
      // Act
      activitiesBloc.add(LoadActivities());
      // Assert
      expectLater(
        eventsOccasionCubit.stream,
        emits(
          EventsOccasionLoaded(
            timers: const <TimerDay>[],
            activities: const [],
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
      when(() => mockActivityRepository.load()).thenAnswer(
          (_) => Future.value([nowActivity, pastActivity, futureActivity]));

      // Act
      activitiesBloc.add(LoadActivities());
      activitiesBloc.add(LoadActivities());

      // Assert
      expectLater(
        eventsOccasionCubit.stream,
        emits(
          EventsOccasionLoaded(
            activities: [
              ActivityDay(pastActivity, initialDay),
              ActivityDay(nowActivity, initialDay),
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

    test('fullday activities', () {
      // Arrange
      final fullDayActivity = FakeActivity.fullday(initialMinutes);
      final tomorrowFullday =
          FakeActivity.fullday(initialMinutes.add(1.days()));
      final yesterdayFullday =
          FakeActivity.fullday(initialMinutes.subtract(1.days()));
      when(() => mockActivityRepository.load()).thenAnswer((_) => Future.value([
            yesterdayFullday,
            tomorrowFullday,
            fullDayActivity,
          ]));

      // Act
      activitiesBloc.add(LoadActivities());

      // Assert
      expectLater(
        eventsOccasionCubit.stream,
        emits(
          EventsOccasionLoaded(
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
        'only loads todays activities with correct occasion in correct order and fullday activities',
        () {
      // Arrange
      final nowActivity = FakeActivity.starts(initialMinutes);
      final pastActivity =
          FakeActivity.ends(initialMinutes.subtract(1.minutes()));
      final futureActivity =
          FakeActivity.starts(initialMinutes.add(1.minutes()));
      final fullDayActivity = FakeActivity.fullday(initialMinutes);
      final tomorrowActivity =
          FakeActivity.starts(initialMinutes.add(1.days()));
      when(() => mockActivityRepository.load()).thenAnswer((_) => Future.value([
            nowActivity,
            pastActivity,
            futureActivity,
            fullDayActivity,
            tomorrowActivity
          ]));

      // Act
      activitiesBloc.add(LoadActivities());

      // Assert
      expectLater(
        eventsOccasionCubit.stream,
        emits(
          EventsOccasionLoaded(
            activities: [
              ActivityDay(pastActivity, initialDay),
              ActivityDay(nowActivity, initialDay),
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

    test('fullday activities, today, tomorrow, yesterday', () async {
      // Arrange
      final fullDayActivity = FakeActivity.fullday(initialMinutes);
      final tomorrowFullday =
          FakeActivity.fullday(initialMinutes.add(1.days()));
      final yesterdayFullday =
          FakeActivity.fullday(initialMinutes.subtract(1.days()));
      when(() => mockActivityRepository.load()).thenAnswer((_) => Future.value([
            yesterdayFullday,
            tomorrowFullday,
            fullDayActivity,
          ]));

      // Act
      activitiesBloc.add(LoadActivities());
      // Assert
      await expectLater(
        eventsOccasionCubit.stream,
        emits(
          EventsOccasionLoaded(
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
      dayPickerBloc.add(NextDay());
      dayPickerBloc.add(PreviousDay());
      dayPickerBloc.add(PreviousDay());

      // Assert
      await expectLater(
        eventsOccasionCubit.stream,
        emitsInOrder([
          EventsOccasionLoaded(
            activities: const [],
            fullDayActivities: [
              ActivityOccasion(tomorrowFullday, nextDay, Occasion.future)
            ],
            timers: const [],
            day: nextDay,
            occasion: Occasion.future,
          ),
          EventsOccasionLoaded(
            activities: const [],
            fullDayActivities: [
              ActivityOccasion(fullDayActivity, initialDay, Occasion.future)
            ],
            timers: const [],
            day: initialDay,
            occasion: Occasion.current,
          ),
          EventsOccasionLoaded(
            activities: const [],
            fullDayActivities: [
              ActivityOccasion(yesterdayFullday, previusDay, Occasion.past)
            ],
            timers: const [],
            day: previusDay,
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
      final fulldayActivity = FakeActivity.fullday(tomorrow);
      when(() => mockActivityRepository.load()).thenAnswer((_) => Future.value(
          [nowActivity, pastActivity, futureActivity, fulldayActivity]));
      //Act
      activitiesBloc.add(LoadActivities());
      dayPickerBloc.add(NextDay());
      //Assert
      expectLater(
        eventsOccasionCubit.stream,
        emits(
          EventsOccasionLoaded(
            activities: [
              ActivityDay(pastActivity, nextDay),
              ActivityDay(nowActivity, nextDay),
              ActivityDay(futureActivity, nextDay),
            ],
            timers: const [],
            fullDayActivities: [
              ActivityOccasion(fulldayActivity, nextDay, Occasion.future)
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
      final fulldayActivity = FakeActivity.fullday(yesterday);
      when(() => mockActivityRepository.load()).thenAnswer((_) => Future.value(
          [nowActivity, pastActivity, futureActivity, fulldayActivity]));
      //Act
      activitiesBloc.add(LoadActivities());
      dayPickerBloc.add(PreviousDay());
      //Assert
      expectLater(
        eventsOccasionCubit.stream,
        emits(
          EventsOccasionLoaded(
            activities: [
              ActivityDay(pastActivity, previusDay),
              ActivityDay(nowActivity, previusDay),
              ActivityDay(futureActivity, previusDay),
            ],
            timers: const [],
            fullDayActivities: [
              ActivityOccasion(fulldayActivity, previusDay, Occasion.past)
            ],
            day: previusDay,
            occasion: Occasion.past,
          ),
        ),
      );
    });

    test('Activity ends this minute is current', () {
      // Arrange
      final endsSoon = FakeActivity.ends(initialMinutes);
      when(() => mockActivityRepository.load())
          .thenAnswer((_) => Future.value([endsSoon]));

      // Act
      activitiesBloc.add(LoadActivities());

      expectLater(
        eventsOccasionCubit.stream,
        emits(
          EventsOccasionLoaded(
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
      when(() => mockActivityRepository.load())
          .thenAnswer((_) => Future.value([startsNow]));

      // Act
      activitiesBloc.add(LoadActivities());

      // Assert
      expectLater(
        eventsOccasionCubit.stream,
        emits(
          EventsOccasionLoaded(
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
      when(() => mockActivityRepository.load()).thenAnswer((_) =>
          Future.value([nowActivity, startSoonActivity, endsSoonActivity]));

      // Act
      activitiesBloc.add(LoadActivities());

      // Assert
      await expectLater(
        eventsOccasionCubit.stream,
        emits(
          EventsOccasionLoaded(
            activities: [
              ActivityDay(nowActivity, initialDay),
              ActivityDay(endsSoonActivity, initialDay),
              ActivityDay(startSoonActivity, initialDay),
            ],
            timers: const [],
            fullDayActivities: const [],
            day: initialDay,
            occasion: Occasion.current,
          ),
        ),
      );

      final eventsOccasionLoaded =
          eventsOccasionCubit.state as EventsOccasionLoaded;

      final thisMinpastEvents = eventsOccasionLoaded.pastEvents(initialMinutes);
      final thisMinNotPastEvents =
          eventsOccasionLoaded.notPastEvents(initialMinutes);
      expect(thisMinpastEvents, isEmpty);
      expect(thisMinNotPastEvents, [
        ActivityOccasion(nowActivity, initialDay, Occasion.current),
        ActivityOccasion(endsSoonActivity, initialDay, Occasion.current),
        ActivityOccasion(startSoonActivity, initialDay, Occasion.future),
      ]);

      final nextMinpastEvents = eventsOccasionLoaded.pastEvents(nextMinute);
      final nextMinNotPastEvents =
          eventsOccasionLoaded.notPastEvents(nextMinute);
      expect(nextMinpastEvents, [
        ActivityOccasion(endsSoonActivity, initialDay, Occasion.past),
      ]);
      expect(nextMinNotPastEvents, [
        ActivityOccasion(nowActivity, initialDay, Occasion.current),
        ActivityOccasion(startSoonActivity, initialDay, Occasion.current),
      ]);
    });
  });

  group('EventsOccasionCubit recurring', () {
    test('Shows recurring past, present and future', () async {
      // Arrange
      final longAgo = initialMinutes.subtract(const Duration(days: 1111));
      final weekendActivity = FakeActivity.reocurrsWeekends(longAgo);
      final tuesdayRecurring = FakeActivity.reocurrsTuedays(longAgo);
      final mondayRecurring = FakeActivity.reocurrsMondays(longAgo);
      final activities = const Iterable<Activity>.empty()
          .followedBy([weekendActivity, tuesdayRecurring, mondayRecurring]);
      when(() => mockActivityRepository.load())
          .thenAnswer((_) => Future.value(activities));

      final friday = initialDay.add(const Duration(days: 3));
      final saturday = friday.add(const Duration(days: 1));
      final sunday = saturday.add(const Duration(days: 1));
      final monday = sunday.add(const Duration(days: 1));

      // Act
      activitiesBloc.add(LoadActivities());
      await expectLater(
        eventsOccasionCubit.stream,
        emits(
          // Tuesday
          EventsOccasionLoaded(
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
      dayPickerBloc.add(PreviousDay());
      dayPickerBloc.add(GoTo(day: friday));
      dayPickerBloc.add(NextDay());
      dayPickerBloc.add(NextDay());
      dayPickerBloc.add(NextDay());

      // Assert
      await expectLater(
          eventsOccasionCubit.stream,
          emitsInOrder([
            // monday
            EventsOccasionLoaded(
              activities: [
                ActivityDay(mondayRecurring,
                    initialDay.subtract(const Duration(days: 1))),
              ],
              timers: const [],
              fullDayActivities: const [],
              day: previusDay,
              occasion: Occasion.past,
            ),
            // Friday
            EventsOccasionLoaded(
              activities: const [],
              timers: const [],
              fullDayActivities: const [],
              day: friday,
              occasion: Occasion.future,
            ),
            // Saturday
            EventsOccasionLoaded(
              activities: [
                ActivityDay(weekendActivity, saturday),
              ],
              timers: const [],
              fullDayActivities: const [],
              day: saturday,
              occasion: Occasion.future,
            ),
            // Sunday
            EventsOccasionLoaded(
              activities: [
                ActivityDay(weekendActivity, sunday),
              ],
              timers: const [],
              fullDayActivities: const [],
              day: sunday,
              occasion: Occasion.future,
            ),
            // Monday
            EventsOccasionLoaded(
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
        'Dont show past days remove after activities, but show present and future',
        () async {
      // Arrange
      final longAgo = initialMinutes.subtract(1111.days());
      final yesterday = initialDay.subtract(1.days());
      final tomorrow = initialDay.add(1.days());
      final in1Hour = initialMinutes.add(1.hours());

      final everyDayRecurring =
          FakeActivity.reocurrsEveryDay(longAgo).copyWith(removeAfter: true);
      final todayActivity =
          FakeActivity.starts(in1Hour).copyWith(removeAfter: true);
      final yesterdayActivity = FakeActivity.starts(in1Hour.subtract(1.days()))
          .copyWith(removeAfter: true);
      final tomorrowActivity = FakeActivity.starts(in1Hour.add(1.days()))
          .copyWith(removeAfter: true);
      final everyDayFullDayRecurring = FakeActivity.fullday(longAgo).copyWith(
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
      when(() => mockActivityRepository.load())
          .thenAnswer((_) => Future.value(activities));

      // Act
      activitiesBloc.add(LoadActivities());

      // Assert
      await expectLater(
        eventsOccasionCubit.stream,
        emits(
          // Tuesday
          EventsOccasionLoaded(
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
      dayPickerBloc.add(PreviousDay());
      dayPickerBloc.add(NextDay());
      dayPickerBloc.add(NextDay());

      // Assert
      await expectLater(
          eventsOccasionCubit.stream,
          emitsInOrder([
            // Monday
            EventsOccasionLoaded(
                activities: const [],
                timers: const [],
                fullDayActivities: const [],
                day: yesterday,
                occasion: Occasion.past),
            // Tuesday
            EventsOccasionLoaded(
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
            EventsOccasionLoaded(
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
      final dayBeforeyesterday = yesterday.previousDay();
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
      when(() => mockActivityRepository.load())
          .thenAnswer((_) => Future.value(activities));

      // Act
      activitiesBloc.add(LoadActivities());

      // Assert
      await expectLater(
        eventsOccasionCubit.stream,
        emits(
          // Tuesday
          EventsOccasionLoaded(
            activities: [
              ActivityDay(everyDayRecurring, dayBeforeyesterday),
              ActivityDay(everyDayRecurring, yesterday),
              ActivityDay(everyDayRecurring, initialDay),
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
        eventsOccasionCubit.stream,
        emits(
          // Monday
          EventsOccasionLoaded(
            activities: [
              ActivityDay(everyDayRecurring, yesterday),
              ActivityDay(everyDayRecurring, initialDay),
              ActivityDay(everyDayRecurring, tomorrow),
            ],
            timers: const [],
            fullDayActivities: const [],
            day: tomorrow,
            occasion: Occasion.future,
          ),
        ),
      );
    });

    test(' overlapping into this day before starting early today', () async {
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
      when(() => mockActivityRepository.load())
          .thenAnswer((_) => Future.value(activities));

      // Act
      activitiesBloc.add(LoadActivities());
      await activitiesBloc.stream.any((s) => s is ActivitiesLoaded);

      // Assert
      await expectLater(
          eventsOccasionCubit.stream,
          emitsInOrder([
            // Tuesday
            EventsOccasionLoaded(
              activities: [
                ActivityDay(earlyActivity, initialDay),
                ActivityDay(mondayRecurring, monday),
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
  tearDown(() {
    dayPickerBloc.close();
    activitiesBloc.close();
    eventsOccasionCubit.close();
    dayEventsCubit.close();
    clockBloc.close();
    mockedTicker.close();
  });
}
