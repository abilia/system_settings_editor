import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/ui/all.dart';

void main() {
  test('TimerWheel creation. Will be past since secondsLeft is 0', () {
    const timerWheel = TimerWheel.nonInteractive(
      secondsLeft: 0,
      lengthInMinutes: 1,
    );
    expect(timerWheel.isPast, true);
  });

  test('TimerWheel creation. Not past', () {
    const timerWheel = TimerWheel.nonInteractive(
      secondsLeft: 10,
      lengthInMinutes: 1,
    );
    expect(timerWheel.isPast, false);
  });
}
