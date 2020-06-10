import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

import '../../../mocks.dart';

void main() {
  ActivitiesBloc activitiesBloc;
  MockActivityRepository mockActivityRepository;
  final aTime = DateTime(1999, 12, 20, 20, 12);
  final aDay = aTime.onlyDays();
  StreamController<String> notificationSelected;
  NotificationBloc notificationBloc;

  setUp(() {
    notificationSelected = StreamController<String>();
    mockActivityRepository = MockActivityRepository();
    activitiesBloc = ActivitiesBloc(
      activityRepository: mockActivityRepository,
      syncBloc: MockSyncBloc(),
      pushBloc: MockPushBloc(),
    );

    notificationBloc = NotificationBloc(
      activitiesBloc: activitiesBloc,
      selectedNotificationStream: notificationSelected.stream,
    );
  });
  test('Notification selected after Activities loaded emits new alarm state',
      () async {
    // Arrange
    final nowActivity = FakeActivity.starts(aTime);
    when(mockActivityRepository.load())
        .thenAnswer((_) => Future.value([nowActivity]));

    final payload = json.encode(NotificationPayload(
            activityId: nowActivity.id, day: aDay, onStart: true)
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
          AlarmState(StartAlarm(nowActivity, aDay)),
        ]));
  });

  test('Notification selected after Activities loaded emits new reminder state',
      () async {
    // Arrange
    final reminderTime = 5;
    final nowActivity = FakeActivity.starts(aTime)
        .copyWith(reminderBefore: [reminderTime.minutes().inMilliseconds]);
    when(mockActivityRepository.load())
        .thenAnswer((_) => Future.value([nowActivity]));

    final payload = json.encode(NotificationPayload(
      activityId: nowActivity.id,
      day: aDay,
      reminder: reminderTime,
      onStart: true,
    ).toJson());
    // Act
    activitiesBloc.add(LoadActivities());
    await activitiesBloc.firstWhere((s) => s is ActivitiesLoaded);
    notificationSelected.add(payload);

    // Assert
    await expectLater(
        notificationBloc,
        emitsInOrder([
          UnInitializedAlarmState(),
          AlarmState(ReminderBefore(
            nowActivity,
            aDay,
            reminder: reminderTime.minutes(),
          )),
        ]));
  });

  test(
      'Notification selected before Activities loaded emits after Activities loaded',
      () async {
    // Arrange
    final nowActivity = FakeActivity.starts(aTime);
    when(mockActivityRepository.load())
        .thenAnswer((_) => Future.value([nowActivity]));

    final payload = NotificationPayload(
      activityId: nowActivity.id,
      day: aDay,
      onStart: true,
    );
    final serializedPayload = json.encode(payload.toJson());

    // Act
    notificationSelected.add(serializedPayload);
    activitiesBloc.add(LoadActivities());

    // Assert
    await expectLater(
        notificationBloc,
        emitsInOrder([
          UnInitializedAlarmState(),
          PendingAlarmState({payload}),
          AlarmState(StartAlarm(nowActivity, aDay)),
        ]));
  });

  test(
      'Notifications selected before Activities loaded emits after Activities loaded',
      () async {
    // Arrange
    final alarmActivity = FakeActivity.starts(aTime);
    final reminderTime = 5.minutes();
    final reminderActivity = FakeActivity.starts(aTime)
        .copyWith(reminderBefore: [reminderTime.inMilliseconds]);

    when(mockActivityRepository.load())
        .thenAnswer((_) => Future.value([alarmActivity, reminderActivity]));

    final alarmPayload = NotificationPayload(
      activityId: alarmActivity.id,
      day: aDay,
      onStart: true,
    );
    final alarmSerializedPayload = json.encode(alarmPayload.toJson());

    final reminderPayload = NotificationPayload(
      activityId: reminderActivity.id,
      day: aDay,
      reminder: reminderTime.inMinutes,
      onStart: true,
    );
    final reminderSerializedPayload = json.encode(reminderPayload.toJson());

    // Act
    notificationSelected.add(alarmSerializedPayload);
    notificationSelected.add(reminderSerializedPayload);

    // Assert
    await expectLater(
        notificationBloc,
        emitsInAnyOrder([
          UnInitializedAlarmState(),
          PendingAlarmState({alarmPayload}),
          PendingAlarmState({alarmPayload, reminderPayload}),
        ]));

    // Act
    activitiesBloc.add(LoadActivities());

    // Assert
    await expectLater(
        notificationBloc,
        emitsInAnyOrder([
          PendingAlarmState({alarmPayload, reminderPayload}),
          AlarmState(
              ReminderBefore(reminderActivity, aDay, reminder: reminderTime)),
          AlarmState(StartAlarm(alarmActivity, aDay)),
        ]));
  });

  test(
      'Notifications selected when the activity is not in the loaded activities emits pending alarm',
      () async {
    // Arrange
    final startTime = DateTime(2020, 06, 08, 12, 46);
    final day = startTime.onlyDays();

    final a1 = Activity.createNew(title: 'a1', startTime: startTime);
    final a2 =
        Activity.createNew(title: 'a2', startTime: startTime.add(1.hours()));
    final a3 =
        Activity.createNew(title: 'a3', startTime: startTime.add(2.hours()));

    when(mockActivityRepository.load())
        .thenAnswer((_) => Future.value([a1, a2]));

    final startAlarm = StartAlarm(a3, day);
    final alarmPayload = NotificationPayload.fromNotificationAlarm(startAlarm);
    final alarmPayloadJson = alarmPayload.toJson();
    final alarmPayloadEncoded = json.encode(alarmPayloadJson);

    when(mockActivityRepository.load())
        .thenAnswer((_) => Future.value([a1, a2]));
    // Act
    activitiesBloc.add(LoadActivities());
    await activitiesBloc.firstWhere((state) => state is ActivitiesLoaded);
    notificationSelected.add(alarmPayloadEncoded);

    // Assert
    await expectLater(
        notificationBloc,
        emitsInAnyOrder([
          UnInitializedAlarmState(),
          PendingAlarmState({alarmPayload}),
        ]));
  });

  test(
      'Notifications selected when the activity is not in the loaded emits alarm when the  activity is loaded',
      () async {
    // Arrange
    final startTime = DateTime(2020, 06, 08, 12, 46);
    final day = startTime.onlyDays();

    final a1 = Activity.createNew(title: 'a1', startTime: startTime);
    final a2 =
        Activity.createNew(title: 'a2', startTime: startTime.add(1.hours()));
    final a3 =
        Activity.createNew(title: 'a3', startTime: startTime.add(2.hours()));

    when(mockActivityRepository.load())
        .thenAnswer((_) => Future.value([a1, a2]));

    final startAlarm = StartAlarm(a3, day);
    final alarmPayload = NotificationPayload.fromNotificationAlarm(startAlarm);
    final alarmPayloadJson = alarmPayload.toJson();
    final alarmPayloadEncoded = json.encode(alarmPayloadJson);

    // Act
    activitiesBloc.add(LoadActivities()); // load activities a1 and a2
    await activitiesBloc.firstWhere((state) => state is ActivitiesLoaded);
    notificationSelected.add(
        alarmPayloadEncoded); // activity a3 comes as alarm, should be added as pending
    when(mockActivityRepository.load())
        .thenAnswer((_) => Future.value([a1, a2, a3]));
    activitiesBloc.add(LoadActivities()); // load activities a1, a2 and a3

    // Assert
    await expectLater(
        notificationBloc,
        emitsInAnyOrder([
          UnInitializedAlarmState(),
          PendingAlarmState({alarmPayload}),
          AlarmState(startAlarm),
        ]));
  });
}
