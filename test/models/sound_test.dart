import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/models/all.dart';

void main() {
  test('Correct string mapping', () {
    expect('Drum'.toSound(), Sound.Drum);
    expect('Trip'.toSound(), Sound.Trip);
    expect(Sound.Drum.name(), 'Drum');
  });
}
