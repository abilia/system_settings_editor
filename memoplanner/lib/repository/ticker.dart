import 'dart:async';

import 'package:meta/meta.dart';
import 'package:memoplanner/utils/all.dart';

class Ticker {
  final _streamController = StreamController<DateTime>();
  late Stream<DateTime> _stream = _streamController.stream.asBroadcastStream();
  Stream<DateTime> get seconds => _stream;
  Stream<DateTime> get minutes => _stream.where((t) => t.second == 0);

  DateTime _time;
  DateTime get time => _time;

  Timer _realTimer() {
    _streamController.add(DateTime.now().onlyMinutes());
    return Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        _time = DateTime.now().onlySeconds();
        _streamController.add(_time);
      },
    );
  }

  late Timer _timer = _realTimer();

  Ticker({required DateTime initialTime}) : _time = initialTime {
    _timer = _realTimer();
  }

  @visibleForTesting
  Ticker.fake({
    required DateTime initialTime,
    Stream<DateTime> stream = const Stream.empty(),
  })  : _time = initialTime,
        _stream = stream.asBroadcastStream() {
    _stream.listen((tick) => _time = tick);
  }

  double? ticksPerSecond;
  DateTime? _initialFakeTime;
  void setFakeTime(DateTime initTime, {bool setTicker = true}) {
    _streamController.add(initTime);
    _initialFakeTime = initTime;
    _time = initTime;
    if (ticksPerSecond == null && setTicker) {
      setFakeTicker(1);
    }
  }

  void setFakeTicker(double speedUp) {
    assert(speedUp >= 0);
    _initialFakeTime ??= _time;
    ticksPerSecond = speedUp;
    _timer.cancel();
    if (ticksPerSecond == 0) return;
    final period = Duration(milliseconds: (1 / ticksPerSecond! * 1000).toInt());
    _timer = Timer.periodic(period, (t) {
      _time = _initialFakeTime!.add(Duration(seconds: t.tick));
      _streamController.add(_time);
    });
  }

  void reset() {
    _timer.cancel();
    ticksPerSecond = null;
    _initialFakeTime = null;
    _timer = _realTimer();
  }
}
