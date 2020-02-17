import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

void main() {
  group('get alarms and reminders', () {
    final startDate = DateTime(2008, 8, 8, 8, 8);
    final day = startDate.onlyDays();
    final endDate = DateTime(2008, 8, 9, 8, 8);
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

//////////////////////////////////////////////
// Testing with end dates ////////////////////
//////////////////////////////////////////////

    test('no alarms with end', () {
      // Arrange
      final activities = Iterable<Activity>.empty();
      // Act
      final alarms = activities.alarmsForRange(startDate, endDate);
      // Assert
      expect(alarms, isEmpty);
    });

    test('one same start alarms with end', () {
      // Arrange
      final activity = FakeActivity.starts(startDate);
      final activities = [activity];

      // Act
      final alarms = activities.alarmsForRange(startDate, endDate).toList();
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
      final alarms = activities.alarmsForRange(startDate, endDate).toList();
      // Assert
      expect(alarms, [NewAlarm(activity, day, alarmOnStart: false)]);
    });

    test('alarm one min after with end', () {
      // Arrange
      final activity = FakeActivity.starts(startDate.add(1.minutes()));
      final activities = [activity];

      // Act
      final alarms = activities.alarmsForRange(startDate, endDate).toList();
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
      final alarms = activities.alarmsForRange(startDate, endDate).toSet();
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
          .copyWith(reminderBefore: [5.minutes().inMilliseconds]);
      final onTime = FakeActivity.starts(startDate, title: 'onTime');
      final activities = [afterWithReminder, onTime];

      // Act
      final alarms = activities.alarmsForRange(startDate, endDate).toList();
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
      final alarms = activities.alarmsForRange(startDate, endDate).toList();
      // Assert
      expect(alarms, [NewReminder(afterWithReminder, day, reminder: reminder)]);
    });

    test('one start and end with start passed, one future without end time',
        () {
      // Arrange
      final fiveMinBefore = startDate.subtract(5.minutes());
      final end = fiveMinBefore.add(1.hours());
      final in30 = startDate.add(30.minutes());

      final overlapping = FakeActivity.starts(fiveMinBefore).copyWith(
          title: 'Well hello there',
          alarmType: ALARM_SOUND_AND_VIBRATION,
          duration: 1.hours().inMilliseconds,
          endTime: end.millisecondsSinceEpoch);
      final later = FakeActivity.starts(in30).copyWith(
          title: 'Another one bites the dust',
          endTime: in30.millisecondsSinceEpoch,
          duration: 0,
          alarmType: ALARM_SOUND_AND_VIBRATION);
      final activities = [overlapping, later];

      // Act
      final alarms = activities.alarmsForRange(startDate, endDate).toSet();

      // Asserte
      expect(
          alarms,
          [
            NewAlarm(overlapping, day, alarmOnStart: false),
            NewAlarm(later, day),
          ].toSet());
    });
  });
}
