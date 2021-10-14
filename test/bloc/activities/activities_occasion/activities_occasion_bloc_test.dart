import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

import '../../../fakes/fakes_blocs.dart';
import '../../../mocks/shared.mocks.dart';

void main() {
  late DayActivitiesBloc dayActivitiesBloc;
  late DayPickerBloc dayPickerBloc;
  late ClockBloc clockBloc;
  late ActivitiesBloc activitiesBloc;
  late ActivitiesOccasionBloc activitiesOccasionBloc;
  late MockActivityRepository mockActivityRepository;
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
    activitiesBloc = ActivitiesBloc(
      activityRepository: mockActivityRepository,
      syncBloc: FakeSyncBloc(),
      pushBloc: FakePushBloc(),
    );
    dayActivitiesBloc = DayActivitiesBloc(
        dayPickerBloc: dayPickerBloc, activitiesBloc: activitiesBloc);
    activitiesOccasionBloc = ActivitiesOccasionBloc(
      clockBloc: clockBloc,
      dayActivitiesBloc: dayActivitiesBloc,
    );
  });
  group('ActivitiesOccasionBloc', () {
    test('initial state is ActivitiesOccasionLoading', () {
      expect(activitiesOccasionBloc.state, ActivitiesOccasionLoading());
    });

    test(
        'state is ActivitiesOccasionLoaded when ActivitiesBloc loadeds activities',
        () {
      // Arrange
      when(mockActivityRepository.load())
          .thenAnswer((_) => Future.value(Iterable.empty()));
      // Act
      activitiesBloc.add(LoadActivities());
      // Assert
      expectLater(
        activitiesOccasionBloc.stream,
        emits(
          ActivitiesOccasionLoaded(
            activities: const <ActivityOccasion>[],
            fullDayActivities: const <ActivityOccasion>[],
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
      when(mockActivityRepository.load()).thenAnswer(
          (_) => Future.value([nowActivity, pastActivity, futureActivity]));

      // Act
      activitiesBloc.add(LoadActivities());
      activitiesBloc.add(LoadActivities());

      // Assert
      expectLater(
        activitiesOccasionBloc.stream,
        emits(
          ActivitiesOccasionLoaded(
            activities: [
              ActivityOccasion.forTest(pastActivity,
                  occasion: Occasion.past, day: initialDay),
              ActivityOccasion.forTest(nowActivity,
                  occasion: Occasion.current, day: initialDay),
              ActivityOccasion.forTest(futureActivity,
                  occasion: Occasion.future, day: initialDay),
            ],
            fullDayActivities: const <ActivityOccasion>[],
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
      when(mockActivityRepository.load()).thenAnswer((_) => Future.value([
            yesterdayFullday,
            tomorrowFullday,
            fullDayActivity,
          ]));

      // Act
      activitiesBloc.add(LoadActivities());

      // Assert
      expectLater(
        activitiesOccasionBloc.stream,
        emits(
          ActivitiesOccasionLoaded(
            activities: const <ActivityOccasion>[],
            fullDayActivities: [
              ActivityOccasion.forTest(fullDayActivity,
                  occasion: Occasion.future, day: initialDay)
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
      when(mockActivityRepository.load()).thenAnswer((_) => Future.value([
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
        activitiesOccasionBloc.stream,
        emits(
          ActivitiesOccasionLoaded(
            activities: <ActivityOccasion>[
              ActivityOccasion.forTest(pastActivity,
                  occasion: Occasion.past, day: initialDay),
              ActivityOccasion.forTest(nowActivity,
                  occasion: Occasion.current, day: initialDay),
              ActivityOccasion.forTest(futureActivity,
                  occasion: Occasion.future, day: initialDay),
            ],
            fullDayActivities: [
              ActivityOccasion.forTest(fullDayActivity,
                  occasion: Occasion.future, day: initialDay)
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
      when(mockActivityRepository.load()).thenAnswer((_) => Future.value([
            yesterdayFullday,
            tomorrowFullday,
            fullDayActivity,
          ]));

      // Act
      activitiesBloc.add(LoadActivities());
      await activitiesBloc.stream.any((s) => s is ActivitiesLoaded);
      dayPickerBloc.add(NextDay());
      dayPickerBloc.add(PreviousDay());
      dayPickerBloc.add(PreviousDay());

      // Assert
      await expectLater(
        activitiesOccasionBloc.stream,
        emitsInOrder([
          ActivitiesOccasionLoaded(
            activities: const <ActivityOccasion>[],
            fullDayActivities: [
              ActivityOccasion.forTest(fullDayActivity,
                  occasion: Occasion.future, day: initialDay)
            ],
            day: initialDay,
            occasion: Occasion.current,
          ),
          ActivitiesOccasionLoaded(
            activities: const <ActivityOccasion>[],
            fullDayActivities: [
              ActivityOccasion.forTest(tomorrowFullday,
                  occasion: Occasion.future, day: nextDay)
            ],
            day: nextDay,
            occasion: Occasion.future,
          ),
          ActivitiesOccasionLoaded(
            activities: const <ActivityOccasion>[],
            fullDayActivities: [
              ActivityOccasion.forTest(fullDayActivity,
                  occasion: Occasion.future, day: initialDay)
            ],
            day: initialDay,
            occasion: Occasion.current,
          ),
          ActivitiesOccasionLoaded(
            activities: const <ActivityOccasion>[],
            fullDayActivities: [
              ActivityOccasion.forTest(yesterdayFullday,
                  occasion: Occasion.past, day: previusDay)
            ],
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
      final tomorrow = initialMinutes.add(Duration(days: 1));
      final nowActivity = FakeActivity.starts(tomorrow);
      final pastActivity = FakeActivity.ends(tomorrow.add(1.minutes()));
      final futureActivity = FakeActivity.starts(tomorrow.add(1.minutes()));
      final fulldayActivity = FakeActivity.fullday(tomorrow);
      when(mockActivityRepository.load()).thenAnswer((_) => Future.value(
          [nowActivity, pastActivity, futureActivity, fulldayActivity]));
      //Act
      activitiesBloc.add(LoadActivities());
      dayPickerBloc.add(NextDay());
      //Assert
      expectLater(
        activitiesOccasionBloc.stream,
        emits(
          ActivitiesOccasionLoaded(
            activities: [
              ActivityOccasion.forTest(pastActivity,
                  occasion: Occasion.future, day: nextDay),
              ActivityOccasion.forTest(nowActivity,
                  occasion: Occasion.future, day: nextDay),
              ActivityOccasion.forTest(futureActivity,
                  occasion: Occasion.future, day: nextDay),
            ],
            fullDayActivities: [
              ActivityOccasion.forTest(fulldayActivity,
                  occasion: Occasion.future, day: nextDay)
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
      final yesterday = initialMinutes.subtract(Duration(days: 1));
      final nowActivity = FakeActivity.starts(yesterday);
      final pastActivity = FakeActivity.ends(yesterday.add(1.minutes()));
      final futureActivity = FakeActivity.starts(yesterday.add(1.minutes()));
      final fulldayActivity = FakeActivity.fullday(yesterday);
      when(mockActivityRepository.load()).thenAnswer((_) => Future.value(
          [nowActivity, pastActivity, futureActivity, fulldayActivity]));
      //Act
      activitiesBloc.add(LoadActivities());
      dayPickerBloc.add(PreviousDay());
      //Assert
      expectLater(
        activitiesOccasionBloc.stream,
        emits(
          ActivitiesOccasionLoaded(
            activities: [
              ActivityOccasion.forTest(pastActivity,
                  occasion: Occasion.past, day: previusDay),
              ActivityOccasion.forTest(nowActivity,
                  occasion: Occasion.past, day: previusDay),
              ActivityOccasion.forTest(futureActivity,
                  occasion: Occasion.past, day: previusDay),
            ],
            fullDayActivities: [
              ActivityOccasion.forTest(fulldayActivity,
                  occasion: Occasion.past, day: previusDay)
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
      when(mockActivityRepository.load())
          .thenAnswer((_) => Future.value([endsSoon]));

      // Act
      activitiesBloc.add(LoadActivities());

      expectLater(
        activitiesOccasionBloc.stream,
        emits(
          ActivitiesOccasionLoaded(
            activities: <ActivityOccasion>[
              ActivityOccasion.forTest(endsSoon,
                  occasion: Occasion.current, day: initialDay),
            ],
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
      when(mockActivityRepository.load())
          .thenAnswer((_) => Future.value([startsNow]));

      // Act
      activitiesBloc.add(LoadActivities());

      // Assert
      expectLater(
        activitiesOccasionBloc.stream,
        emits(
          ActivitiesOccasionLoaded(
            activities: <ActivityOccasion>[
              ActivityOccasion.forTest(startsNow,
                  occasion: Occasion.current, day: initialDay),
            ],
            fullDayActivities: const [],
            day: initialDay,
            occasion: Occasion.current,
          ),
        ),
      );
    });

    test('Changing now changing order', () async {
      // Arrange
      final nextMinute = initialMinutes.add(Duration(minutes: 1));
      final nowActivity =
          FakeActivity.starts(initialMinutes.onlyDays(), duration: 16.hours());
      final endsSoonActivity = FakeActivity.ends(initialMinutes);
      final startSoonActivity =
          FakeActivity.starts(initialMinutes.add(1.minutes()));
      when(mockActivityRepository.load()).thenAnswer((_) =>
          Future.value([nowActivity, startSoonActivity, endsSoonActivity]));

      // Act
      activitiesBloc.add(LoadActivities());

      // Assert
      await expectLater(
        activitiesOccasionBloc.stream,
        emits(
          ActivitiesOccasionLoaded(
            activities: <ActivityOccasion>[
              ActivityOccasion.forTest(nowActivity,
                  occasion: Occasion.current, day: initialDay),
              ActivityOccasion.forTest(endsSoonActivity,
                  occasion: Occasion.current, day: initialDay),
              ActivityOccasion.forTest(startSoonActivity,
                  occasion: Occasion.future, day: initialDay),
            ],
            fullDayActivities: const <ActivityOccasion>[],
            day: initialDay,
            occasion: Occasion.current,
          ),
        ),
      );

      // Act
      mockedTicker.add(nextMinute);

      // Assert
      await expectLater(
        activitiesOccasionBloc.stream,
        emits(
          ActivitiesOccasionLoaded(
            activities: <ActivityOccasion>[
              ActivityOccasion.forTest(endsSoonActivity,
                  occasion: Occasion.past, day: initialDay),
              ActivityOccasion.forTest(nowActivity,
                  occasion: Occasion.current, day: initialDay),
              ActivityOccasion.forTest(startSoonActivity,
                  occasion: Occasion.current, day: initialDay),
            ],
            fullDayActivities: const <ActivityOccasion>[],
            day: initialDay,
            occasion: Occasion.current,
          ),
        ),
      );
    });
  });

  group('ActivitiesOccasionBloc recurring', () {
    test('Shows recurring past, present and future', () async {
      // Arrange
      final longAgo = initialMinutes.subtract(Duration(days: 1111));
      final weekendActivity = FakeActivity.reocurrsWeekends(longAgo);
      final tuesdayRecurring = FakeActivity.reocurrsTuedays(longAgo);
      final mondayRecurring = FakeActivity.reocurrsMondays(longAgo);
      final activities = Iterable<Activity>.empty()
          .followedBy([weekendActivity, tuesdayRecurring, mondayRecurring]);
      when(mockActivityRepository.load())
          .thenAnswer((_) => Future.value(activities));

      final friday = initialDay.add(Duration(days: 3));
      final saturday = friday.add(Duration(days: 1));
      final sunday = saturday.add(Duration(days: 1));
      final monday = sunday.add(Duration(days: 1));

      // Act
      activitiesBloc.add(LoadActivities());
      await activitiesBloc.stream.any((s) => s is ActivitiesLoaded);
      dayPickerBloc.add(PreviousDay());
      dayPickerBloc.add(GoTo(day: friday));
      dayPickerBloc.add(NextDay());
      dayPickerBloc.add(NextDay());
      dayPickerBloc.add(NextDay());

      // Assert
      await expectLater(
          activitiesOccasionBloc.stream,
          emitsInOrder([
            // Tuesday
            ActivitiesOccasionLoaded(
              activities: <ActivityOccasion>[
                ActivityOccasion.forTest(tuesdayRecurring,
                    occasion: Occasion.current, day: initialDay),
              ],
              fullDayActivities: const [],
              day: initialDay,
              occasion: Occasion.current,
            ),
            // monday
            ActivitiesOccasionLoaded(
              activities: <ActivityOccasion>[
                ActivityOccasion.forTest(mondayRecurring,
                    occasion: Occasion.past,
                    day: initialDay.subtract(Duration(days: 1))),
              ],
              fullDayActivities: const [],
              day: previusDay,
              occasion: Occasion.past,
            ),
            // Friday
            ActivitiesOccasionLoaded(
              activities: const <ActivityOccasion>[],
              fullDayActivities: const [],
              day: friday,
              occasion: Occasion.future,
            ),
            // Saturday
            ActivitiesOccasionLoaded(
              activities: <ActivityOccasion>[
                ActivityOccasion.forTest(weekendActivity,
                    occasion: Occasion.future, day: saturday),
              ],
              fullDayActivities: const [],
              day: saturday,
              occasion: Occasion.future,
            ),
            // Sunday
            ActivitiesOccasionLoaded(
              activities: <ActivityOccasion>[
                ActivityOccasion.forTest(weekendActivity,
                    occasion: Occasion.future, day: sunday),
              ],
              fullDayActivities: const [],
              day: sunday,
              occasion: Occasion.future,
            ),
            // Monday
            ActivitiesOccasionLoaded(
              activities: <ActivityOccasion>[
                ActivityOccasion.forTest(mondayRecurring,
                    occasion: Occasion.future, day: monday),
              ],
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

      final activities = Iterable<Activity>.empty().followedBy([
        everyDayRecurring,
        todayActivity,
        yesterdayActivity,
        tomorrowActivity,
        everyDayFullDayRecurring
      ]);
      when(mockActivityRepository.load())
          .thenAnswer((_) => Future.value(activities));

      // Act
      activitiesBloc.add(LoadActivities());
      await activitiesBloc.stream.any((s) => s is ActivitiesLoaded);
      dayPickerBloc.add(PreviousDay());
      dayPickerBloc.add(NextDay());
      dayPickerBloc.add(NextDay());

      // Assert
      await expectLater(
          activitiesOccasionBloc.stream,
          emitsInOrder([
            // Tuesday
            ActivitiesOccasionLoaded(
              activities: <ActivityOccasion>[
                ActivityOccasion.forTest(everyDayRecurring,
                    occasion: Occasion.current, day: initialDay),
                ActivityOccasion.forTest(todayActivity,
                    occasion: Occasion.future, day: initialDay),
              ],
              fullDayActivities: [
                ActivityOccasion.forTest(everyDayFullDayRecurring,
                    occasion: Occasion.future, day: initialDay),
              ],
              day: initialDay,
              occasion: Occasion.current,
            ),
            // Monday
            ActivitiesOccasionLoaded(
              activities: const <ActivityOccasion>[],
              fullDayActivities: const [],
              day: yesterday,
              occasion: Occasion.past,
            ),
            // Tuesday
            ActivitiesOccasionLoaded(
              activities: <ActivityOccasion>[
                ActivityOccasion.forTest(everyDayRecurring,
                    occasion: Occasion.current, day: initialDay),
                ActivityOccasion.forTest(todayActivity,
                    occasion: Occasion.future, day: initialDay),
              ],
              fullDayActivities: [
                ActivityOccasion.forTest(everyDayFullDayRecurring,
                    occasion: Occasion.future, day: initialDay),
              ],
              day: initialDay,
              occasion: Occasion.current,
            ),
            // Wednesday
            ActivitiesOccasionLoaded(
              activities: <ActivityOccasion>[
                ActivityOccasion.forTest(everyDayRecurring,
                    occasion: Occasion.future, day: tomorrow),
                ActivityOccasion.forTest(tomorrowActivity,
                    occasion: Occasion.future, day: tomorrow),
              ],
              fullDayActivities: [
                ActivityOccasion.forTest(everyDayFullDayRecurring,
                    occasion: Occasion.future, day: tomorrow),
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

      final activities = Iterable<Activity>.empty().followedBy([
        everyDayRecurring,
      ]);
      when(mockActivityRepository.load())
          .thenAnswer((_) => Future.value(activities));

      // Act
      activitiesBloc.add(LoadActivities());
      await activitiesBloc.stream.any((s) => s is ActivitiesLoaded);
      dayPickerBloc.add(NextDay());

      // Assert
      await expectLater(
          activitiesOccasionBloc.stream,
          emitsInOrder([
            // Tuesday
            ActivitiesOccasionLoaded(
              activities: <ActivityOccasion>[
                ActivityOccasion.forTest(everyDayRecurring,
                    occasion: Occasion.current, day: dayBeforeyesterday),
                ActivityOccasion.forTest(everyDayRecurring,
                    occasion: Occasion.current, day: yesterday),
                ActivityOccasion.forTest(everyDayRecurring,
                    occasion: Occasion.current, day: initialDay),
              ],
              fullDayActivities: const [],
              day: initialDay,
              occasion: Occasion.current,
            ),
            // Monday
            ActivitiesOccasionLoaded(
              activities: [
                ActivityOccasion.forTest(everyDayRecurring,
                    occasion: Occasion.current, day: yesterday),
                ActivityOccasion.forTest(everyDayRecurring,
                    occasion: Occasion.current, day: initialDay),
                ActivityOccasion.forTest(everyDayRecurring,
                    occasion: Occasion.future, day: tomorrow),
              ],
              fullDayActivities: const [],
              day: tomorrow,
              occasion: Occasion.future,
            ),
          ]));
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

      final activities = Iterable<Activity>.empty().followedBy([
        mondayRecurring,
        earlyActivity,
        earlyCurrent,
      ]);
      when(mockActivityRepository.load())
          .thenAnswer((_) => Future.value(activities));

      // Act
      activitiesBloc.add(LoadActivities());
      await activitiesBloc.stream.any((s) => s is ActivitiesLoaded);

      // Assert
      await expectLater(
          activitiesOccasionBloc.stream,
          emitsInOrder([
            // Tuesday
            ActivitiesOccasionLoaded(
              activities: [
                ActivityOccasion.forTest(earlyActivity,
                    occasion: Occasion.past, day: initialDay),
                ActivityOccasion.forTest(mondayRecurring,
                    occasion: Occasion.current, day: monday),
                ActivityOccasion.forTest(earlyCurrent,
                    occasion: Occasion.current, day: initialDay),
              ],
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
    activitiesOccasionBloc.close();
    dayActivitiesBloc.close();
    clockBloc.close();
    mockedTicker.close();
  });
}
