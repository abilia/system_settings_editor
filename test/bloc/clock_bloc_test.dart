import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc.dart';
import 'package:seagull/repositories.dart';

void main() {
  group('ClockBloc', () {
    ClockBloc clockBloc;

    setUp(() {
      clockBloc = ClockBloc(Ticker.minute());
    });

    test('initial state is a flat minute', () {
      expect(clockBloc.initialState.second, 0);
      expect(clockBloc.initialState.millisecond, 0);
      expect(clockBloc.initialState.microsecond, 0);
    });
    tearDown(() {
      clockBloc.close();
    });
  });
}