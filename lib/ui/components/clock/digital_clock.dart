import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:intl/intl.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class DigitalClock extends StatelessWidget {
  const DigitalClock({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final language = Localizations.localeOf(context).toLanguageTag();
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      builder: (context, settingsState) => BlocBuilder<ClockBloc, DateTime>(
        builder: (context, time) => Container(
          child: Tts(
            child: Text(
              settingsState.timepillarHourClockType == HourClockType.use12
                  ? DateFormat('hh:mm a', language).format(time)
                  : DateFormat('HH:mm', language).format(time),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.caption,
            ),
          ),
        ),
      ),
    );
  }
}
