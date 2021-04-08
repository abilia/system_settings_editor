import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class DigitalClock extends StatelessWidget {
  const DigitalClock({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClockBloc, DateTime>(
      builder: (context, time) => Container(
        child: Tts(
          child: Text(
            hourAndMinuteFormat(context)(time),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.caption,
          ),
        ),
      ),
    );
  }
}
