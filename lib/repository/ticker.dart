import 'dart:async';

import 'package:seagull/utils/all.dart';

class Ticker {
  final DateTime initialTime;
  final Stream<DateTime> _stream;
  Ticker({DateTime initialTime, Stream<DateTime> stream})
      : initialTime = (initialTime ?? DateTime.now()).onlyMinutes(),
        _stream = stream ??
            Stream.periodic(Duration(seconds: 1), (_) => DateTime.now())
                .where((dateTime) => dateTime.second == 0)
                .map((d) => d.onlyMinutes());
  Stream<DateTime> get stream => _stream.asBroadcastStream();
}
