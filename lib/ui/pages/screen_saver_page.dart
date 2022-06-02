import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/datetime.dart';

class ScreenSaverPage extends StatelessWidget {
  const ScreenSaverPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) => Navigator.of(context).pop(),
      behavior: HitTestBehavior.translucent,
      child: BlocSelector<MemoplannerSettingBloc, MemoplannerSettingsState,
          DayParts>(
        selector: (state) => state.dayParts,
        builder: (context, dayParts) => BlocSelector<ClockBloc, DateTime, bool>(
          selector: (time) => time.isNight(dayParts),
          builder: (context, isNight) => Scaffold(
            backgroundColor: AbiliaColors.black,
            body: Opacity(
              opacity: isNight ? 0.3 : 1,
              child: Column(
                children: [
                  const ScreenSaverAppBar(),
                  Padding(
                    padding: layout.screenSaver.clockPadding,
                    child: BlocSelector<MemoplannerSettingBloc,
                        MemoplannerSettingsState, ClockType>(
                      selector: (state) => state.clockType,
                      builder: (context, clockType) => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (clockType != ClockType.digital)
                            Padding(
                              padding: EdgeInsets.only(
                                  right: layout.screenSaver.clockSeparation),
                              child: ScreensaverAnalogClock(isNight: isNight),
                            ),
                          if (clockType != ClockType.analogue)
                            DigitalClock(
                              style: layout.screenSaver.digitalClockTextStyle,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ScreenSaverAppBar extends StatelessWidget {
  const ScreenSaverAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
        builder: (context, memoSettingsState) => Padding(
          padding: layout.screenSaver.titleBarPadding,
          child: BlocBuilder<ClockBloc, DateTime>(
            builder: (state, time) => AppBarTitle(
              style: Theme.of(context)
                  .textTheme
                  .headline4
                  ?.copyWith(color: AbiliaColors.white),
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
        ),
      );
}
