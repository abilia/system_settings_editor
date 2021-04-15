import 'dart:async';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class ClockSettingsTab extends StatelessWidget {
  const ClockSettingsTab({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final is24h = MediaQuery.of(context).alwaysUse24HourFormat;
    final t = Translator.of(context).translate;
    return BlocBuilder<GeneralCalendarSettingsCubit,
        GeneralCalendarSettingsState>(
      builder: (context, state) {
        final onClockChanged = (v) => context
            .read<GeneralCalendarSettingsCubit>()
            .changeFunctionSettings(state.copyWith(clockType: v));
        return SettingsTab(
          children: [
            Tts(child: Text(t.clock)),
            Center(
              child: SizedBox(
                height: 90.s,
                width: 72.s,
                child: FittedBox(
                  child: AbiliaClockType(
                    state.clockType,
                  ),
                ),
              ),
            ),
            RadioField(
              text: Text(t.analogueDigital),
              value: ClockType.analogueDigital,
              groupValue: state.clockType,
              onChanged: onClockChanged,
            ),
            RadioField(
              text: Text(t.analogue),
              value: ClockType.analogue,
              groupValue: state.clockType,
              onChanged: onClockChanged,
            ),
            RadioField(
              text: Text(t.digital),
              value: ClockType.digital,
              groupValue: state.clockType,
              onChanged: onClockChanged,
            ),
            const Divider(),
            Tts(child: Text(t.timeline)),
            const PreviewTimePillar(),
            SwitchField(
              key: TestKey.use12hSwitch,
              value: !is24h || state.use12h,
              onChanged: is24h
                  ? (value) => context
                      .read<GeneralCalendarSettingsCubit>()
                      .changeFunctionSettings(state.copyWith(use12h: value))
                  : null,
              text: Text(t.twelveHourFormat),
            ),
            const SizedBox.shrink(),
            RadioField(
              text: Text(t.oneDot),
              value: false,
              groupValue: state.columnOfDots,
              onChanged: (value) => context
                  .read<GeneralCalendarSettingsCubit>()
                  .changeFunctionSettings(state.copyWith(columnOfDots: value)),
            ),
            RadioField(
              text: Text(t.columnOfDots),
              value: true,
              groupValue: state.columnOfDots,
              onChanged: (value) => context
                  .read<GeneralCalendarSettingsCubit>()
                  .changeFunctionSettings(state.copyWith(columnOfDots: value)),
            ),
            const SizedBox.shrink(),
            SwitchField(
              value: state.timeline,
              onChanged: (value) => context
                  .read<GeneralCalendarSettingsCubit>()
                  .changeFunctionSettings(state.copyWith(timeline: value)),
              text: Text(t.lineAcrossCurrentTime),
            ),
            SwitchField(
              value: state.hourLines,
              onChanged: (value) => context
                  .read<GeneralCalendarSettingsCubit>()
                  .changeFunctionSettings(state.copyWith(hourLines: value)),
              text: Text(t.linesForEachHour),
            ),
          ],
        );
      },
    );
  }
}

class PreviewTimePillar extends StatelessWidget {
  const PreviewTimePillar({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final interval = TimepillarInterval(
      start: DateTime(2021, 1, 1, 12),
      end: DateTime(2021, 1, 1, 15),
    );
    final ts = TimepillarState(interval, 1.0);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => TimepillarBloc.fake(
            state: ts,
          ),
        ),
        BlocProvider(
          create: (context) => ClockBloc(
            StreamController<DateTime>().stream,
            initialTime: DateTime(2021, 1, 1, 13, 30),
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Center(
          child: SizedBox(
            width: 138.s,
            child: BlocBuilder<GeneralCalendarSettingsCubit,
                GeneralCalendarSettingsState>(
              builder: (context, state) {
                return Stack(
                  children: [
                    if (state.hourLines)
                      HourLines(
                        numberOfLines: 3,
                        hourHeight: ts.hourHeight,
                      ),
                    Center(
                      child: TimePillar(
                        preview: true,
                        dayOccasion: Occasion.current,
                        dayParts: const DayParts(
                          21600000,
                          36000000,
                          43200000,
                          64800000,
                          82800000,
                        ),
                        use12h: state.use12h,
                        nightParts: [],
                        interval: interval,
                        showTimeLine: state.timeline,
                        columnOfDots: state.columnOfDots,
                      ),
                    ),
                    if (state.timeline)
                      Timeline(
                        width: ts.timePillarTotalWidth * 3,
                        timepillarState: ts,
                        offset: hoursToPixels(
                          interval.startTime.hour,
                          ts.dotDistance,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
