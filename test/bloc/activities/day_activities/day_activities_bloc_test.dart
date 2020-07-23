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
  ActivitiesBloc activitiesBloc;
  final today = DateTime(2020, 01, 01);
  final yesterday = today.subtract(Duration(days: 1));
  final tomorrow = today.add(Duration(days: 1));
  MockActivityRepository mockActivityRepository;
  group('DayActivitiesBloc', () {
    setUp(() {
      final stream = Stream<DateTime>.value(today);
      dayPickerBloc = DayPickerBloc(
        clockBloc: ClockBloc(stream, initialTime: today),
      );
      mockActivityRepository = MockActivityRepository();
      activitiesBloc = ActivitiesBloc(
        activityRepository: mockActivityRepository,
        syncBloc: MockSyncBloc(),
        pushBloc: MockPushBloc(),
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
      await dayActivitiesBloc.any((s) => s is DayActivitiesLoaded);

      // Assert
      expect(dayActivitiesBloc.state,
          DayActivitiesLoaded(Iterable<Activity>.empty(), today));
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
        dayActivitiesBloc,
        emits(DayActivitiesLoaded(activities, today)),
      );
    });

    test('DayActivitiesLoaded only loads todays activities', () {
      // Arrange
      final activitiesNow =
          <Activity>[FakeActivity.starts(today)].followedBy({});
      final activitiesTomorrow =
          <Activity>[FakeActivity.starts(today.add(1.days()))].followedBy({});

      when(mockActivityRepository.load()).thenAnswer(
          (_) => Future.value(activitiesNow.followedBy(activitiesTomorrow)));

      // Act
      activitiesBloc.add(LoadActivities());

      // Assert
      expectLater(
        dayActivitiesBloc,
        emits(DayActivitiesLoaded(activitiesNow, today)),
      );
    });

    test('next day loads next days activities', () async {
      // Arrange
      final activitiesNow =
          <Activity>[FakeActivity.starts(today)].followedBy({});
      final activitiesTomorrow = <Activity>[
        FakeActivity.starts(today.subtract(1.days()))
      ].followedBy({});
      when(mockActivityRepository.load()).thenAnswer(
          (_) => Future.value(activitiesNow.followedBy(activitiesTomorrow)));

      // Act
      activitiesBloc.add(LoadActivities());
      await activitiesBloc.any((s) => s is ActivitiesLoaded);
      dayPickerBloc.add(NextDay());

      // Assert
      await expectLater(
        dayActivitiesBloc,
        emitsInOrder([
          DayActivitiesLoaded(activitiesNow, today),
          DayActivitiesLoaded(activitiesTomorrow, tomorrow),
        ]),
      );
    });

    test('previous day loads previous days activities', () async {
      // Arrange
      final activitiesNow =
          <Activity>[(FakeActivity.starts(today))].followedBy({});
      final activitiesYesterDay = <Activity>[
        FakeActivity.starts(today.subtract(1.days()))
      ].followedBy({});
      when(mockActivityRepository.load()).thenAnswer(
          (_) => Future.value(activitiesNow.followedBy(activitiesYesterDay)));

      // Act
      activitiesBloc.add(LoadActivities());
      await activitiesBloc.any((s) => s is ActivitiesLoaded);
      dayPickerBloc.add(PreviousDay());

      // Assert
      await expectLater(
        dayActivitiesBloc,
        emitsInOrder([
          DayActivitiesLoaded(activitiesNow, today),
          DayActivitiesLoaded(activitiesYesterDay, yesterday),
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
      await activitiesBloc.any((s) => s is ActivitiesLoaded);
      dayPickerBloc.add(NextDay());
      dayPickerBloc.add(PreviousDay());
      dayPickerBloc.add(PreviousDay());

      // Assert
      await expectLater(
        dayActivitiesBloc,
        emitsInOrder([
          DayActivitiesLoaded(Iterable.empty(), today),
          DayActivitiesLoaded(Iterable.empty(), tomorrow),
          DayActivitiesLoaded(Iterable.empty(), today),
          DayActivitiesLoaded(Iterable.empty(), yesterday),
        ]),
      );
    });

    test('adding activities shows', () async {
      // Arrange
      final todayActivity =
          <Activity>[FakeActivity.starts(today)].followedBy({});
      final activitiesAdded = todayActivity.followedBy([
        FakeActivity.starts(today.add(1.days())),
        FakeActivity.starts(today.subtract(1.days())),
      ]).followedBy({});
      when(mockActivityRepository.load())
          .thenAnswer((_) => Future.value(Iterable.empty()));

      // Act
      activitiesBloc.add(LoadActivities());

      // Assert
      await expectLater(
        dayActivitiesBloc,
        emits(DayActivitiesLoaded(Iterable.empty(), today)),
      );

      // Arrange
      when(mockActivityRepository.load())
          .thenAnswer((_) => Future.value(activitiesAdded));

      // Act
      activitiesBloc.add(LoadActivities());

      // Assert
      await expectLater(
        dayActivitiesBloc,
        emits(DayActivitiesLoaded(todayActivity, today)),
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
        syncBloc: MockSyncBloc(),
        pushBloc: MockPushBloc(),
      );
      dayActivitiesBloc = DayActivitiesBloc(
          dayPickerBloc: dayPickerBloc, activitiesBloc: activitiesBloc);
    });

    test('Shows recurring weekends', () async {
      // Arrange
      final weekendActivity = Iterable<Activity>.empty()
          .followedBy([FakeActivity.reocurrsWeekends(DateTime(2000, 01, 01))]);
      when(mockActivityRepository.load())
          .thenAnswer((_) => Future.value(weekendActivity));
      // Act
      activitiesBloc.add(LoadActivities());
      await dayActivitiesBloc.any((s) => s is DayActivitiesLoaded);
      dayPickerBloc.add(NextDay());
      dayPickerBloc.add(NextDay());
      dayPickerBloc.add(NextDay());
      dayPickerBloc.add(NextDay());
      // Assert
      await expectLater(
          dayActivitiesBloc,
          emitsInOrder([
            DayActivitiesLoaded(
                Iterable.empty(), firstDay.add(Duration(days: 1))), // friday
            DayActivitiesLoaded(
                weekendActivity, firstDay.add(Duration(days: 2))), // saturday
            DayActivitiesLoaded(
                weekendActivity, firstDay.add(Duration(days: 3))), // sunday
            DayActivitiesLoaded(
                Iterable.empty(), firstDay.add(Duration(days: 4))), // monday
          ]));
    });

    test('Shows recurring christmas', () async {
      // Arrange
      final boxingDay = DateTime(2000, 12, 23);
      final chrismasEve = DateTime(2000, 12, 24);
      final chrismasDay = DateTime(2000, 12, 25);
      final christmas = Iterable<Activity>.empty().followedBy(
          [FakeActivity.reocurrsOnDate(chrismasEve, DateTime(2000, 01, 01))]);
      when(mockActivityRepository.load())
          .thenAnswer((_) => Future.value(christmas));
      // Act
      activitiesBloc.add(LoadActivities());
      await dayActivitiesBloc.any((s) => s is DayActivitiesLoaded);
      dayPickerBloc.add(GoTo(day: boxingDay));
      dayPickerBloc.add(NextDay());
      dayPickerBloc.add(NextDay());
      // Assert
      await expectLater(
          dayActivitiesBloc,
          emitsInOrder([
            DayActivitiesLoaded(Iterable.empty(), boxingDay),
            DayActivitiesLoaded(christmas, chrismasEve),
            DayActivitiesLoaded(Iterable.empty(), chrismasDay),
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
      await dayActivitiesBloc.any((s) => s is DayActivitiesLoaded);
      dayPickerBloc.add(GoTo(day: boxingDay));
      dayPickerBloc.add(NextDay());
      dayPickerBloc.add(NextDay());
      // Assert
      await expectLater(
          dayActivitiesBloc,
          emitsInOrder([
            DayActivitiesLoaded(Iterable.empty(), boxingDay),
            DayActivitiesLoaded(Iterable.empty(), chrismasEve),
            DayActivitiesLoaded(Iterable.empty(), chrismasDay),
          ]));
    });

    test('Does not show recurring christmas after endTime', () async {
      // Arrange
      final boxingDay = DateTime(2022, 12, 23);
      final chrismasEve = DateTime(2022, 12, 24);
      final chrismasDay = DateTime(2022, 12, 25);
      final weekendActivity = Iterable<Activity>.empty().followedBy([
        FakeActivity.reocurrsOnDate(
            chrismasEve, DateTime(2012, 01, 01), DateTime(2021, 01, 01))
      ]);
      when(mockActivityRepository.load())
          .thenAnswer((_) => Future.value(weekendActivity));
      // Act
      activitiesBloc.add(LoadActivities());
      await dayActivitiesBloc.any((s) => s is DayActivitiesLoaded);
      dayPickerBloc.add(GoTo(day: boxingDay));
      dayPickerBloc.add(NextDay());
      dayPickerBloc.add(NextDay());
      // Assert
      await expectLater(
          dayActivitiesBloc,
          emitsInOrder([
            DayActivitiesLoaded(Iterable.empty(), boxingDay),
            DayActivitiesLoaded(Iterable.empty(), chrismasEve),
            DayActivitiesLoaded(Iterable.empty(), chrismasDay),
          ]));
    });

    test('Show first of month during one year', () async {
      // Arrange
      final startTime = DateTime(2031, 12, 31);
      final endTime = DateTime(2032, 12, 31);
      final weekendActivity = Iterable<Activity>.empty()
          .followedBy([FakeActivity.reocurrsOnDay(1, startTime, endTime)]);
      final allOtherDays = List.generate(
          300, (i) => startTime.add(Duration(days: i)).onlyDays());
      when(mockActivityRepository.load())
          .thenAnswer((_) => Future.value(weekendActivity));

      // Act
      activitiesBloc.add(LoadActivities());
      await dayActivitiesBloc.any((s) => s is DayActivitiesLoaded);
      dayPickerBloc.add(GoTo(day: startTime));
      allOtherDays.forEach((_) => dayPickerBloc.add(NextDay()));

      // Assert
      await expectLater(
        dayActivitiesBloc,
        emitsInOrder(
          allOtherDays.map(
            (day) => DayActivitiesLoaded(
                day.day == 1 ? weekendActivity : Iterable.empty(), day),
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
        reminderBefore: [],
        recurs: Recurs.weekly(16383, ends: preSplitEndTime),
        alarmType: 104,
        duration: 86399999.milliseconds(),
        category: 0,
        startTime: preSplitStartTime,
        fullDay: true,
      );

      final splitRecurring = Activity.createNew(
        title: 'Split recurring ',
        reminderBefore: [],
        recurs: Recurs.weekly(16383, ends: splitEndTime),
        alarmType: 104,
        duration: 86399999.milliseconds(),
        category: 0,
        startTime: splitStartTime,
        fullDay: true,
      );

      when(mockActivityRepository.load())
          .thenAnswer((_) => Future.value([preSplitRecurring, splitRecurring]));

      // Act
      activitiesBloc.add(LoadActivities());
      await activitiesBloc.any((s) => s is ActivitiesLoaded);
      dayPickerBloc.add(GoTo(day: dayBeforeSplit));
      dayPickerBloc.add(NextDay());
      dayPickerBloc.add(NextDay());

      // Assert
      await expectLater(
          dayActivitiesBloc,
          emitsInOrder([
            DayActivitiesLoaded(Iterable.empty(), firstDay),
            DayActivitiesLoaded(
                Iterable<Activity>.empty().followedBy([preSplitRecurring]),
                dayBeforeSplit),
            DayActivitiesLoaded(
                Iterable<Activity>.empty().followedBy([splitRecurring]),
                dayOnSplit),
            DayActivitiesLoaded(
                Iterable<Activity>.empty().followedBy([splitRecurring]),
                dayOnSplit.add(Duration(days: 1))),
          ]));
    });

    tearDown(() {
      dayPickerBloc.close();
      activitiesBloc.close();
    });
  });
}
