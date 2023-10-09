import 'package:calendar_events/calendar_events.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utils/utils.dart';

void main() {
  test('Timer to dbMap and back', () {
    final timer = AbiliaTimer.createNew(
      title: 'myTitle',
      fileId: 'myFileId',
      startTime: DateTime(11, 11, 11),
      duration: 30.minutes(),
    );
    final dbMap = timer.toMapForDb();

    final timerFromDb = AbiliaTimer.fromDbMap(dbMap);
    expect(timerFromDb, timer);
  });
}
