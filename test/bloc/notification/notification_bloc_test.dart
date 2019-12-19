import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc.dart';
import 'package:seagull/fakes/fake_activities.dart';
import 'package:seagull/models.dart';
import 'package:seagull/utils.dart';

import '../../mocks.dart';

void main() {
  ActivitiesBloc activitiesBloc;
  MockActivityRepository mockActivityRepository;
  DateTime aTime = DateTime(1999, 12, 20, 20, 12);
  StreamController<String> notificationSelected;
  NotificationBloc notificationBloc;

  group(
    'NotificationBloc',
    () {
      setUp(() {
        notificationSelected = StreamController<String>();
        mockActivityRepository = MockActivityRepository();
        activitiesBloc = ActivitiesBloc(
            activitiesRepository: mockActivityRepository,
            pushBloc: MockPushBloc());

        notificationBloc = NotificationBloc(
          activitiesBloc: activitiesBloc,
          selectedNotificationStream: notificationSelected.stream,
        );
      });
      test(
          'Notification selected after Activities loaded emits new alarm state',
          () async {
        // Arrange
        final nowActivity = FakeActivity.onTime(aTime);
        when(mockActivityRepository.loadActivities())
            .thenAnswer((_) => Future.value([nowActivity]));

        final payload = json.encode(
            Payload(activityId: nowActivity.id, onStart: true).toJson());
        // Act
        activitiesBloc.add(LoadActivities());
        await activitiesBloc.firstWhere((s) => s is ActivitiesLoaded);
        notificationSelected.add(payload);

        // Assert
        await expectLater(
            notificationBloc,
            emitsInOrder([
              UnInitializedAlarmState(),
              AlarmState(NewAlarm(nowActivity)),
            ]));
      });

      test(
          'Notification selected after Activities loaded emits new reminder state',
          () async {
        // Arrange
        final reminderTime = 5;
        final nowActivity = FakeActivity.onTime(aTime)
            .copyWith(reminderBefore: [reminderTime.minutes().inMilliseconds]);
        when(mockActivityRepository.loadActivities())
            .thenAnswer((_) => Future.value([nowActivity]));

        final payload = json.encode(
            Payload(activityId: nowActivity.id, reminder: reminderTime)
                .toJson());
        // Act
        activitiesBloc.add(LoadActivities());
        await activitiesBloc.firstWhere((s) => s is ActivitiesLoaded);
        notificationSelected.add(payload);

        // Assert
        await expectLater(
            notificationBloc,
            emitsInOrder([
              UnInitializedAlarmState(),
              AlarmState(NewReminder(
                nowActivity,
                reminder: reminderTime.minutes(),
              )),
            ]));
      });

      test(
          'Notification selected before Activities loaded emits after Activities loaded',
          () async {
        // Arrange
        final nowActivity = FakeActivity.onTime(aTime);
        when(mockActivityRepository.loadActivities())
            .thenAnswer((_) => Future.value([nowActivity]));

        final payload = Payload(activityId: nowActivity.id, onStart: true);
        final serializedPayload = json.encode(payload.toJson());

        // Act
        notificationSelected.add(serializedPayload);
        activitiesBloc.add(LoadActivities());

        // Assert
        await expectLater(
            notificationBloc,
            emitsInOrder([
              UnInitializedAlarmState(),
              PendingAlarmState([payload]),
              AlarmState(NewAlarm(nowActivity)),
            ]));
      });

      test(
          'Notifications selected before Activities loaded emits after Activities loaded',
          () async {
        // Arrange
        final alarmActivity = FakeActivity.onTime(aTime);
        final reminderTime = 5.minutes();
        final reminderActivity = FakeActivity.onTime(aTime)
            .copyWith(reminderBefore: [reminderTime.inMilliseconds]);

        when(mockActivityRepository.loadActivities())
            .thenAnswer((_) => Future.value([alarmActivity, reminderActivity]));

        final alarmPayload =
            Payload(activityId: alarmActivity.id, onStart: true);
        final alarmSerializedPayload = json.encode(alarmPayload.toJson());

        final reminderPayload = Payload(
            activityId: reminderActivity.id, reminder: reminderTime.inMinutes);
        final reminderSerializedPayload = json.encode(reminderPayload.toJson());

        // Act
        notificationSelected.add(alarmSerializedPayload);
        notificationSelected.add(reminderSerializedPayload);

        // Assert
        await expectLater(
            notificationBloc,
            emitsInAnyOrder([
              UnInitializedAlarmState(),
              PendingAlarmState([alarmPayload, reminderPayload]),
            ]));

        // Act
        activitiesBloc.add(LoadActivities());

        // Assert
        await expectLater(
            notificationBloc,
            emitsInAnyOrder([
              PendingAlarmState([alarmPayload, reminderPayload]),
              AlarmState(NewReminder(reminderActivity, reminder: reminderTime)),
              AlarmState(NewAlarm(alarmActivity)),
            ]));
      });
      tearDown(
        () {
          activitiesBloc.close();
          notificationSelected.close();
          notificationBloc.close();
        },
      );
    },
  );
}
