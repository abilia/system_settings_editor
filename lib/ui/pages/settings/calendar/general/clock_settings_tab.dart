import 'dart:async';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class ClockSettingsTab extends StatelessWidget {
  const ClockSettingsTab({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final is24h = MediaQuery.of(context).alwaysUse24HourFormat;
    final t = Translator.of(context).translate;
    return BlocBuilder<GeneralCalendarSettingsCubit,
        GeneralCalendarSettingsState>(
      builder: (context, state) {
        final tpState = state.timepillar;
        final onClockChanged = (v) => context
            .read<GeneralCalendarSettingsCubit>()
            .changeSettings(state.copyWith(clockType: v));
        return SettingsTab(
          children: [
            Tts(child: Text(t.clock)),
            Center(
              child: FittedAbiliaClock(
                state.clockType,
                height: 90.s,
                width: 72.s,
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
              value: !is24h || tpState.use12h,
              onChanged: is24h
                  ? (value) => context
                      .read<GeneralCalendarSettingsCubit>()
                      .changeTimepillarSettings(tpState.copyWith(use12h: value))
                  : null,
              child: Text(t.twelveHourFormat),
            ),
            const SizedBox.shrink(),
            RadioField<bool>(
                text: Text(t.oneDot),
                value: false,
                groupValue: tpState.columnOfDots,
                onChanged: (value) => context
                    .read<GeneralCalendarSettingsCubit>()
                    .changeTimepillarSettings(
                        tpState.copyWith(columnOfDots: value))),
            RadioField<bool>(
              text: Text(t.columnOfDots),
              value: true,
              groupValue: tpState.columnOfDots,
              onChanged: (value) => context
                  .read<GeneralCalendarSettingsCubit>()
                  .changeTimepillarSettings(
                      tpState.copyWith(columnOfDots: value)),
            ),
            const SizedBox.shrink(),
            SwitchField(
              value: tpState.timeline,
              onChanged: (value) => context
                  .read<GeneralCalendarSettingsCubit>()
                  .changeTimepillarSettings(tpState.copyWith(timeline: value)),
              child: Text(t.lineAcrossCurrentTime),
            ),
            SwitchField(
              value: tpState.hourLines,
              onChanged: (value) => context
                  .read<GeneralCalendarSettingsCubit>()
                  .changeTimepillarSettings(tpState.copyWith(hourLines: value)),
              child: Text(t.linesForEachHour),
            ),
          ],
        );
      },
    );
  }
}

class PreviewTimePillar extends StatelessWidget {
  const PreviewTimePillar({Key? key}) : super(key: key);

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
          create: (context) => TimepillarBloc.fake(state: ts),
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
              buildWhen: (previous, current) =>
                  previous.timepillar != current.timepillar,
              builder: (context, state) {
                final tpState = state.timepillar;
                return Stack(
                  children: [
                    if (tpState.hourLines)
                      HourLines(
                        numberOfLines: 3,
                        hourHeight: ts.hourHeight,
                      ),
                    Center(
                      child: TimePillar(
                        preview: true,
                        dayOccasion: Occasion.current,
                        dayParts: DayParts.standard(),
                        use12h: tpState.use12h,
                        nightParts: [],
                        interval: interval,
                        showTimeLine: tpState.timeline,
                        columnOfDots: tpState.columnOfDots,
                      ),
                    ),
                    if (tpState.timeline)
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
