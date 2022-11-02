import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

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
