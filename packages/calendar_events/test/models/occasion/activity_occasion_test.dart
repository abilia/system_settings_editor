import 'package:calendar_events/calendar_events.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utils/utils.dart';

void main() {
  test('correct past day', () {
    // Arrange
    final now = DateTime(2020, 05, 27, 12, 25);
    final startTime = DateTime(2020, 05, 26, 23, 30);
    final startDay = startTime.onlyDays();
    final duration = 8.hours();
    final activity = Activity.createNew(
        title: '*', startTime: startTime, duration: duration);
    // Act
    final ao = ActivityDay(activity, startDay).toOccasion(now);
    // Assert
    expect(ao.occasion, Occasion.past);
  });
}
