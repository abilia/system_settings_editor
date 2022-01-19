import 'dart:async';

import 'package:meta/meta.dart';

class Ticker {
  final _streamController = StreamController<DateTime>();
  late Stream<DateTime> _stream = _streamController.stream.asBroadcastStream();
  Stream<DateTime> get stream => _stream;

  DateTime _time;
  DateTime get time => _time;

  get _realTimer => Timer.periodic(
        const Duration(seconds: 1),
        (_) {
          _time = DateTime.now();
          _streamController.add(_time);
        },
      );

  late Timer _timer = _realTimer;

  Ticker({required DateTime initialTime}) : _time = initialTime;

  @visibleForTesting
  Ticker.fake({
    required DateTime initialTime,
    Stream<DateTime> stream = const Stream.empty(),
  })  : _time = initialTime,
        _stream = stream;

  double? ticksPerSecond;
  DateTime? _initialFakeTime;
  void setFakeTime(DateTime initTime) {
    _streamController.add(initTime);
    _initialFakeTime = initTime;
    if (ticksPerSecond == null) {
      setFakeTicker(1);
    }
  }

  void setFakeTicker(double speedUp) {
    _initialFakeTime ??= _time;
    ticksPerSecond = speedUp;
    final period = Duration(milliseconds: (1 / ticksPerSecond! * 1000).toInt());
    _timer.cancel();
    _timer = Timer.periodic(period, (t) {
      _time = _initialFakeTime!.add(Duration(seconds: t.tick));
      _streamController.add(_time);
    });
  }

  void reset() {
    _timer.cancel();
    ticksPerSecond = null;
    _initialFakeTime = null;
    _timer = _realTimer;
  }
}
