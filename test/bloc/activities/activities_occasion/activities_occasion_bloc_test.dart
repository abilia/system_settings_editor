import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc.dart';
import 'package:seagull/fakes/fake_activities.dart';
import 'package:seagull/models.dart';
import 'package:seagull/utils.dart';

import '../../../mocks.dart';

void main() {
  DayActivitiesBloc dayActivitiesBloc;
  DayPickerBloc dayPickerBloc;
  ClockBloc clockBloc;
  ActivitiesBloc activitiesBloc;
  ActivitiesOccasionBloc activitiesOccasionBloc;
  DateTime initialTime = onlyMinutes(DateTime(2006, 06, 06, 06, 06, 06, 06));
  DateTime initialMinutes = onlyMinutes(initialTime);
  DateTime initialDay = onlyDays(initialTime);
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
          activitiesRepository: mockActivityRepository,
          pushBloc: MockPushBloc());
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
      when(mockActivityRepository.loadActivities())
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
          ),
        ]),
      );
    });

    test('only loads todays activities with correct occasion in correct order',
        () {
      // Arrange
      final nowActivity = FakeActivity.onTime(initialMinutes);
      final pastActivity = FakeActivity.past(initialMinutes);
      final futureActivity = FakeActivity.future(initialMinutes);
      when(mockActivityRepository.loadActivities()).thenAnswer(
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
              ActivityOccasion.forTest(pastActivity, Occasion.past),
              ActivityOccasion.forTest(nowActivity, Occasion.current),
              ActivityOccasion.forTest(futureActivity, Occasion.future),
            ],
            fullDayActivities: <ActivityOccasion>[],
            indexOfCurrentActivity: 1,
            day: initialDay,
          ),
        ]),
      );
    });

    test('fullday activities', () {
      // Arrange
      final fullDayActivity = FakeActivity.fullday(initialMinutes);
      final tomorrowFullday = FakeActivity.tomorrowFullday(initialMinutes);
      final yesterdayFullday = FakeActivity.yesterdayFullday(initialMinutes);
      when(mockActivityRepository.loadActivities())
          .thenAnswer((_) => Future.value([
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
              ActivityOccasion.forTest(fullDayActivity, Occasion.future)
            ],
            day: initialDay,
            indexOfCurrentActivity: -1,
          ),
        ]),
      );
    });

    test(
        'only loads todays activities with correct occasion in correct order and fullday activities',
        () {
      // Arrange
      final nowActivity = FakeActivity.onTime(initialMinutes);
      final pastActivity = FakeActivity.past(initialMinutes);
      final futureActivity = FakeActivity.future(initialMinutes);
      final fullDayActivity = FakeActivity.fullday(initialMinutes);
      final tomorrowActivity = FakeActivity.dayAfter(initialMinutes);
      when(mockActivityRepository.loadActivities()).thenAnswer((_) =>
          Future.value([
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
              ActivityOccasion.forTest(pastActivity, Occasion.past),
              ActivityOccasion.forTest(nowActivity, Occasion.current),
              ActivityOccasion.forTest(futureActivity, Occasion.future),
            ],
            fullDayActivities: [
              ActivityOccasion.forTest(fullDayActivity, Occasion.future)
            ],
            indexOfCurrentActivity: 1,
            day: initialDay,
          ),
        ]),
      );
    });

    test('fullday activities, today, tomorrow, yesterday', () async {
      // Arrange
      final fullDayActivity = FakeActivity.fullday(initialMinutes);
      final tomorrowFullday = FakeActivity.tomorrowFullday(initialMinutes);
      final yesterdayFullday = FakeActivity.yesterdayFullday(initialMinutes);
      when(mockActivityRepository.loadActivities())
          .thenAnswer((_) => Future.value([
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
              ActivityOccasion.forTest(fullDayActivity, Occasion.future)
            ],
            indexOfCurrentActivity: -1,
            day: initialDay,
          ),
          ActivitiesOccasionLoaded(
            activities: <ActivityOccasion>[],
            fullDayActivities: [
              ActivityOccasion.forTest(tomorrowFullday, Occasion.future)
            ],
            indexOfCurrentActivity: -1,
            day: nextDay,
          ),
          ActivitiesOccasionLoaded(
            activities: <ActivityOccasion>[],
            fullDayActivities: [
              ActivityOccasion.forTest(fullDayActivity, Occasion.future)
            ],
            indexOfCurrentActivity: -1,
            day: initialDay,
          ),
          ActivitiesOccasionLoaded(
            activities: <ActivityOccasion>[],
            fullDayActivities: [
              ActivityOccasion.forTest(yesterdayFullday, Occasion.past)
            ],
            indexOfCurrentActivity: -1,
            day: previusDay,
          ),
        ]),
      );
    });

    test(
        'only loads tomorrows activities with correct occasion in correct order and tomorrows full day',
        () {
      //Arrange
      final tomorrow = initialMinutes.add(Duration(days: 1));
      final nowActivity = FakeActivity.startsAt(tomorrow);
      final pastActivity = FakeActivity.past(tomorrow);
      final futureActivity = FakeActivity.future(tomorrow);
      final fulldayActivity = FakeActivity.fulldayWhen(tomorrow);
      when(mockActivityRepository.loadActivities()).thenAnswer((_) =>
          Future.value(
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
              ActivityOccasion.forTest(pastActivity, Occasion.future),
              ActivityOccasion.forTest(nowActivity, Occasion.future),
              ActivityOccasion.forTest(futureActivity, Occasion.future),
            ],
            fullDayActivities: [
              ActivityOccasion.forTest(fulldayActivity, Occasion.future)
            ],
            day: nextDay,
            indexOfCurrentActivity: 1,
          ),
        ]),
      );
    });

    test(
        'only loads yesterday activities with correct occasion in correct order and yesterday full day',
        () {
      //Arrange
      final yesterday = initialMinutes.subtract(Duration(days: 1));
      final nowActivity = FakeActivity.startsAt(yesterday);
      final pastActivity = FakeActivity.past(yesterday);
      final futureActivity = FakeActivity.future(yesterday);
      final fulldayActivity = FakeActivity.fulldayWhen(yesterday);
      when(mockActivityRepository.loadActivities()).thenAnswer((_) =>
          Future.value(
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
              ActivityOccasion.forTest(pastActivity, Occasion.past),
              ActivityOccasion.forTest(nowActivity, Occasion.past),
              ActivityOccasion.forTest(futureActivity, Occasion.past),
            ],
            fullDayActivities: [
              ActivityOccasion.forTest(fulldayActivity, Occasion.past)
            ],
            indexOfCurrentActivity: 2,
            day: previusDay,
          ),
        ]),
      );
    });

    test('Activity ends this minute is current', () {
      // Arrange
      final endsSoon = FakeActivity.endsAt(initialMinutes);
      when(mockActivityRepository.loadActivities())
          .thenAnswer((_) => Future.value([endsSoon]));

      // Act
      activitiesBloc.add(LoadActivities());

      expectLater(
        activitiesOccasionBloc,
        emitsInOrder([
          ActivitiesOccasionLoading(),
          ActivitiesOccasionLoaded(
            activities: <ActivityOccasion>[
              ActivityOccasion.forTest(endsSoon, Occasion.current),
            ],
            fullDayActivities: [],
            indexOfCurrentActivity: 0,
            day: initialDay,
          ),
        ]),
      );
    });

    test('Activity start this minute is current', () {
      // Arrange
      final startsNow = FakeActivity.startsAt(initialMinutes);
      when(mockActivityRepository.loadActivities())
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
              ActivityOccasion.forTest(startsNow, Occasion.current),
            ],
            fullDayActivities: [],
            indexOfCurrentActivity: 0,
            day: initialDay,
          ),
        ]),
      );
    });

    test('Changing now changing order', () async {
      // Arrange
      final nextMinute = initialMinutes.add(Duration(minutes: 1));
      final nowActivity = FakeActivity.longSpanning(initialMinutes);
      final endsSoonActivity = FakeActivity.endsAt(initialMinutes);
      final startSoonActivity =
          FakeActivity.startsOneMinuteAfter(initialMinutes);
      when(mockActivityRepository.loadActivities()).thenAnswer((_) =>
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
              ActivityOccasion.forTest(nowActivity, Occasion.current),
              ActivityOccasion.forTest(endsSoonActivity, Occasion.current),
              ActivityOccasion.forTest(startSoonActivity, Occasion.future),
            ],
            fullDayActivities: <ActivityOccasion>[],
            indexOfCurrentActivity: 0,
            day: initialDay,
          ),
          ActivitiesOccasionLoaded(
            activities: <ActivityOccasion>[
              ActivityOccasion.forTest(endsSoonActivity, Occasion.past),
              ActivityOccasion.forTest(nowActivity, Occasion.current),
              ActivityOccasion.forTest(startSoonActivity, Occasion.current),
            ],
            fullDayActivities: <ActivityOccasion>[],
            indexOfCurrentActivity: 1,
            day: initialDay,
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
          activitiesRepository: mockActivityRepository,
          pushBloc: MockPushBloc());
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
      when(mockActivityRepository.loadActivities())
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
                ActivityOccasion.forTest(tuesdayRecurring, Occasion.current),
              ],
              fullDayActivities: [],
              indexOfCurrentActivity: 0,
              day: initialDay,
            ),
            // monday
            ActivitiesOccasionLoaded(
              activities: <ActivityOccasion>[
                ActivityOccasion.forTest(mondayRecurring, Occasion.past),
              ],
              fullDayActivities: [],
              indexOfCurrentActivity: 0,
              day: previusDay,
            ),
            // Friday
            ActivitiesOccasionLoaded(
                activities: <ActivityOccasion>[],
                fullDayActivities: [],
                indexOfCurrentActivity: -1,
                day: friday),
            // Saturday
            ActivitiesOccasionLoaded(
              activities: <ActivityOccasion>[
                ActivityOccasion.forTest(weekendActivity, Occasion.future),
              ],
              fullDayActivities: [],
              indexOfCurrentActivity: 0,
              day: saturday,
            ),
            // Sunday
            ActivitiesOccasionLoaded(
              activities: <ActivityOccasion>[
                ActivityOccasion.forTest(weekendActivity, Occasion.future),
              ],
              fullDayActivities: [],
              indexOfCurrentActivity: 0,
              day: sunday,
            ),
            // Monday
            ActivitiesOccasionLoaded(
              activities: <ActivityOccasion>[
                ActivityOccasion.forTest(mondayRecurring, Occasion.future),
              ],
              fullDayActivities: [],
              indexOfCurrentActivity: 0,
              day: monday,
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
