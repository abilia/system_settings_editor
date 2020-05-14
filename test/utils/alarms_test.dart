import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

void main() {
  group('alarms On Exact Minute', () {
    final startDate = DateTime(2008, 8, 8, 8, 8);
    final day = startDate.onlyDays();
    test('no alarms', () {
      // Arrange
      final activities = Iterable<Activity>.empty();
      // Act
      final alarms = activities.alarmsOnExactMinute(startDate);
      // Assert
      expect(alarms, isEmpty);
    });

    test('one same start alarms', () {
      // Arrange
      final activity = FakeActivity.starts(startDate);
      final activities = [activity];

      // Act
      final alarms = activities.alarmsOnExactMinute(startDate).toList();
      // Assert
      expect(alarms, [NewAlarm(activity, day)]);
    });

    test('alarm one min before', () {
      // Arrange
      final activity = FakeActivity.starts(startDate.subtract(1.minutes()));
      final activities = [activity];

      // Act
      final alarms = activities.alarmsOnExactMinute(startDate).toList();
      // Assert
      expect(alarms, isEmpty);
    });

    test('alarm one min after', () {
      // Arrange
      final activity = FakeActivity.starts(startDate.add(1.minutes()));
      final activities = [activity];

      // Act
      final alarms = activities.alarmsOnExactMinute(startDate).toList();
      // Assert
      expect(alarms, isEmpty);
    });

    test('one on, one after, one before', () {
      // Arrange
      final before = FakeActivity.starts(startDate.subtract(1.minutes()));
      final after = FakeActivity.starts(startDate.add(1.minutes()));
      final onTime = FakeActivity.starts(startDate);
      final activities = [before, after, onTime];

      // Act
      final alarms = activities.alarmsOnExactMinute(startDate).toList();
      // Assert
      expect(alarms, [NewAlarm(onTime, day)]);
    });

    test('one on, and one reminder after', () {
      // Arrange
      final reminder = 5.minutes();
      final afterWithReminder = FakeActivity.starts(startDate.add(reminder))
          .copyWith(reminderBefore: [5.minutes().inMilliseconds]);
      final onTime = FakeActivity.starts(startDate);
      final activities = [afterWithReminder, onTime];

      // Act
      final alarms = activities.alarmsOnExactMinute(startDate).toList();
      // Assert
      expect(
          listEquals(alarms, [
            NewAlarm(onTime, day),
            NewReminder(afterWithReminder, day, reminder: reminder)
          ]),
          isTrue);
    });

    test('one on without alarm, and one reminder after', () {
      // Arrange
      final reminder = 5.minutes();
      final afterWithReminder = FakeActivity.starts(startDate.add(reminder))
          .copyWith(
              reminderBefore: [5.minutes().inMilliseconds],
              alarmType: NO_ALARM);
      final onTime =
          FakeActivity.starts(startDate).copyWith(alarmType: NO_ALARM);
      final activities = [afterWithReminder, onTime];

      // Act
      final alarms = activities.alarmsOnExactMinute(startDate).toList();
      // Assert
      expect(alarms, [NewReminder(afterWithReminder, day, reminder: reminder)]);
    });

    test('full day is no alarm', () {
      // Arrange
      final activity = FakeActivity.starts(startDate).copyWith(fullDay: true);
      final activities = [activity];

      // Act
      final alarms = activities.alarmsOnExactMinute(startDate).toList();
      // Assert
      expect(alarms, isEmpty);
    });
    test('fullday with reminders or alarm is no alarm', () {
      // Arrange
      final reminder = 5.minutes();
      final afterWithReminder = FakeActivity.starts(startDate.add(reminder))
          .copyWith(
              reminderBefore: [5.minutes().inMilliseconds], fullDay: true);
      final onTime = FakeActivity.starts(startDate).copyWith(fullDay: true);
      final activities = [afterWithReminder, onTime];

      // Act
      final alarms = activities.alarmsOnExactMinute(startDate).toList();
      // Assert
      expect(alarms, isEmpty);
    });
  });

  group('all alarms from', () {
    final startDate = DateTime(2008, 8, 8, 8, 8);
    final day = startDate.onlyDays();
    final now = DateTime(2020, 03, 24);
    final tomorrow = now.nextDay();
    test('no alarms with end', () {
      // Arrange
      final activities = Iterable<Activity>.empty();
      // Act
      final alarms = activities.alarmsFrom(startDate);
      // Assert
      expect(alarms, isEmpty);
    });

    test('one same start alarms with end', () {
      // Arrange
      final activity = FakeActivity.starts(startDate);
      final activities = [activity];

      // Act
      final alarms = activities.alarmsFrom(startDate).toList();
      // Assert
      expect(alarms, [
        NewAlarm(activity, day, alarmOnStart: true),
        NewAlarm(activity, day, alarmOnStart: false)
      ]);
    });

    test('alarm one min before with end', () {
      // Arrange
      final activity = FakeActivity.starts(startDate.subtract(1.minutes()));
      final activities = [activity];

      // Act
      final alarms = activities.alarmsFrom(startDate).toList();
      // Assert
      expect(alarms, [NewAlarm(activity, day, alarmOnStart: false)]);
    });

    test('alarm one min after with end', () {
      // Arrange
      final activity = FakeActivity.starts(startDate.add(1.minutes()));
      final activities = [activity];

      // Act
      final alarms = activities.alarmsFrom(startDate).toList();
      // Assert
      expect(alarms, [
        NewAlarm(activity, day, alarmOnStart: true),
        NewAlarm(activity, day, alarmOnStart: false)
      ]);
    });

    test('one on, one after, one before with end', () {
      // Arrange
      final before = FakeActivity.starts(startDate.subtract(1.minutes()));
      final after = FakeActivity.starts(startDate.add(1.minutes()));
      final onTime = FakeActivity.starts(startDate);
      final activities = [before, after, onTime];

      // Act
      final alarms = activities.alarmsFrom(startDate).toSet();
      // Assert
      expect(
        alarms,
        [
          NewAlarm(after, day, alarmOnStart: true),
          NewAlarm(onTime, day, alarmOnStart: true),
          NewAlarm(after, day, alarmOnStart: false),
          NewAlarm(onTime, day, alarmOnStart: false),
          NewAlarm(before, day, alarmOnStart: false),
        ].toSet(),
      );
    });

    test('one on, and one reminder after', () {
      // Arrange
      final reminder = 5.minutes();
      final afterWithReminder = FakeActivity.starts(startDate.add(reminder),
              title: 'after with reminder')
          .copyWith(reminderBefore: [reminder.inMilliseconds]);
      final onTime = FakeActivity.starts(startDate, title: 'onTime');
      final activities = [afterWithReminder, onTime];

      // Act
      final alarms = activities.alarmsFrom(startDate).toList();
      // Assert
      expect(alarms, [
        NewAlarm(afterWithReminder, day, alarmOnStart: true),
        NewAlarm(onTime, day, alarmOnStart: true),
        NewAlarm(afterWithReminder, day, alarmOnStart: false),
        NewAlarm(onTime, day, alarmOnStart: false),
        NewReminder(afterWithReminder, day, reminder: reminder)
      ]);
    });

    test('one on without alarm, and one reminder after', () {
      // Arrange
      final reminder = 5.minutes();
      final afterWithReminder = FakeActivity.starts(startDate.add(reminder))
          .copyWith(
              reminderBefore: [5.minutes().inMilliseconds],
              alarmType: NO_ALARM);
      final onTime =
          FakeActivity.starts(startDate).copyWith(alarmType: NO_ALARM);
      final activities = [afterWithReminder, onTime];

      // Act
      final alarms = activities.alarmsFrom(startDate).toList();
      // Assert
      expect(alarms, [NewReminder(afterWithReminder, day, reminder: reminder)]);
    });

    test('one start and end with start passed, one future without end time',
        () {
      // Arrange
      final fiveMinBefore = startDate.subtract(5.minutes());
      final in30 = startDate.add(30.minutes());

      final overlapping = FakeActivity.starts(fiveMinBefore).copyWith(
          title: 'Well hello there',
          alarmType: ALARM_SOUND_AND_VIBRATION,
          duration: 1.hours());
      final later = FakeActivity.starts(in30).copyWith(
          title: 'Another one bites the dust',
          alarmType: ALARM_SOUND_AND_VIBRATION,
          duration: 0.minutes());
      final activities = [overlapping, later];

      // Act
      final alarms = activities.alarmsFrom(startDate).toSet();

      // Asserte
      expect(
          alarms,
          [
            NewAlarm(overlapping, day, alarmOnStart: false),
            NewAlarm(later, day),
          ].toSet());
    });

    test('empty list gives back no alarms or reminders', () {
      final got = <Activity>[].alarmsFrom(now, take: 100);
      expect(got, isEmpty);
    });

    test('one activity gives back one ativity', () {
      final activity = Activity.createNew(title: '', startTime: now);
      final got = <Activity>[activity].alarmsFrom(now, take: 100);
      expect(got, [NewAlarm(activity, now)]);
    });

    test('reaccurs daily gives back all daily', () {
      final activity = FakeActivity.reocurrsEveryDay(now)
          .copyWith(alarmType: ALARM_SOUND_ONLY_ON_START);
      final got = <Activity>[activity].alarmsFrom(now, take: 100, maxDays: 500);
      expect(got, hasLength(100));
    });

    test('reaccurs weekly gives back all week in the given days', () {
      final lenght = 100;
      final maxDays = 400;
      final activity = FakeActivity.reocurrsFridays(now)
          .copyWith(alarmType: ALARM_SOUND_ONLY_ON_START);
      final got =
          <Activity>[activity].alarmsFrom(now, take: lenght, maxDays: maxDays);
      expect(got, hasLength(maxDays ~/ 7));
    });

    test('reminder right on time', () {
      final activity = Activity.createNew(
          title: 'null',
          alarmType: NO_ALARM,
          startTime: now.add(5.minutes()),
          reminderBefore: [5.minutes().inMilliseconds]);
      final got = <Activity>[activity].alarmsFrom(now);
      expect(got, [NewReminder(activity, now, reminder: 5.minutes())]);
    });

    test(
        'reaccurs daily and one other activity gives back that other one aswell',
        () {
      final lenght = 100;
      final in50Days = now.copyWith(day: now.day + 50);
      final reoccuringActivity = FakeActivity.reocurrsEveryDay(now)
          .copyWith(alarmType: ALARM_SOUND_ONLY_ON_START);
      final normalActivity = Activity.createNew(
          title: 'THIS HAPPENS IN 20 days',
          startTime: in50Days,
          alarmType: ALARM_SOUND_AND_VIBRATION);
      final got = <Activity>[reoccuringActivity, normalActivity]
          .alarmsFrom(now, take: lenght, maxDays: 1000);

      expect(got, hasLength(100));
      expect(got, contains(NewAlarm(normalActivity, in50Days)));
    });

    test('returns reminders', () {
      final reminder = 2.hours();

      final reminderActivity = Activity.createNew(
          title: 'has a reminder',
          alarmType: NO_ALARM,
          startTime: tomorrow,
          reminderBefore: [reminder.inMilliseconds]);

      final got = <Activity>[
        reminderActivity,
      ].alarmsFrom(now, take: 100);

      expect(
          got, [NewReminder(reminderActivity, tomorrow, reminder: reminder)]);
    });

    test('returns only todays first 50', () {
      final manyToday = Iterable.generate(
          70,
          (i) => Activity.createNew(
              title: 'has a reminder', startTime: now.add(i.minutes())));
      final manyTomorrow = Iterable.generate(
          70,
          (i) => Activity.createNew(
              title: 'has a reminder', startTime: tomorrow.add(i.minutes())));

      final got = manyTomorrow.followedBy(manyToday).alarmsFrom(now, take: 50);

      expect(got, hasLength(50));
      expect(
          got.any((a) => a.activity.startTime.isAtSameDay(tomorrow)), isFalse);
    });

    test('returns reminders and start end time', () {
      final remindersDates = [
        5.minutes(),
        15.minutes(),
        30.minutes(),
        1.hours(),
        2.hours(),
        1.days(),
      ].map((r) => r.inMilliseconds);
      final reoccuringActivity = FakeActivity.reocurrsEveryDay(now)
          .copyWith(reminderBefore: remindersDates);

      final got = <Activity>[
        reoccuringActivity,
      ].alarmsFrom(now, take: 100);

      expect(got, hasLength(100));
      expect(
          got,
          containsAll([
            NewAlarm(reoccuringActivity, now),
            NewAlarm(reoccuringActivity, now, alarmOnStart: false),
            NewAlarm(reoccuringActivity, tomorrow),
            NewAlarm(reoccuringActivity, tomorrow, alarmOnStart: false)
          ]));

      expect(
        got,
        containsAll(
          remindersDates.map(
            (r) => NewReminder(
              reoccuringActivity,
              tomorrow,
              reminder: Duration(milliseconds: r),
            ),
          ),
        ),
      );

      final shouldNotContainTheseReminders = remindersDates
          .map(
            (r) => NewReminder(
              reoccuringActivity,
              now,
              reminder: Duration(milliseconds: r),
            ),
          )
          .toSet();
      expect(got.toSet().intersection(shouldNotContainTheseReminders), isEmpty);
    });
    test('fullday is not alarm or reminders ', () {
      // Arrange
      final reminder = 5.minutes();
      final afterWithReminder = FakeActivity.starts(startDate.add(reminder),
              title: 'after with reminder')
          .copyWith(
        reminderBefore: [reminder.inMilliseconds],
        fullDay: true,
      );
      final onTime = FakeActivity.starts(startDate, title: 'onTime').copyWith(
        fullDay: true,
      );
      final activities = [afterWithReminder, onTime];

      // Act
      final alarms = activities.alarmsFrom(startDate).toList();
      // Assert
      expect(alarms, isEmpty);
    });
  });
}
