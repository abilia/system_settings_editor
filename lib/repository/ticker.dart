import 'dart:async';

import 'package:seagull/utils/all.dart';

class Ticker {
  Ticker._();
  static Stream<DateTime> second() =>
      Stream.periodic(Duration(seconds: 1), (_) => DateTime.now());
  static Stream<DateTime> minute() => second()
      .where((dateTime) => dateTime.second == 0)
      .map((d) => d.onlyMinutes());
}
