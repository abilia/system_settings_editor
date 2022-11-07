import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/utils/all.dart';

void main() {
  test('testNullOnEmpty', () {
    expect('not empty'.nullOnEmpty(), 'not empty');
    expect(''.nullOnEmpty(), null);
  });
}
