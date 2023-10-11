import 'dart:math';

import 'package:flutter/material.dart';

part 'cary_clock_painter.dart';

class AnalogClock extends StatelessWidget {
  final DateTime time;
  const AnalogClock(this.time, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: CaryClockPainter(time));
}
