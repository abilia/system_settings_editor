import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/models/all.dart';

void main() {
  test('Correct string mapping', () {
    expect('AfloatSynth'.toSound(), Sound.AfloatSynth);
    expect('DoorBell'.toSound(), Sound.DoorBell);
    expect(Sound.BreathlessPiano.name, 'BreathlessPiano');
  });
}
