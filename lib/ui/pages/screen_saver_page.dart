import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/datetime.dart';

class ScreenSaverPage extends StatelessWidget {
  const ScreenSaverPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<InactivityCubit, InactivityState>(
      listenWhen: (previous, current) =>
          previous is! PointerDown && current is PointerDown,
      listener: (context, state) => Navigator.of(context).maybePop(),
      child: BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
        builder: (context, memoSettingsState) =>
            BlocBuilder<ClockBloc, DateTime>(
          builder: (context, time) {
            final bool isNight = time.isNight(memoSettingsState.dayParts);
            final AnalogClockStyle analogClock = isNight
                ? layout.screenSaver.nightClock
                : layout.screenSaver.dayClock;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: context.read<TouchDetectionCubit>().onPointerDown,
              child: Scaffold(
                backgroundColor: AbiliaColors.black,
                body: Column(
                  children: [
                    ScreenSaverAppBar(isNight: isNight, time: time),
                    Padding(
                      padding: layout.screenSaver.clockPadding,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (memoSettingsState.clockType != ClockType.digital)
                            Padding(
                              padding: EdgeInsets.only(
                                  right: layout.screenSaver.clockSeparation),
                              child: SizedBox(
                                height: layout.screenSaver.clockHeight,
                                child: FittedBox(
                                  fit: BoxFit.fitHeight,
                                  child: CustomizableAnalogClock(
                                      style: analogClock),
                                ),
                              ),
                            ),
                          if (memoSettingsState.clockType != ClockType.analogue)
                            DigitalClock(
                              style: layout.screenSaver
                                  .digitalClockTextStyle(isNight),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ScreenSaverAppBar extends StatelessWidget {
  final bool isNight;
  final DateTime time;

  const ScreenSaverAppBar({
    Key? key,
    required this.isNight,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
        builder: (context, memoSettingsState) => Padding(
          padding: layout.screenSaver.titleBarPadding,
          child: AppBarTitle(
            style: layout.screenSaver.titleBarTextStyle(isNight),
            rows: AppBarTitleRows.day(
              compactDay: true,
              displayWeekDay: memoSettingsState.activityDisplayWeekDay,
              displayPartOfDay: memoSettingsState.activityDisplayDayPeriod,
              displayDate: memoSettingsState.activityDisplayDate,
              currentTime: time,
              day: time.onlyDays(),
              dayParts: memoSettingsState.dayParts,
              langCode: Localizations.localeOf(context).toLanguageTag(),
              translator: Translator.of(context).translate,
            ),
          ),
        ),
      );
}
