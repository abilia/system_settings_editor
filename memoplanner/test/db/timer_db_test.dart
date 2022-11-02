import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

void main() {
  late Database db;
  late TimerDb timerDb;

  setUp(() async {
    db = await DatabaseRepository.createInMemoryFfiDb();
    timerDb = TimerDb(db);
  });

  tearDown(() {
    DatabaseRepository.clearAll(db);
  });

  test('add timer and delete timer', () async {
    final time = DateTime(2022, 2, 22, 22, 22);
    final all = await timerDb.getAllTimers();
    expect(all, isEmpty);
    final t = AbiliaTimer.createNew(
      title: 'title',
      fileId: 'fileid',
      startTime: time,
      duration: const Duration(minutes: 22),
    );

    final insertRes = await timerDb.insert(t);
    expect(insertRes, 1);

    final all1 = await timerDb.getAllTimers();
    expect(all1, hasLength(1));
    expect(all1.first, t);

    final deleteRes = await timerDb.delete(t);
    expect(deleteRes, 1);

    final all2 = await timerDb.getAllTimers();
    expect(all2, isEmpty);
  });

  test('getActiveTimersFrom', () async {
    final now = DateTime(2022, 2, 22, 22, 22);

    final t1 = AbiliaTimer.createNew(
          title: 'ongoing',
          startTime: now.subtract(10.minutes()),
          duration: const Duration(minutes: 22),
        ),
        t2 = AbiliaTimer(
          id: 'id',
          title: 'paused',
          paused: true,
          pausedAt: 1.minutes(),
          startTime: now.subtract(10.minutes()),
          duration: const Duration(minutes: 22),
        ),
        t3 = AbiliaTimer.createNew(
          title: 'past',
          startTime: now.subtract(22.minutes()).subtract(1.seconds()),
          duration: const Duration(minutes: 22),
        );

    await timerDb.insert(t1);
    await timerDb.insert(t2);
    await timerDb.insert(t3);

    final res = (await timerDb.getRunningTimersFrom(now)).toAlarm();

    expect(res, hasLength(1));
    expect(res.first, TimerAlarm(t1));
  });
}
