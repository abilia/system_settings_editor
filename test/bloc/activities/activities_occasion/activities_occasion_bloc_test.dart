import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

import '../../../mocks.dart';

void main() {
  DayActivitiesBloc dayActivitiesBloc;
  DayPickerBloc dayPickerBloc;
  ClockBloc clockBloc;
  ActivitiesBloc activitiesBloc;
  ActivitiesOccasionBloc activitiesOccasionBloc;
  DateTime initialTime = DateTime(2006, 06, 06, 06, 06, 06, 06).onlyMinutes();
  DateTime initialMinutes = initialTime.onlyMinutes();
  DateTime initialDay = initialTime.onlyDays();
  DateTime nextDay = initialDay.add(Duration(days: 1));
  DateTime previusDay = initialDay.subtract(Duration(days: 1));
  MockActivityRepository mockActivityRepository;
  StreamController<DateTime> mockedTicker;

  group('ActivitiesOccasionBloc', () {
    setUp(() {
      mockedTicker = StreamController<DateTime>();
      clockBloc = ClockBloc(mockedTicker.stream, initialTime: initialMinutes);
      dayPickerBloc = DayPickerBloc(clockBloc: clockBloc);
      mockActivityRepository = MockActivityRepository();
      activitiesBloc = ActivitiesBloc(
        activityRepository: mockActivityRepository,
        syncBloc: MockSyncBloc(),
        pushBloc: MockPushBloc(),
      );
      dayActivitiesBloc = DayActivitiesBloc(
          dayPickerBloc: dayPickerBloc, activitiesBloc: activitiesBloc);
      activitiesOccasionBloc = ActivitiesOccasionBloc(
          clockBloc: clockBloc,
          dayActivitiesBloc: dayActivitiesBloc,
          dayPickerBloc: dayPickerBloc);
    });

    test('initial state is ActivitiesOccasionLoading', () {
      expect(activitiesOccasionBloc.initialState, ActivitiesOccasionLoading());
      expect(activitiesOccasionBloc.state, ActivitiesOccasionLoading());
      expectLater(
        activitiesOccasionBloc,
        emitsInOrder([ActivitiesOccasionLoading()]),
      );
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
        activitiesOccasionBloc,
        emitsInOrder([
          ActivitiesOccasionLoading(),
          ActivitiesOccasionLoaded(
            activities: <ActivityOccasion>[],
            fullDayActivities: <ActivityOccasion>[],
            indexOfCurrentActivity: -1,
            day: initialDay,
            occasion: Occasion.current,
          ),
        ]),
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
        activitiesOccasionBloc,
        emitsInOrder([
          ActivitiesOccasionLoading(),
          ActivitiesOccasionLoaded(
            activities: [
              ActivityOccasion.forTest(pastActivity, Occasion.past,
                  day: initialDay),
              ActivityOccasion.forTest(nowActivity, Occasion.current,
                  day: initialDay),
              ActivityOccasion.forTest(futureActivity, Occasion.future,
                  day: initialDay),
            ],
            fullDayActivities: <ActivityOccasion>[],
            indexOfCurrentActivity: 1,
            day: initialDay,
            occasion: Occasion.current,
          ),
        ]),
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
        activitiesOccasionBloc,
        emitsInOrder([
          ActivitiesOccasionLoading(),
          ActivitiesOccasionLoaded(
            activities: <ActivityOccasion>[],
            fullDayActivities: [
              ActivityOccasion.forTest(fullDayActivity, Occasion.future,
                  day: initialDay)
            ],
            indexOfCurrentActivity: -1,
            day: initialDay,
            occasion: Occasion.current,
          ),
        ]),
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
        activitiesOccasionBloc,
        emitsInOrder([
          ActivitiesOccasionLoading(),
          ActivitiesOccasionLoaded(
            activities: <ActivityOccasion>[
              ActivityOccasion.forTest(pastActivity, Occasion.past,
                  day: initialDay),
              ActivityOccasion.forTest(nowActivity, Occasion.current,
                  day: initialDay),
              ActivityOccasion.forTest(futureActivity, Occasion.future,
                  day: initialDay),
            ],
            fullDayActivities: [
              ActivityOccasion.forTest(fullDayActivity, Occasion.future,
                  day: initialDay)
            ],
            indexOfCurrentActivity: 1,
            day: initialDay,
            occasion: Occasion.current,
          ),
        ]),
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
      await activitiesBloc.any((s) => s is ActivitiesLoaded);
      dayPickerBloc.add(NextDay());
      dayPickerBloc.add(PreviousDay());
      dayPickerBloc.add(PreviousDay());

      // Assert
      await expectLater(
        activitiesOccasionBloc,
        emitsInOrder([
          ActivitiesOccasionLoading(),
          ActivitiesOccasionLoaded(
            activities: <ActivityOccasion>[],
            fullDayActivities: [
              ActivityOccasion.forTest(fullDayActivity, Occasion.future,
                  day: initialDay)
            ],
            indexOfCurrentActivity: -1,
            day: initialDay,
            occasion: Occasion.current,
          ),
          ActivitiesOccasionLoaded(
            activities: <ActivityOccasion>[],
            fullDayActivities: [
              ActivityOccasion.forTest(tomorrowFullday, Occasion.future,
                  day: nextDay)
            ],
            indexOfCurrentActivity: -1,
            day: nextDay,
            occasion: Occasion.future,
          ),
          ActivitiesOccasionLoaded(
            activities: <ActivityOccasion>[],
            fullDayActivities: [
              ActivityOccasion.forTest(fullDayActivity, Occasion.future,
                  day: initialDay)
            ],
            indexOfCurrentActivity: -1,
            day: initialDay,
            occasion: Occasion.current,
          ),
          ActivitiesOccasionLoaded(
            activities: <ActivityOccasion>[],
            fullDayActivities: [
              ActivityOccasion.forTest(yesterdayFullday, Occasion.past,
                  day: previusDay)
            ],
            indexOfCurrentActivity: -1,
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
        activitiesOccasionBloc,
        emitsInOrder([
          ActivitiesOccasionLoading(),
          ActivitiesOccasionLoaded(
            activities: [
              ActivityOccasion.forTest(pastActivity, Occasion.future,
                  day: nextDay),
              ActivityOccasion.forTest(nowActivity, Occasion.future,
                  day: nextDay),
              ActivityOccasion.forTest(futureActivity, Occasion.future,
                  day: nextDay),
            ],
            fullDayActivities: [
              ActivityOccasion.forTest(fulldayActivity, Occasion.future,
                  day: nextDay)
            ],
            day: nextDay,
            indexOfCurrentActivity: -1,
            occasion: Occasion.future,
          ),
        ]),
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
        activitiesOccasionBloc,
        emitsInOrder([
          ActivitiesOccasionLoading(),
          ActivitiesOccasionLoaded(
            activities: [
              ActivityOccasion.forTest(pastActivity, Occasion.past,
                  day: previusDay),
              ActivityOccasion.forTest(nowActivity, Occasion.past,
                  day: previusDay),
              ActivityOccasion.forTest(futureActivity, Occasion.past,
                  day: previusDay),
            ],
            fullDayActivities: [
              ActivityOccasion.forTest(fulldayActivity, Occasion.past,
                  day: previusDay)
            ],
            indexOfCurrentActivity: -1,
            day: previusDay,
            occasion: Occasion.past,
          ),
        ]),
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
        activitiesOccasionBloc,
        emitsInOrder([
          ActivitiesOccasionLoading(),
          ActivitiesOccasionLoaded(
            activities: <ActivityOccasion>[
              ActivityOccasion.forTest(endsSoon, Occasion.current,
                  day: initialDay),
            ],
            fullDayActivities: [],
            indexOfCurrentActivity: 0,
            day: initialDay,
            occasion: Occasion.current,
          ),
        ]),
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
        activitiesOccasionBloc,
        emitsInOrder([
          ActivitiesOccasionLoading(),
          ActivitiesOccasionLoaded(
            activities: <ActivityOccasion>[
              ActivityOccasion.forTest(startsNow, Occasion.current,
                  day: initialDay),
            ],
            fullDayActivities: [],
            indexOfCurrentActivity: 0,
            day: initialDay,
            occasion: Occasion.current,
          ),
        ]),
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
      await activitiesOccasionBloc.any((s) => s is ActivitiesOccasionLoaded);
      mockedTicker.add(nextMinute);

      // Assert
      await expectLater(
        activitiesOccasionBloc,
        emitsInOrder([
          ActivitiesOccasionLoaded(
            activities: <ActivityOccasion>[
              ActivityOccasion.forTest(nowActivity, Occasion.current,
                  day: initialDay),
              ActivityOccasion.forTest(endsSoonActivity, Occasion.current,
                  day: initialDay),
              ActivityOccasion.forTest(startSoonActivity, Occasion.future,
                  day: initialDay),
            ],
            fullDayActivities: <ActivityOccasion>[],
            indexOfCurrentActivity: 0,
            day: initialDay,
            occasion: Occasion.current,
          ),
          ActivitiesOccasionLoaded(
            activities: <ActivityOccasion>[
              ActivityOccasion.forTest(endsSoonActivity, Occasion.past,
                  day: initialDay),
              ActivityOccasion.forTest(nowActivity, Occasion.current,
                  day: initialDay),
              ActivityOccasion.forTest(startSoonActivity, Occasion.current,
                  day: initialDay),
            ],
            fullDayActivities: <ActivityOccasion>[],
            indexOfCurrentActivity: 1,
            day: initialDay,
            occasion: Occasion.current,
          ),
        ]),
      );
    });

    tearDown(() {
      dayPickerBloc.close();
      activitiesBloc.close();
      activitiesOccasionBloc.close();
      dayActivitiesBloc.close();
      clockBloc.close();
      mockedTicker.close();
    });
  });

  group('ActivitiesOccasionBloc recurring', () {
    setUp(() {
      mockedTicker = StreamController<DateTime>();
      clockBloc = ClockBloc(mockedTicker.stream, initialTime: initialMinutes);
      dayPickerBloc = DayPickerBloc(clockBloc: clockBloc);
      mockActivityRepository = MockActivityRepository();
      activitiesBloc = ActivitiesBloc(
        activityRepository: mockActivityRepository,
        syncBloc: MockSyncBloc(),
        pushBloc: MockPushBloc(),
      );
      dayActivitiesBloc = DayActivitiesBloc(
          dayPickerBloc: dayPickerBloc, activitiesBloc: activitiesBloc);
      activitiesOccasionBloc = ActivitiesOccasionBloc(
          clockBloc: clockBloc,
          dayActivitiesBloc: dayActivitiesBloc,
          dayPickerBloc: dayPickerBloc);
    });

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
      await activitiesBloc.any((s) => s is ActivitiesLoaded);
      dayPickerBloc.add(PreviousDay());
      dayPickerBloc.add(GoTo(day: friday));
      dayPickerBloc.add(NextDay());
      dayPickerBloc.add(NextDay());
      dayPickerBloc.add(NextDay());

      // Assert
      await expectLater(
          activitiesOccasionBloc,
          emitsInOrder([
            ActivitiesOccasionLoading(),
            // Tuesday
            ActivitiesOccasionLoaded(
              activities: <ActivityOccasion>[
                ActivityOccasion.forTest(tuesdayRecurring, Occasion.current,
                    day: initialDay),
              ],
              fullDayActivities: [],
              indexOfCurrentActivity: 0,
              day: initialDay,
              occasion: Occasion.current,
            ),
            // monday
            ActivitiesOccasionLoaded(
              activities: <ActivityOccasion>[
                ActivityOccasion.forTest(mondayRecurring, Occasion.past,
                    day: initialDay.subtract(Duration(days: 1))),
              ],
              fullDayActivities: [],
              indexOfCurrentActivity: -1,
              day: previusDay,
              occasion: Occasion.past,
            ),
            // Friday
            ActivitiesOccasionLoaded(
              activities: <ActivityOccasion>[],
              fullDayActivities: [],
              indexOfCurrentActivity: -1,
              day: friday,
              occasion: Occasion.future,
            ),
            // Saturday
            ActivitiesOccasionLoaded(
              activities: <ActivityOccasion>[
                ActivityOccasion.forTest(weekendActivity, Occasion.future,
                    day: saturday),
              ],
              fullDayActivities: [],
              indexOfCurrentActivity: -1,
              day: saturday,
              occasion: Occasion.future,
            ),
            // Sunday
            ActivitiesOccasionLoaded(
              activities: <ActivityOccasion>[
                ActivityOccasion.forTest(weekendActivity, Occasion.future,
                    day: sunday),
              ],
              fullDayActivities: [],
              indexOfCurrentActivity: -1,
              day: sunday,
              occasion: Occasion.future,
            ),
            // Monday
            ActivitiesOccasionLoaded(
              activities: <ActivityOccasion>[
                ActivityOccasion.forTest(mondayRecurring, Occasion.future,
                    day: monday),
              ],
              fullDayActivities: [],
              indexOfCurrentActivity: -1,
              day: monday,
              occasion: Occasion.future,
            ),
          ]));
    });

    tearDown(() {
      dayPickerBloc.close();
      activitiesBloc.close();
      activitiesOccasionBloc.close();
      dayActivitiesBloc.close();
      clockBloc.close();
      mockedTicker.close();
    });
  });
  group('Remove after', () {
    setUp(() {
      mockedTicker = StreamController<DateTime>();
      clockBloc = ClockBloc(mockedTicker.stream, initialTime: initialMinutes);
      dayPickerBloc = DayPickerBloc(clockBloc: clockBloc);
      mockActivityRepository = MockActivityRepository();
      activitiesBloc = ActivitiesBloc(
        activityRepository: mockActivityRepository,
        syncBloc: MockSyncBloc(),
        pushBloc: MockPushBloc(),
      );
      dayActivitiesBloc = DayActivitiesBloc(
          dayPickerBloc: dayPickerBloc, activitiesBloc: activitiesBloc);
      activitiesOccasionBloc = ActivitiesOccasionBloc(
          clockBloc: clockBloc,
          dayActivitiesBloc: dayActivitiesBloc,
          dayPickerBloc: dayPickerBloc);
    });

    test(
        'Dont show past days remove after activities, but show present and future',
        () async {
      // Arrange
      final longAgo = initialMinutes.subtract(1111.days());
      final yesterday = initialDay.subtract(1.days());
      final tomorrow = initialDay.add(1.days());
      final in1Hour = initialTime.add(1.hours());

      final everyDayRecurring =
          FakeActivity.reocurrsEveryDay(longAgo).copyWith(removeAfter: true);
      final todayActivity =
          FakeActivity.starts(in1Hour).copyWith(removeAfter: true);
      final yesterdayActivity = FakeActivity.starts(in1Hour.subtract(1.days()))
          .copyWith(removeAfter: true);
      final tomorrowActivity = FakeActivity.starts(in1Hour.add(1.days()))
          .copyWith(removeAfter: true);
      final everyDayFullDayRecurring = FakeActivity.fullday(longAgo).copyWith(
        endTime: DateTime.fromMillisecondsSinceEpoch(253402297199000),
        removeAfter: true,
        recurrentType: RecurrentType.weekly.index,
        recurrentData: allWeekdays,
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
      await activitiesBloc.any((s) => s is ActivitiesLoaded);
      dayPickerBloc.add(PreviousDay());
      dayPickerBloc.add(NextDay());
      dayPickerBloc.add(NextDay());

      // Assert
      await expectLater(
          activitiesOccasionBloc,
          emitsInOrder([
            ActivitiesOccasionLoading(),
            // Tuesday
            ActivitiesOccasionLoaded(
              activities: <ActivityOccasion>[
                ActivityOccasion.forTest(everyDayRecurring, Occasion.current,
                    day: initialDay),
                ActivityOccasion.forTest(todayActivity, Occasion.future,
                    day: initialDay),
              ],
              fullDayActivities: [
                ActivityOccasion.forTest(
                    everyDayFullDayRecurring, Occasion.future,
                    day: initialDay),
              ],
              indexOfCurrentActivity: 0,
              day: initialDay,
              occasion: Occasion.current,
            ),
            // Monday
            ActivitiesOccasionLoaded(
              activities: <ActivityOccasion>[],
              fullDayActivities: [],
              indexOfCurrentActivity: -1,
              day: yesterday,
              occasion: Occasion.past,
            ),
            // Tuesday
            ActivitiesOccasionLoaded(
              activities: <ActivityOccasion>[
                ActivityOccasion.forTest(everyDayRecurring, Occasion.current,
                    day: initialDay),
                ActivityOccasion.forTest(todayActivity, Occasion.future,
                    day: initialDay),
              ],
              fullDayActivities: [
                ActivityOccasion.forTest(
                    everyDayFullDayRecurring, Occasion.future,
                    day: initialDay),
              ],
              indexOfCurrentActivity: 0,
              day: initialDay,
              occasion: Occasion.current,
            ),
            // Wednesday
            ActivitiesOccasionLoaded(
              activities: <ActivityOccasion>[
                ActivityOccasion.forTest(everyDayRecurring, Occasion.future,
                    day: tomorrow),
                ActivityOccasion.forTest(tomorrowActivity, Occasion.future,
                    day: tomorrow),
              ],
              fullDayActivities: [
                ActivityOccasion.forTest(
                    everyDayFullDayRecurring, Occasion.future,
                    day: tomorrow),
              ],
              indexOfCurrentActivity: -1,
              day: tomorrow,
              occasion: Occasion.future,
            ),
          ]));
    });

    tearDown(() {
      dayPickerBloc.close();
      activitiesBloc.close();
      activitiesOccasionBloc.close();
      dayActivitiesBloc.close();
      clockBloc.close();
      mockedTicker.close();
    });
  });
}
