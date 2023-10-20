import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:provider/provider.dart';

class ClockSettingsTab extends StatelessWidget {
  const ClockSettingsTab({super.key});
  @override
  Widget build(BuildContext context) {
    final is24h = MediaQuery.of(context).alwaysUse24HourFormat;
    final translate = Lt.of(context);
    return BlocBuilder<GeneralCalendarSettingsCubit, GeneralCalendarSettings>(
      builder: (context, state) {
        final tpState = state.timepillar;
        void onClockChanged(v) => context
            .read<GeneralCalendarSettingsCubit>()
            .changeSettings(state.copyWith(clockType: v));
        return SettingsTab(
          children: [
            Tts(child: Text(translate.clock)),
            Center(
              child: FittedAbiliaClock(
                state.clockType,
                height: layout.settings.clockHeight,
                width: layout.settings.clockWidth,
              ),
            ),
            RadioField(
              text: Text(translate.analogueDigital),
              value: ClockType.analogueDigital,
              groupValue: state.clockType,
              onChanged: onClockChanged,
            ),
            RadioField(
              text: Text(translate.analogue),
              value: ClockType.analogue,
              groupValue: state.clockType,
              onChanged: onClockChanged,
            ),
            RadioField(
              text: Text(translate.digital),
              value: ClockType.digital,
              groupValue: state.clockType,
              onChanged: onClockChanged,
            ),
            const Divider(),
            Tts(child: Text(translate.timeline)),
            const PreviewTimePillar(),
            SwitchField(
              key: TestKey.use12hSwitch,
              value: !is24h || tpState.use12h,
              onChanged: is24h
                  ? (value) => context
                      .read<GeneralCalendarSettingsCubit>()
                      .changeTimepillarSettings(tpState.copyWith(use12h: value))
                  : null,
              child: Text(translate.twelveHourFormat),
            ),
            const SizedBox.shrink(),
            RadioField<bool>(
                text: Text(translate.oneDot),
                value: false,
                groupValue: tpState.columnOfDots,
                onChanged: (value) => context
                    .read<GeneralCalendarSettingsCubit>()
                    .changeTimepillarSettings(
                        tpState.copyWith(columnOfDots: value))),
            RadioField<bool>(
              text: Text(translate.columnOfDots),
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
              child: Text(translate.lineAcrossCurrentTime),
            ),
            SwitchField(
              value: tpState.hourLines,
              onChanged: (value) => context
                  .read<GeneralCalendarSettingsCubit>()
                  .changeTimepillarSettings(tpState.copyWith(hourLines: value)),
              child: Text(translate.linesForEachHour),
            ),
          ],
        );
      },
    );
  }
}

class PreviewTimePillar extends StatelessWidget {
  const PreviewTimePillar({super.key});
  static final _time = DateTime(2021, 1, 1, 13, 30);

  @override
  Widget build(BuildContext context) {
    final interval = TimepillarInterval(
      start: DateTime(2021, 1, 1, 12),
      end: DateTime(2021, 1, 1, 15),
    );
    final measures = TimepillarMeasures(interval, 1.0);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => TimepillarMeasuresCubit.fixed(state: measures),
        ),
        BlocProvider(create: (context) => ClockCubit.fixed(_time)),
      ],
      child: Provider(
        create: (_) => measures,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Center(
            child: SizedBox(
              width: layout.settings.previewTimePillarWidth,
              child: BlocBuilder<GeneralCalendarSettingsCubit,
                  GeneralCalendarSettings>(
                buildWhen: (previous, current) =>
                    previous.timepillar != current.timepillar,
                builder: (context, state) {
                  final tpState = state.timepillar;
                  return Stack(
                    children: [
                      if (tpState.hourLines)
                        HourLines(
                          numberOfLines: 3,
                          hourHeight: measures.hourHeight,
                          width: layout.settings.previewTimePillarWidth,
                          strokeWidth: measures.hourLineWidth,
                        ),
                      Center(
                        child: TimePillar(
                          preview: true,
                          dayOccasion: Occasion.current,
                          dayParts: const DayParts(),
                          use12h: tpState.use12h,
                          nightParts: const [],
                          interval: interval,
                          columnOfDots: tpState.columnOfDots,
                          topMargin: 0.0,
                          measures: measures,
                        ),
                      ),
                      if (tpState.timeline)
                        Timeline(
                          top: currentDotMidPosition(
                                _time,
                                measures,
                                topMargin: 0,
                              ) -
                              layout.timepillar.timeLineHeight / 2,
                          width: measures.timePillarTotalWidth * 3,
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
