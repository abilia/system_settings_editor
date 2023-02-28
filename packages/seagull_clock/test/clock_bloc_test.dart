import 'dart:async';

import 'package:test/test.dart';
import 'package:seagull_clock/clock_bloc.dart';

void main() {
  late ClockBloc clockBloc;
  late StreamController<DateTime> mockedTicker;
  final initTime = DateTime(2019, 12, 12, 12, 12, 12, 12, 12);

  setUp(() {
    mockedTicker = StreamController<DateTime>();
    clockBloc = ClockBloc(mockedTicker.stream, initialTime: initTime);
  });

  test('initial state is a flat minute', () {
    expect(clockBloc.state.second, 0);
    expect(clockBloc.state.millisecond, 0);
    expect(clockBloc.state.microsecond, 0);
  });

  test('tick returns tick', () {
    final tick = DateTime(2000);
    mockedTicker.add(tick);
    expectLater(clockBloc.stream, emits(tick));
  });

  test('ticks returns ticks', () {
    final ticks =
        List.generate(100, (m) => DateTime(2000).add(Duration(minutes: m)));
    for (final tick in ticks) {
      mockedTicker.add(tick);
    }
    expectLater(clockBloc.stream, emitsInOrder(ticks));
  });

  tearDown(() {
    clockBloc.close();
    mockedTicker.close();
  });
}
