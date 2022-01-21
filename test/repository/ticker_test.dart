@Timeout(Duration(seconds: 1, milliseconds: 100))
import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/repository/all.dart';

void main() {
  test(
      'real ticker ticks',
      () => expectLater(
          Ticker(initialTime: DateTime(2022, 01, 20, 11, 03)).seconds,
          emits(isA<DateTime>())));
}
