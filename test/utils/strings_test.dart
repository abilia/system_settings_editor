import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/utils/all.dart';

void main() {
  test('Removing zeros', () {
    expect('01'.removeLeadingZeros(), '1');
    expect('000000001'.removeLeadingZeros(), '1');
    expect('00100'.removeLeadingZeros(), '100');
    expect('100'.removeLeadingZeros(), '100');
    expect('00'.removeLeadingZeros(), '0');
  });
}
