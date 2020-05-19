import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/models/all.dart';

void main() {
  final time = DateTime(2020, 05, 14, 18, 39, 30);
  final day = DateTime(2020, 05, 14);
  test('StartAlarm toJson and back', () {
    final original =
        StartAlarm(Activity.createNew(title: 'null', startTime: time), day);
    final asJson = original.toJson();
    final back = NotificationAlarm.fromJson(asJson);
    expect(back, original);
  });
  test('EndAlarm toJson and back', () {
    final original =
        EndAlarm(Activity.createNew(title: 'null', startTime: time), day);
    final asJson = original.toJson();
    final back = NotificationAlarm.fromJson(asJson);
    expect(back, original);
  });
  test('NewReminder toJson and back', () {
    final original = NewReminder(
        Activity.createNew(title: 'null', startTime: time), day,
        reminder: Duration(minutes: 5));
    final asJson = original.toJson();
    final back = NotificationAlarm.fromJson(asJson);
    expect(back, original);
  });
}
