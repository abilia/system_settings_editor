import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc.dart';
import 'package:seagull/fakes/fake_activities.dart';
import 'package:seagull/models.dart';
import 'package:seagull/utils.dart';

import '../../mocks.dart';

void main() {
  ClockBloc clockBloc;
  ActivitiesBloc activitiesBloc;
  AlarmBloc alarmBloc;
  DateTime thisMinute = DateTime(2006, 06, 06, 06, 06).onlyMinutes();
  DateTime nextMinute = thisMinute.add(Duration(minutes: 1));
  DateTime inTwoMin = thisMinute.add(Duration(minutes: 2));
  MockActivityRepository mockActivityRepository;
  StreamController<DateTime> mockedTicker;

  _tick() async {
    final nextMin = clockBloc?.state?.add(Duration(minutes: 1));
    if (nextMin != null) {
      mockedTicker?.add(nextMin);
      await clockBloc.firstWhere((d) => d == nextMin);
    }
  }

  group(
    'AlarmBloc',
    () {
      setUp(() {
        mockedTicker = StreamController<DateTime>();
        clockBloc = ClockBloc(mockedTicker.stream, initialTime: thisMinute);
        mockActivityRepository = MockActivityRepository();
        activitiesBloc = ActivitiesBloc(
            activitiesRepository: mockActivityRepository,
            pushBloc: MockPushBloc());
        alarmBloc =
            AlarmBloc(clockBloc: clockBloc, activitiesBloc: activitiesBloc);
      });

      test('Load activities with current alarm shows alarm', () async {
        // Arrange
        final nowActivity = FakeActivity.onTime(nextMinute);
        when(mockActivityRepository.loadActivities())
            .thenAnswer((_) => Future.value([nowActivity]));
        // Act
        activitiesBloc.add(LoadActivities());
        await activitiesBloc.firstWhere((s) => s is ActivitiesLoaded);
        await _tick();
        // Assert
        await expectLater(
          alarmBloc,
          emitsInOrder([
            UnInitializedAlarmState(),
            AlarmState(NewAlarm(nowActivity)),
          ]),
        );
      });

      test('Ticks before Load activities does nothing', () async {
        // Arrange
        final nowActivity = FakeActivity.onTime(thisMinute);
        when(mockActivityRepository.loadActivities())
            .thenAnswer((_) => Future.value([nowActivity]));
        // Act
        await _tick();
        await _tick();
        await _tick();
        await _tick();
        await _tick();
        await alarmBloc.close();
        // Assert
        await expectLater(
          alarmBloc,
          neverEmits(AlarmState(NewAlarm(nowActivity))),
        );
      });

      test('Does not show if clock is not on start time', () async {
        // Arrange
        final soonActivity = FakeActivity.onTime(thisMinute);
        when(mockActivityRepository.loadActivities())
            .thenAnswer((_) => Future.value([soonActivity]));
        // Act
        await _tick();
        activitiesBloc.add(LoadActivities());
        await activitiesBloc.any((s) => s is ActivitiesLoaded);
        await alarmBloc.close();
        // Assert
        await expectLater(
          alarmBloc,
          neverEmits(AlarmState(NewAlarm(soonActivity))),
        );
      });

      test('Next minut alarm does nothing', () async {
        // Arrange
        final soonActivity = FakeActivity.onTime(nextMinute);
        when(mockActivityRepository.loadActivities())
            .thenAnswer((_) => Future.value([soonActivity]));
        // Act
        activitiesBloc.add(LoadActivities());
        await activitiesBloc.any((s) => s is ActivitiesLoaded);
        await alarmBloc.close();
        // Assert
        await expectLater(
          alarmBloc,
          neverEmits(AlarmState(NewAlarm(soonActivity))),
        );
      });

      test('Next minut alarm alarm next minute', () async {
        // Arrange
        final soonActivity = FakeActivity.onTime(nextMinute);
        when(mockActivityRepository.loadActivities())
            .thenAnswer((_) => Future.value([soonActivity]));
        // Act
        activitiesBloc.add(LoadActivities());
        await activitiesBloc.any((s) => s is ActivitiesLoaded);
        await _tick();
        // Assert
        await expectLater(
          alarmBloc,
          emitsInOrder([
            UnInitializedAlarmState(),
            AlarmState(NewAlarm(soonActivity)),
          ]),
        );
      });

      test('Two activities at the same time emits', () async {
        // Arrange
        final soonActivity = FakeActivity.onTime(nextMinute);
        final soonActivity2 = FakeActivity.onTime(nextMinute);
        when(mockActivityRepository.loadActivities())
            .thenAnswer((_) => Future.value([soonActivity, soonActivity2]));
        // Act
        activitiesBloc.add(LoadActivities());
        await activitiesBloc.any((s) => s is ActivitiesLoaded);
        await _tick();
        // Assert
        await expectLater(
          alarmBloc,
          emitsInAnyOrder([
            UnInitializedAlarmState(),
            AlarmState(NewAlarm(soonActivity)),
            AlarmState(NewAlarm(soonActivity2)),
          ]),
        );
      });

      test('two activities starts in order', () async {
        // Arrange
        final nowActivity = FakeActivity.onTime(thisMinute);
        final nextMinActivity = FakeActivity.onTime(nextMinute);
        final inTwoMinActivity = FakeActivity.onTime(inTwoMin);
        when(mockActivityRepository.loadActivities()).thenAnswer((_) =>
            Future.value([inTwoMinActivity, nowActivity, nextMinActivity]));

        // Act
        activitiesBloc.add(LoadActivities());
        await activitiesBloc.any((s) => s is ActivitiesLoaded);
        await _tick();
        await _tick();

        // Assert
        await expectLater(
          alarmBloc,
          emitsInOrder([
            AlarmState(NewAlarm(nextMinActivity)),
            AlarmState(NewAlarm(inTwoMinActivity)),
          ]),
        );
      });

      test('Activity with no alarm set does not trigger an alarm', () async {
        // Arrange
        final inOneMinuteWithoutAlarmActivity =
            FakeActivity.startsOneMinuteAfter(thisMinute)
                .copyWith(alarmType: NO_ALARM);
        final inTwoMinutesActivity =
            FakeActivity.startsOneMinuteAfter(nextMinute);
        when(mockActivityRepository.loadActivities()).thenAnswer((_) =>
            Future.value(
                [inTwoMinutesActivity, inOneMinuteWithoutAlarmActivity]));
        // Act
        activitiesBloc.add(LoadActivities());
        await _tick();
        await _tick();

        // Assert
        await expectLater(
            alarmBloc,
            emitsInOrder([
              UnInitializedAlarmState(),
              AlarmState(NewAlarm(inTwoMinutesActivity))
            ]));
      });

      test('Recuring weekly alarms shows', () async {
        // Arrange
        final recursThursday = FakeActivity.reocurrsTuedays(nextMinute);
        when(mockActivityRepository.loadActivities())
            .thenAnswer((_) => Future.value([recursThursday]));
        // Act
        activitiesBloc.add(LoadActivities());
        await activitiesBloc.any((s) => s is ActivitiesLoaded);
        await _tick();
        // Assert
        await expectLater(
          alarmBloc,
          emitsInOrder(
            [
              UnInitializedAlarmState(),
              AlarmState(NewAlarm(recursThursday)),
            ],
          ),
        );
      });

      test('Recuring monthly alarms shows', () async {
        // Arrange
        final recursTheThisDayOfMonth = FakeActivity.reocurrsOnDay(
            nextMinute.day,
            nextMinute.subtract(Duration(days: 60)),
            nextMinute.add(Duration(days: 60)));
        when(mockActivityRepository.loadActivities())
            .thenAnswer((_) => Future.value([recursTheThisDayOfMonth]));
        // Act
        activitiesBloc.add(LoadActivities());
        await activitiesBloc.any((s) => s is ActivitiesLoaded);
        await _tick();
        // Assert
        await expectLater(
            alarmBloc,
            emitsInOrder(
              [
                UnInitializedAlarmState(),
                AlarmState(NewAlarm(recursTheThisDayOfMonth)),
              ],
            ));
      });

      test('Recuring yearly alarms shows', () async {
        // Arrange
        final recursTheThisDayOfYear = FakeActivity.reocurrsOnDate(nextMinute);
        when(mockActivityRepository.loadActivities())
            .thenAnswer((_) => Future.value([recursTheThisDayOfYear]));
        // Act
        activitiesBloc.add(LoadActivities());
        await activitiesBloc.any((s) => s is ActivitiesLoaded);
        await _tick();
        // Assert
        await expectLater(
            alarmBloc,
            emitsInOrder(
              [
                UnInitializedAlarmState(),
                AlarmState(NewAlarm(recursTheThisDayOfYear)),
              ],
            ));
      });

      test('Alarm on EndTime shows', () async {
        // Arrange
        final activityEnding = FakeActivity.endsAt(nextMinute);
        when(mockActivityRepository.loadActivities())
            .thenAnswer((_) => Future.value([activityEnding]));
        // Act
        activitiesBloc.add(LoadActivities());
        await activitiesBloc.any((s) => s is ActivitiesLoaded);
        await _tick();
        // Assert
        await expectLater(
            alarmBloc,
            emitsInOrder(
              [
                UnInitializedAlarmState(),
                AlarmState(NewAlarm(activityEnding, alarmOnStart: false)),
              ],
            ));
      });

      test(
        'Alarm on EndTime does not show when it has no end time (start time is same as end time)',
        () async {
          // Arrange
          final nextAlarm = FakeActivity.onTime(nextMinute, Duration());
          final afterThatAlarm = FakeActivity.onTime(inTwoMin, Duration());
          when(mockActivityRepository.loadActivities())
              .thenAnswer((_) => Future.value([nextAlarm, afterThatAlarm]));
          // Act
          activitiesBloc.add(LoadActivities());
          await activitiesBloc.any((s) => s is ActivitiesLoaded);
          await _tick();
          await _tick();
          // Assert
          await expectLater(
            alarmBloc,
            emitsInOrder(
              [
                AlarmState(NewAlarm(nextAlarm, alarmOnStart: true)),
                AlarmState(NewAlarm(afterThatAlarm, alarmOnStart: true)),
              ],
            ),
          );
        },
      );

      test(
        'Reminders shows',
        () async {
          // Arrange
          final reminderTime = Duration(hours: 1);
          final remind1HourBefore =
              FakeActivity.future(nextMinute, reminderTime)
                  .copyWith(reminderBefore: [reminderTime.inMilliseconds]);
          when(mockActivityRepository.loadActivities())
              .thenAnswer((_) => Future.value([remind1HourBefore]));
          // Act
          activitiesBloc.add(LoadActivities());
          await activitiesBloc.any((s) => s is ActivitiesLoaded);
          await _tick();
          // Assert
          await expectLater(
            alarmBloc,
            emitsInOrder(
              [
                UnInitializedAlarmState(),
                AlarmState(
                    NewReminder(remind1HourBefore, reminder: reminderTime)),
              ],
            ),
          );
        },
      );

      tearDown(
        () {
          activitiesBloc.close();
          clockBloc.close();
          mockedTicker.close();
          alarmBloc.close();
        },
      );
    },
  );
}
