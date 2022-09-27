import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class PhotoCalendarPage extends StatelessWidget {
  const PhotoCalendarPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final photoCalendarLayout = layout.photoCalendarLayout;
    final functions = context
        .select((MemoplannerSettingBloc bloc) => bloc.state.settings.functions);
    final display = functions.display;
    final clockType = context.select((MemoplannerSettingBloc settings) =>
        settings.state.settings.calendar.clockType);
    final calendarDayColor = context.select((MemoplannerSettingBloc settings) =>
        settings.state.settings.calendar.dayColor);
    final weekday =
        context.select((ClockBloc currentTime) => currentTime.state.weekday);
    final theme = weekdayTheme(
      dayColor: calendarDayColor,
      languageCode: Localizations.localeOf(context).languageCode,
      weekday: weekday,
    );

    return Theme(
      data: theme.theme,
      child: WillPopScope(
        onWillPop: () async {
          final index = display.menu ? display.menuTabIndex : 0;
          DefaultTabController.of(context)?.index = index;
          return false;
        },
        child: Scaffold(
          appBar: const PhotoCalendarAppBar(),
          backgroundColor: theme.color,
          body: SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: photoCalendarLayout.clockRowHeight,
                  child: Stack(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (clockType != ClockType.digital)
                            SizedBox(
                              height: photoCalendarLayout.analogClockSize +
                                  layout.clock.borderWidth * 2,
                              width: photoCalendarLayout.analogClockSize,
                              child: const FittedBox(child: AnalogClock()),
                            ),
                          if (clockType == ClockType.analogueDigital)
                            SizedBox(width: photoCalendarLayout.clockDistance),
                          if (clockType != ClockType.analogue)
                            DigitalClock(
                              style: photoCalendarLayout.textStyle(clockType),
                            ),
                        ],
                      ).pad(
                        clockType == ClockType.digital
                            ? photoCalendarLayout.digitalClockPadding
                            : photoCalendarLayout.analogClockPadding,
                      ),
                      Positioned(
                        bottom: photoCalendarLayout.backButtonPosition.dy,
                        right: photoCalendarLayout.backButtonPosition.dx,
                        child: IconActionButton(
                          style: theme.isLight
                              ? actionButtonStyleLight
                              : actionButtonStyleDark,
                          onPressed: () {
                            final index =
                                functions.startView == StartView.photoAlbum
                                    ? 0
                                    : functions.startViewIndex;
                            DefaultTabController.of(context)?.index = index;
                          },
                          child: Icon(functions.startView.icon),
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
      ),
    );
  }
}

extension StartViewExtension on StartView {
  IconData get icon {
    switch (this) {
      case StartView.weekCalendar:
        return AbiliaIcons.week;
      case StartView.monthCalendar:
        return AbiliaIcons.month;
      case StartView.menu:
        return AbiliaIcons.appMenu;
      default:
        return AbiliaIcons.day;
    }
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
    final appBarSettings = memoSettingsState.settings.dayCalendar.appBar;
    final time = context.watch<ClockBloc>().state;
    return CalendarAppBar(
      textStyle: Theme.of(context).textTheme.headline4,
      day: time.onlyDays(),
      calendarDayColor: memoSettingsState.settings.calendar.dayColor,
      rows: AppBarTitleRows.day(
        displayWeekDay: appBarSettings.showDayPeriod,
        displayPartOfDay: appBarSettings.showWeekday,
        displayDate: appBarSettings.showDate,
        currentTime: time,
        day: time.onlyDays(),
        dayPart: context.read<DayPartCubit>().state,
        dayParts: memoSettingsState.settings.calendar.dayParts,
        langCode: Localizations.localeOf(context).toLanguageTag(),
        translator: Translator.of(context).translate,
        compactDay: false,
      ),
      showClock: false,
    );
  }
}
