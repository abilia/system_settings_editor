import 'package:flutter_test/flutter_test.dart';
import 'package:rxdart/subjects.dart';
import 'package:timezone/timezone.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

void main() {
  final aTime = DateTime(1999, 12, 20, 20, 12);
  final aDay = aTime.onlyDays();
  late ReplaySubject<NotificationAlarm> notificationSelected;
  late NotificationCubit notificationBloc;
  const localTimezoneName = 'aTimeZone';

  setUp(() {
    setLocalLocation(Location(localTimezoneName, [], [], []));
    notificationSelected = ReplaySubject<NotificationAlarm>();

    notificationBloc = NotificationCubit(
      selectedNotificationSubject: notificationSelected,
    );
  });

  test('initial state', () {
    expect(notificationBloc.state, null);
  });

  test('Notification selected emits new alarm state', () async {
    // Arrange
    final nowActivity =
        FakeActivity.starts(aTime).copyWith(timezone: localTimezoneName);
    final payload = StartAlarm(nowActivity, aDay);

    // Act
    notificationSelected.add(payload);

    // Assert
    await expectLater(
        notificationBloc.stream, emits(StartAlarm(nowActivity, aDay)));
  });

  test('Notification selected emits new reminder state', () async {
    // Arrange
    final reminderTime = 5.minutes();
    final nowActivity = FakeActivity.starts(aTime).copyWith(
        timezone: localTimezoneName,
        reminderBefore: [reminderTime.inMilliseconds]);

    final payload = ReminderBefore(
      nowActivity,
      aDay,
      reminder: reminderTime,
    );
    notificationSelected.add(payload);

    // Assert
    await expectLater(
      notificationBloc.stream,
      emits(ReminderBefore(
        nowActivity,
        aDay,
        reminder: reminderTime,
      )),
    );
  });
}
