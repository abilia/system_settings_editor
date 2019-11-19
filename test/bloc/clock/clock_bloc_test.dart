import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc.dart';

void main() {
  group('ClockBloc', () {
    ClockBloc clockBloc;
    StreamController<DateTime> mockedTicker;
    DateTime initTime = DateTime(2019, 12, 12, 12, 12, 12, 12, 12);
    DateTime initTimeRounded = DateTime(2019, 12, 12, 12, 12);

    setUp(() {
      mockedTicker = StreamController<DateTime>();
      clockBloc = ClockBloc(mockedTicker.stream, initialTime: initTime);
    });

    test('initial state is a flat minute', () {
      expect(clockBloc.initialState.second, 0);
      expect(clockBloc.initialState.millisecond, 0);
      expect(clockBloc.initialState.microsecond, 0);
    });

    test('tick returns tick', () {
      final tick = DateTime(2000);
      mockedTicker.add(tick);
      expectLater(clockBloc, emitsInOrder([initTimeRounded, tick]));
    });

    tearDown(() {
      clockBloc.close();
      mockedTicker.close();
    });
  });
}
