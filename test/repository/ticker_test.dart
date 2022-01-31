@Timeout(Duration(seconds: 2))
import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/repository/all.dart';

void main() {
  test('real ticker ticks and save', () async {
    final initial = DateTime(2022, 01, 20, 11, 03);
    final ticker = Ticker(initialTime: initial);
    final firstTick = await ticker.seconds.first;
    expect(firstTick, ticker.time);
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
