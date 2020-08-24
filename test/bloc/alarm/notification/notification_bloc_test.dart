import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

void main() {
  final aTime = DateTime(1999, 12, 20, 20, 12);
  final aDay = aTime.onlyDays();
  StreamController<String> notificationSelected;
  NotificationBloc notificationBloc;

  setUp(() {
    notificationSelected = StreamController<String>();

    notificationBloc = NotificationBloc(
      selectedNotificationStream: notificationSelected.stream,
    );
  });

  test('initial state', () {
    expect(notificationBloc.state, UnInitializedAlarmState());
  });

  test('Notification selected emits new alarm state', () async {
    // Arrange
    final nowActivity = FakeActivity.starts(aTime);
    final payload = json.encode(StartAlarm(nowActivity, aDay).toJson());

    // Act
    notificationSelected.add(payload);

    // Assert
    await expectLater(
        notificationBloc, emits(AlarmState(StartAlarm(nowActivity, aDay))));
  });

  test('Notification selected emits new reminder state', () async {
    // Arrange
    final reminderTime = 5.minutes();
    final nowActivity = FakeActivity.starts(aTime)
        .copyWith(reminderBefore: [reminderTime.inMilliseconds]);

    final payload = json.encode(ReminderBefore(
      nowActivity,
      aDay,
      reminder: reminderTime,
    ).toJson());
    notificationSelected.add(payload);

    // Assert
    await expectLater(
        notificationBloc,
        emits(
          AlarmState(ReminderBefore(
            nowActivity,
            aDay,
            reminder: reminderTime,
          )),
        ));
  });
}
