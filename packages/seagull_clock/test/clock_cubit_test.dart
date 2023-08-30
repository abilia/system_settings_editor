import 'dart:async';

import 'package:seagull_clock/clock_cubit.dart';
import 'package:test/test.dart';

void main() {
  late ClockCubit clockCubit;
  late StreamController<DateTime> mockedTicker;
  final initTime = DateTime(2019, 12, 12, 12, 12, 12, 12, 12);

  setUp(() {
    mockedTicker = StreamController<DateTime>();
    clockCubit = ClockCubit(mockedTicker.stream, initialTime: initTime);
  });

  test('initial state is a flat minute', () {
    expect(clockCubit.state.second, 0);
    expect(clockCubit.state.millisecond, 0);
    expect(clockCubit.state.microsecond, 0);
  });

  test('tick returns tick', () {
    final tick = DateTime(2000);
    mockedTicker.add(tick);
    expectLater(clockCubit.stream, emits(tick));
  });

  test('ticks returns ticks', () {
    final ticks =
        List.generate(100, (m) => DateTime(2000).add(Duration(minutes: m)));
    for (final tick in ticks) {
      mockedTicker.add(tick);
    }
    expectLater(clockCubit.stream, emitsInOrder(ticks));
  });

  tearDown(() {
    clockCubit.close();
    mockedTicker.close();
  });
}
