import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class PhotoCalendarPage extends StatelessWidget {
  const PhotoCalendarPage({Key? key}) : super(key: key);

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
              appBar: const PhotoCalendarAppBar(),
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
                              if (state.clockType != ClockType.digital)
                                Padding(
                                  padding: EdgeInsets.all(20.s),
                                  child: SizedBox(
                                    height: 92.s,
                                    width: 92.s,
                                    child: const FittedBox(
                                      child: AnalogClock(),
                                    ),
                                  ),
                                ),
                              if (state.clockType != ClockType.analogue)
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20.s),
                                  child: DigitalClock(
                                    style:
                                        theme.theme.textTheme.caption?.copyWith(
                                      fontSize: 32.s,
                                      height: 1,
                                    ),
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
                            child: const Icon(AbiliaIcons.month),
                          ),
                        ),
                      ],
                    ),
                    const Expanded(
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
