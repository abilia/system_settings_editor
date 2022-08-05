import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class PhotoCalendarPage extends StatelessWidget {
  const PhotoCalendarPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final layout_ = layout.photoCalendarLayout;
    final clockType = context
        .select((MemoplannerSettingBloc settings) => settings.state.clockType);
    final calendarDayColor = context.select(
        (MemoplannerSettingBloc settings) => settings.state.calendarDayColor);
    final weekday =
        context.select((ClockBloc currentTime) => currentTime.state.weekday);
    final theme = weekdayTheme(
      dayColor: calendarDayColor,
      languageCode: Localizations.localeOf(context).languageCode,
      weekday: weekday,
    );

    return Theme(
      data: theme.theme,
      child: Scaffold(
        appBar: const PhotoCalendarAppBar(),
        backgroundColor: theme.color,
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: layout_.clockRowHeight,
                child: Stack(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (clockType != ClockType.digital)
                          SizedBox(
                            height: layout_.analogClockSize +
                                layout.clock.borderWidth * 2,
                            width: layout_.analogClockSize,
                            child: const FittedBox(child: AnalogClock()),
                          ),
                        if (clockType == ClockType.analogueDigital)
                          SizedBox(width: layout_.clockDistance),
                        if (clockType != ClockType.analogue)
                          DigitalClock(
                            style: layout_.textStyle(clockType),
                          ),
                      ],
                    ).pad(
                      clockType == ClockType.digital
                          ? layout_.digitalClockPadding
                          : layout_.analogClockPadding,
                    ),
                    Positioned(
                      bottom: layout_.backButtonPosition.dy,
                      right: layout_.backButtonPosition.dx,
                      child: IconActionButton(
                        style: theme.isLight
                            ? actionButtonStyleLight
                            : actionButtonStyleDark,
                        onPressed: () {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                        },
                        child: const Icon(AbiliaIcons.closeProgram),
                      ),
                    ),
                  ],
                ),
              ),
              const Expanded(
                child: SlideShow(),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class SlideShow extends StatelessWidget {
  const SlideShow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final poppyImage = Image.asset(
      'assets/graphics/poppy_field.jpg',
      fit: BoxFit.cover,
    );
    return BlocProvider<SlideShowCubit>(
      create: (context) => SlideShowCubit(
        sortableBloc: context.read<SortableBloc>(),
      ),
      child: BlocBuilder<SlideShowCubit, SlideShowState>(
        builder: (context, state) {
          final currentFileId = state.currentFileId;
          final currentPath = state.currentPath;
          return AnimatedSwitcher(
            duration: const Duration(seconds: 1),
            child: GestureDetector(
              key: currentFileId != null ? Key(currentFileId) : null,
              onDoubleTap: () => context.read<SlideShowCubit>().next(),
              child: SizedBox.expand(
                child: currentFileId != null && currentPath != null
                    ? PhotoCalendarImage(
                        fileId: currentFileId,
                        filePath: currentPath,
                        errorContent: poppyImage,
                      )
                    : poppyImage,
              ),
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
    Key? key,
  }) : super(key: key);

  @override
  Size get preferredSize => layout.photoCalendarLayout.appBarSize;

  @override
  Widget build(BuildContext context) {
    final memoSettingsState = context.watch<MemoplannerSettingBloc>().state;
    final time = context.watch<ClockBloc>().state;
    return CalendarAppBar(
      textStyle: Theme.of(context).textTheme.headline4,
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
        compactDay: false,
      ),
      showClock: false,
    );
  }
}
