import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/repository/ticker.dart';

void main() {
  test(
    'ticker ticks at start of first and secound minute',
    () async {

      final oneMinFromNow = DateTime.now().add(Duration(minutes: 1));

      final List<DateTime> ticks = await Ticker.minute().take(2).toList();
      
      final nextFlatMinute = DateTime(oneMinFromNow.year, oneMinFromNow.month,
          oneMinFromNow.day, oneMinFromNow.hour, oneMinFromNow.minute);

      final firstTick = ticks.first;
      expect(firstTick.second, 0, reason: '$firstTick second is not zero');

      final nextMinSubtract1Sec = nextFlatMinute.subtract(Duration(seconds: 1));
      expect(firstTick.isAfter(nextFlatMinute), isTrue,
          reason: '$firstTick is not after $nextMinSubtract1Sec');

      final nextMinAdd1Sec = nextFlatMinute.add(Duration(seconds: 1));
      expect(firstTick.isBefore(nextMinAdd1Sec), isTrue,
          reason: '$firstTick is not before $nextMinAdd1Sec');

      final DateTime nextTick = ticks.last;
      expect(nextTick.second, 0, reason: '$nextTick secound is not zero');

      final minAfterNextAdd1Sec =
          nextFlatMinute.add(Duration(minutes: 1, seconds: 1));
      expect(nextTick.isBefore(minAfterNextAdd1Sec), isTrue,
          reason: '$nextTick is not before $minAfterNextAdd1Sec');

      final minAfterNextSubtract1Sec = nextFlatMinute
          .add(Duration(minutes: 1))
          .subtract(Duration(seconds: 1));
      expect(nextTick.isAfter(minAfterNextSubtract1Sec), isTrue,
          reason: '$nextTick is not after $minAfterNextSubtract1Sec');
    },
    timeout: Timeout(Duration(minutes: 2, seconds: 1)),
    skip: 'Unblock if you are doing anything to ticker, otherwise this takes crazy amount of time'
  );
}
