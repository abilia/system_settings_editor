import 'dart:async';

import 'package:seagull/utils.dart';

class Ticker {
  Ticker._();
  static Stream<DateTime> second() =>
      Stream.periodic(Duration(seconds: 1), (_) => DateTime.now());
  //TODO(@bornold) Figure out how to use Stream.periodic(Duration(minutes: 1) instead and _stall_ first value until DateTime.now().second == 0
  static Stream<DateTime> minute() => second()
      .where((dateTime) => dateTime.second == 0)
      .map(onlyMinutes);
}
