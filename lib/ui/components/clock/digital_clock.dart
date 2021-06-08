// @dart=2.9

import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class DigitalClock extends StatelessWidget {
  final TextStyle style;
  const DigitalClock({Key key, this.style}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClockBloc, DateTime>(
      builder: (context, time) => Container(
        child: Tts(
          child: Text(
            hourAndMinuteFormat(context)(time),
            textAlign: TextAlign.center,
            style: style ?? Theme.of(context).textTheme.caption,
          ),
        ),
      ),
    );
  }
}
