@Timeout(Duration(seconds: 2))
import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/repository/all.dart';

void main() {
  test('real ticker ticks min and sec then and save to time ', () async {
    final initial = DateTime(2022, 01, 20, 11, 03);
    final ticker = Ticker(initialTime: initial);

    final aFlatMinute = predicate<DateTime>(
      (d) => d.second == 0 && d.millisecond == 0 && d.microsecond == 0,
      'is a minute',
    );
    final aFlatSecond = predicate<DateTime>(
      (d) => d.millisecond == 0 && d.microsecond == 0,
      'is a second',
    );

    await expectLater(ticker.minutes, emits(aFlatMinute));
    await expectLater(ticker.seconds, emits(aFlatSecond));
    expect(ticker.time, isNot(initial));
  });

  test('fake timer ticks and sets time', () async {
    final initTime = DateTime(2022, 01, 20, 11, 03);
    final newTime = DateTime(2022, 01, 25, 20, 33);

    final ticker = Ticker.fake(
      initialTime: initTime,
      stream: Stream.value(newTime),
    );
    await expectLater(ticker.seconds, emits(newTime));
    expect(ticker.time, newTime);
  });
}
