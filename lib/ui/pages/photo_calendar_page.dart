import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class PhotoCalendarPage extends StatelessWidget {
  const PhotoCalendarPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClockBloc, DateTime>(
      builder: (context, currentTime) =>
          BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
        builder: (context, state) {
          final theme = weekdayTheme(
            dayColor: state.calendarDayColor,
            languageCode: Localizations.localeOf(context).languageCode,
            weekday: currentTime.weekday,
          );
          return Theme(
            data: theme.theme,
            child: Scaffold(
              appBar: PhotoCalendarAppBar(),
              body: SafeArea(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          color: theme.color,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(20.s),
                                child: FittedAnalogClock(
                                  height: 92.s,
                                  width: 92.s,
                                ),
                              ),
                              DigitalClock(
                                style: theme.theme.textTheme.caption.copyWith(
                                  fontSize: 32.s,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 12.s,
                          right: 12.s,
                          child: ActionButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .popUntil((route) => route.isFirst);
                            },
                            child: Icon(AbiliaIcons.month),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: SlideShow(),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SlideShow extends StatelessWidget {
  const SlideShow({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SlideShowCubit>(
      create: (context) => SlideShowCubit(
        sortableBloc: context.read<SortableBloc>(),
      ),
      child: BlocBuilder<SlideShowCubit, SlideShowState>(
        builder: (context, state) {
          return AnimatedSwitcher(
            duration: const Duration(seconds: 1),
            child: FadeInAbiliaImage(
              imageFileId: state.currentFileId,
              // backgroundDecoration: BoxDecoration(color: AbiliaColors.white),
              // fileId: state.currentFileId,
              // filePath: null,
            ),
          );
        },
      ),
    );
  }
}

class PhotoCalendarAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const PhotoCalendarAppBar({
    Key key,
  }) : super(key: key);

  @override
  Size get preferredSize => CalendarAppBar.size;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
        builder: (context, memoSettingsState) {
          return BlocBuilder<ClockBloc, DateTime>(
            builder: (context, time) => CalendarAppBar(
              day: time.onlyDays(),
              calendarDayColor: memoSettingsState.calendarDayColor,
              rows: AppBarTitleRows.day(
                displayWeekDay: memoSettingsState.activityDisplayWeekDay,
                displayPartOfDay: memoSettingsState.activityDisplayDayPeriod,
                displayDate: memoSettingsState.activityDisplayDate,
                currentTime: time,
                day: time.onlyDays(),
                dayParts: memoSettingsState.dayParts,
                langCode: Localizations.localeOf(context).toLanguageTag(),
                translator: Translator.of(context).translate,
              ),
              showClock: false,
            ),
          );
        },
      );
}
