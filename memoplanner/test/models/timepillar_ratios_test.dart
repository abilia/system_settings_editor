import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/bloc/all.dart';

void main() {
  test('Night timepillar height is larger than day timepillar', () {
    final timepillarRatios = TimepillarRatios(
      dayPillarHeight: 100,
      nightPillarHeight: 1000,
    );
    expect(timepillarRatios.dayTimepillarRatio, TimepillarRatios.maxRatio);
    expect(timepillarRatios.nightTimepillarRatio, TimepillarRatios.maxRatio);
  });

  test('Night timepillar height is equal to day timepillar', () {
    final timepillarRatios = TimepillarRatios(
      dayPillarHeight: 100,
      nightPillarHeight: 100,
    );
    expect(timepillarRatios.dayTimepillarRatio,
        timepillarRatios.nightTimepillarRatio);
  });

  test('Night timepillar height is shorter than day timepillar', () {
    final timepillarRatios = TimepillarRatios(
      dayPillarHeight: 1000,
      nightPillarHeight: 100,
    );
    expect(
        timepillarRatios.dayTimepillarRatio, 100 - TimepillarRatios.minRatio);
    expect(timepillarRatios.nightTimepillarRatio, TimepillarRatios.minRatio);
  });
}
