// @dart=2.9

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/utils/all.dart';

void main() {
  ClockBloc clockBloc;
  StreamController<DateTime> mockedTicker;
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
    final ticks = List.generate(100, (m) => DateTime(2000).add(m.minutes()));
    ticks.forEach((tick) => mockedTicker.add(tick));
    expectLater(clockBloc.stream, emitsInOrder(ticks));
  });

  tearDown(() {
    clockBloc.close();
    mockedTicker.close();
  });
}
