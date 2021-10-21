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
  late ActivitiesBloc activitiesBloc;
  late MockActivityRepository mockActivityRepository;

  final today = DateTime(2020, 01, 01);
  final yesterday = today.previousDay();
  final tomorrow = today.nextDay();
  group('DayActivitiesBloc', () {
    setUp(() {
      final stream = Stream<DateTime>.value(today);
      dayPickerBloc = DayPickerBloc(
        clockBloc: ClockBloc(stream, initialTime: today),
      );
      mockActivityRepository = MockActivityRepository();
      activitiesBloc = ActivitiesBloc(
        activityRepository: mockActivityRepository,
        syncBloc: FakeSyncBloc(),
        pushBloc: FakePushBloc(),
      );
      dayActivitiesBloc = DayActivitiesBloc(
          dayPickerBloc: dayPickerBloc, activitiesBloc: activitiesBloc);
    });

    test('initial state is DayActivitiesUninitialized', () {
      expect(dayActivitiesBloc.state, DayActivitiesUninitialized());
    });

    test('initial state is DayActivitiesLoaded if started with loaded activity',
        () async {
      // Arrange
      when(mockActivityRepository.load()).thenAnswer((_) => Future.value([]));

      // Act
      activitiesBloc.add(LoadActivities());
      await dayActivitiesBloc.stream.any((s) => s is DayActivitiesLoaded);

      // Assert
      expect(dayActivitiesBloc.state,
          DayActivitiesLoaded(const <ActivityDay>[], today, Occasion.current));
    });

    test('state is DayActivitiesLoaded when ActivitiesBloc loadeds activities',
        () {
      // Arrange
      final activities = Iterable<Activity>.empty();
      when(mockActivityRepository.load())
          .thenAnswer((_) => Future.value(activities));
      // Act
      activitiesBloc.add(LoadActivities());
      // Assert
      expectLater(
        dayActivitiesBloc.stream,
        emits(DayActivitiesLoaded(
            const <ActivityDay>[], today, Occasion.current)),
      );
    });

    test('DayActivitiesLoaded only loads todays activities', () {
      // Arrange
      final activitiesNow = [FakeActivity.starts(today)];
      final expected = activitiesNow.map((a) => ActivityDay(a, today)).toList();
      final activitiesTomorrow = [FakeActivity.starts(today.add(1.days()))];

      when(mockActivityRepository.load()).thenAnswer(
          (_) => Future.value(activitiesNow.followedBy(activitiesTomorrow)));

      // Act
      activitiesBloc.add(LoadActivities());

      // Assert
      expectLater(
        dayActivitiesBloc.stream,
        emits(DayActivitiesLoaded(expected, today, Occasion.current)),
      );
    });

    test('next day loads next days activities', () async {
      // Arrange
      final activitiesNow = [FakeActivity.starts(today)];
      final expextedToday =
          activitiesNow.map((a) => ActivityDay(a, today)).toList();
      final activitiesTomorrow = [FakeActivity.starts(tomorrow)];
      final expextedTomorrow = activitiesTomorrow
          .map((a) => ActivityDay(a, today.nextDay()))
          .toList();
      when(mockActivityRepository.load()).thenAnswer(
          (_) => Future.value(activitiesNow.followedBy(activitiesTomorrow)));

      // Act
      activitiesBloc.add(LoadActivities());
      await activitiesBloc.stream.any((s) => s is ActivitiesLoaded);
      dayPickerBloc.add(NextDay());

      // Assert
      await expectLater(
        dayActivitiesBloc.stream,
        emitsInOrder([
          DayActivitiesLoaded(expextedToday, today, Occasion.current),
          DayActivitiesLoaded(expextedTomorrow, tomorrow, Occasion.future),
        ]),
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
      when(mockActivityRepository.load()).thenAnswer(
          (_) => Future.value(activitiesNow.followedBy(activitiesYesterDay)));

      // Act
      activitiesBloc.add(LoadActivities());
      await activitiesBloc.stream.any((s) => s is ActivitiesLoaded);
      dayPickerBloc.add(PreviousDay());

      // Assert
      await expectLater(
        dayActivitiesBloc.stream,
        emitsInOrder([
          DayActivitiesLoaded(expectedNow, today, Occasion.current),
          DayActivitiesLoaded(expectedYesterday, yesterday, Occasion.past),
        ]),
      );
    });

    test('does not show next years activities', () async {
      // Arrange
      final nextYear = today.add(Duration(days: 365));

      when(mockActivityRepository.load()).thenAnswer(
          (_) => Future.value(Iterable<Activity>.empty().followedBy([
                FakeActivity.starts(nextYear),
                FakeActivity.starts(nextYear.add(1.days())),
                FakeActivity.starts(nextYear.subtract(1.days())),
              ])));

      // Act
      activitiesBloc.add(LoadActivities());
      await activitiesBloc.stream.any((s) => s is ActivitiesLoaded);
      dayPickerBloc.add(NextDay());
      dayPickerBloc.add(PreviousDay());
      dayPickerBloc.add(PreviousDay());

      // Assert
      await expectLater(
        dayActivitiesBloc.stream,
        emitsInOrder([
          DayActivitiesLoaded(const <ActivityDay>[], today, Occasion.current),
          DayActivitiesLoaded(const <ActivityDay>[], tomorrow, Occasion.future),
          DayActivitiesLoaded(const <ActivityDay>[], today, Occasion.current),
          DayActivitiesLoaded(const <ActivityDay>[], yesterday, Occasion.past),
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
      when(mockActivityRepository.load()).thenAnswer((_) => Future.value([]));

      // Act
      activitiesBloc.add(LoadActivities());

      // Assert
      await expectLater(
        dayActivitiesBloc.stream,
        emits(DayActivitiesLoaded(
            const <ActivityDay>[], today, Occasion.current)),
      );

      // Arrange
      when(mockActivityRepository.load())
          .thenAnswer((_) => Future.value(activitiesAdded));

      // Act
      activitiesBloc.add(LoadActivities());

      // Assert
      await expectLater(
        dayActivitiesBloc.stream,
        emits(DayActivitiesLoaded(expectedActivity, today, Occasion.current)),
      );
    });

    tearDown(() {
      dayPickerBloc.close();
      activitiesBloc.close();
    });
  });

  group('Recurring tests activity', () {
    final firstDay = DateTime(2006, 06, 01); // 2006-06-01 was a thursday
    setUp(() {
      final stream = Stream<DateTime>.empty();
      dayPickerBloc =
          DayPickerBloc(clockBloc: ClockBloc(stream, initialTime: firstDay));
      mockActivityRepository = MockActivityRepository();
      activitiesBloc = ActivitiesBloc(
        activityRepository: mockActivityRepository,
        syncBloc: FakeSyncBloc(),
        pushBloc: FakePushBloc(),
      );
      dayActivitiesBloc = DayActivitiesBloc(
          dayPickerBloc: dayPickerBloc, activitiesBloc: activitiesBloc);
    });

    test('Shows recurring weekends', () async {
      // Arrange
      final weekendActivity = [
        FakeActivity.reocurrsWeekends(DateTime(2000, 01, 01))
      ];
      when(mockActivityRepository.load())
          .thenAnswer((_) => Future.value(weekendActivity));
      // Act
      activitiesBloc.add(LoadActivities());
      await dayActivitiesBloc.stream.any((s) => s is DayActivitiesLoaded);
      dayPickerBloc.add(NextDay());
      dayPickerBloc.add(NextDay());
      dayPickerBloc.add(NextDay());
      dayPickerBloc.add(NextDay());
      // Assert
      await expectLater(
          dayActivitiesBloc.stream,
          emitsInOrder([
            DayActivitiesLoaded(
              const <ActivityDay>[],
              firstDay.add(Duration(days: 1)),
              Occasion.future,
            ), // friday
            DayActivitiesLoaded(
              weekendActivity
                  .map((a) => ActivityDay(a, firstDay.add(Duration(days: 2))))
                  .toList(),
              firstDay.add(Duration(days: 2)),
              Occasion.future,
            ), // saturday
            DayActivitiesLoaded(
              weekendActivity
                  .map((a) => ActivityDay(a, firstDay.add(Duration(days: 3))))
                  .toList(),
              firstDay.add(Duration(days: 3)),
              Occasion.future,
            ), // sunday
            DayActivitiesLoaded(
              const <ActivityDay>[],
              firstDay.add(Duration(days: 4)),
              Occasion.future,
            ), // monday
          ]));
    });

    test('Shows recurring christmas', () async {
      // Arrange
      final boxingDay = DateTime(2000, 12, 23);
      final chrismasEve = DateTime(2000, 12, 24);
      final chrismasDay = DateTime(2000, 12, 25);
      final christmas = [
        FakeActivity.reocurrsOnDate(chrismasEve, DateTime(2000, 01, 01))
      ];
      when(mockActivityRepository.load())
          .thenAnswer((_) => Future.value(christmas));
      // Act
      activitiesBloc.add(LoadActivities());
      await dayActivitiesBloc.stream.any((s) => s is DayActivitiesLoaded);
      dayPickerBloc.add(GoTo(day: boxingDay));
      dayPickerBloc.add(NextDay());
      dayPickerBloc.add(NextDay());
      // Assert
      await expectLater(
          dayActivitiesBloc.stream,
          emitsInOrder([
            DayActivitiesLoaded(
              const <ActivityDay>[],
              boxingDay,
              Occasion.past,
            ),
            DayActivitiesLoaded(
              christmas.map((a) => ActivityDay(a, chrismasEve)).toList(),
              chrismasEve,
              Occasion.past,
            ),
            DayActivitiesLoaded(
              const <ActivityDay>[],
              chrismasDay,
              Occasion.past,
            ),
          ]));
    });

    test('Does not show recurring christmas after endTime', () async {
      // Arrange
      final boxingDay = DateTime(2022, 12, 23);
      final chrismasEve = DateTime(2022, 12, 24);
      final chrismasDay = DateTime(2022, 12, 25);
      final christmas = Iterable<Activity>.empty().followedBy([
        FakeActivity.reocurrsOnDate(
            chrismasEve, DateTime(2012, 01, 01), DateTime(2021, 01, 01))
      ]);
      when(mockActivityRepository.load())
          .thenAnswer((_) => Future.value(christmas));
      // Act
      activitiesBloc.add(LoadActivities());
      await dayActivitiesBloc.stream.any((s) => s is DayActivitiesLoaded);
      dayPickerBloc.add(GoTo(day: boxingDay));
      dayPickerBloc.add(NextDay());
      dayPickerBloc.add(NextDay());
      // Assert
      await expectLater(
          dayActivitiesBloc.stream,
          emitsInOrder([
            DayActivitiesLoaded(
              const <ActivityDay>[],
              boxingDay,
              Occasion.future,
            ),
            DayActivitiesLoaded(
              const <ActivityDay>[],
              chrismasEve,
              Occasion.future,
            ),
            DayActivitiesLoaded(
              const <ActivityDay>[],
              chrismasDay,
              Occasion.future,
            ),
          ]));
    });

    test('Show first of month during one year', () async {
      // Arrange
      final startTime = DateTime(2031, 12, 31);
      final endTime = DateTime(2032, 12, 31);
      final monthStartActivity = [
        FakeActivity.reocurrsOnDay(1, startTime, endTime)
      ];
      final allOtherDays = List.generate(
          300, (i) => startTime.add(Duration(days: i)).onlyDays());
      when(mockActivityRepository.load())
          .thenAnswer((_) => Future.value(monthStartActivity));

      // Act
      activitiesBloc.add(LoadActivities());
      await dayActivitiesBloc.stream.any((s) => s is DayActivitiesLoaded);
      dayPickerBloc.add(GoTo(day: startTime));
      for (final _ in allOtherDays) {
        dayPickerBloc.add(NextDay());
      }

      // Assert
      await expectLater(
        dayActivitiesBloc.stream,
        emitsInOrder(
          allOtherDays.map(
            (day) => DayActivitiesLoaded(
              day.day == 1
                  ? monthStartActivity.map((a) => ActivityDay(a, day)).toList()
                  : <ActivityDay>[],
              day,
              Occasion.future,
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

      when(mockActivityRepository.load())
          .thenAnswer((_) => Future.value([preSplitRecurring, splitRecurring]));

      // Act
      activitiesBloc.add(LoadActivities());
      await activitiesBloc.stream.any((s) => s is ActivitiesLoaded);
      dayPickerBloc.add(GoTo(day: dayBeforeSplit));
      dayPickerBloc.add(NextDay());
      dayPickerBloc.add(NextDay());

      // Assert
      await expectLater(
          dayActivitiesBloc.stream,
          emitsInOrder([
            DayActivitiesLoaded(
              const <ActivityDay>[],
              firstDay,
              Occasion.current,
            ),
            DayActivitiesLoaded(
              [preSplitRecurring]
                  .map((a) => ActivityDay(a, dayBeforeSplit))
                  .toList(),
              dayBeforeSplit,
              Occasion.future,
            ),
            DayActivitiesLoaded(
              [splitRecurring].map((a) => ActivityDay(a, dayOnSplit)).toList(),
              dayOnSplit,
              Occasion.future,
            ),
            DayActivitiesLoaded(
              [splitRecurring]
                  .map((e) => ActivityDay(e, dayOnSplit.add(Duration(days: 1))))
                  .toList(),
              dayOnSplit.add(Duration(days: 1)),
              Occasion.future,
            ),
          ]));
    });

    tearDown(() {
      dayPickerBloc.close();
      activitiesBloc.close();
    });
  });
}
