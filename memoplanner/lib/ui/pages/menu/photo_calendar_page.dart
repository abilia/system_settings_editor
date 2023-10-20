import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class PhotoCalendarPage extends CalendarTab {
  const PhotoCalendarPage({super.key});

  @override
  PreferredSizeWidget get appBar => const PhotoCalendarAppBar();

  @override
  Widget floatingActionButton(BuildContext context) => const FloatingActions();

  @override
  Widget build(BuildContext context) {
    final functionsSettings =
        context.select((MemoplannerSettingsBloc bloc) => bloc.state.functions);
    final displaySettings = functionsSettings.display;

    return WillPopScope(
      onWillPop: () async {
        final index = displaySettings.menu ? displaySettings.menuTabIndex : 0;
        DefaultTabController.of(context).index = index;
        return false;
      },
      child: const SlideShow(),
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
  const SlideShow({super.key});

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
  const PhotoCalendarAppBar({super.key});

  @override
  Size get preferredSize => Size(
      layout.photoCalendarLayout.appBarSize.width,
      layout.photoCalendarLayout.appBarSize.height +
          layout.photoCalendarLayout.clockRowHeight);

  @override
  Widget build(BuildContext context) {
    final calendarSettings =
        context.select((MemoplannerSettingsBloc bloc) => bloc.state.calendar);
    final dayAppBarSettings =
        context.select((MemoplannerSettingsBloc bloc) => bloc.state.dayAppBar);
    final time = context.watch<ClockCubit>().state;

    final photoCalendarLayout = layout.photoCalendarLayout;
    final functionsSettings =
        context.select((MemoplannerSettingsBloc bloc) => bloc.state.functions);
    final clockType = context.select(
        (MemoplannerSettingsBloc bloc) => bloc.state.calendar.clockType);

    final calendarDayColor = context
        .select((MemoplannerSettingsBloc bloc) => bloc.state.calendar.dayColor);
    final weekday =
        context.select((ClockCubit currentTime) => currentTime.state.weekday);
    final dayTheme = weekdayTheme(
      dayColor: calendarDayColor,
      languageCode: Localizations.localeOf(context).languageCode,
      weekday: weekday,
    );

    return ColoredBox(
      color: dayTheme.theme.appBarTheme.backgroundColor ?? Colors.white,
      child: Column(
        children: [
          Expanded(
            child: CalendarAppBar(
              textStyle: dayTheme.theme.textTheme.headlineMedium,
              day: time.onlyDays(),
              calendarDayColor: calendarSettings.dayColor,
              rows: AppBarTitleRows.day(
                settings: dayAppBarSettings,
                currentTime: time,
                day: time.onlyDays(),
                dayPart: context.read<DayPartCubit>().state,
                dayParts: calendarSettings.dayParts,
                langCode: Localizations.localeOf(context).toLanguageTag(),
                translate: Lt.of(context),
                compactDay: false,
              ),
              showClock: false,
            ),
          ),
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
                        style: photoCalendarLayout
                            .textStyle(clockType)
                            .copyWith(
                                color: dayTheme
                                    .theme.textTheme.headlineMedium?.color),
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
                    style: dayTheme.isLight
                        ? actionButtonStyleLight
                        : actionButtonStyleDark,
                    onPressed: () {
                      final index =
                          functionsSettings.startView == StartView.photoAlbum
                              ? 0
                              : functionsSettings.startViewIndex;
                      DefaultTabController.of(context).index = index;
                    },
                    child: Icon(functionsSettings.startView.icon),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
