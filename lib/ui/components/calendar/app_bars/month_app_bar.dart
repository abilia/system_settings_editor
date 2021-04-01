import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class MonthAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MonthAppBar({Key key}) : super(key: key);
  @override
  Size get preferredSize => CalendarAppBar.size;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MonthCalendarBloc, MonthCalendarState>(
      builder: (context, state) => CalendarAppBar(
        day: state.firstDay,
        calendarDayColor: DayColor.noColors,
        rows: AppBarTitleRows.month(
          currentTime: state.firstDay,
          langCode: Localizations.localeOf(context).toLanguageTag(),
        ),
        leftAction: ActionButton(
          onPressed: () =>
              context.read<MonthCalendarBloc>().add(GoToPreviousMonth()),
          child: const Icon(AbiliaIcons.return_to_previous_page),
        ),
        clockReplacement: state.occasion == Occasion.current
            ? null
            : GoToCurrentActionButton(
                onPressed: () =>
                    context.read<MonthCalendarBloc>().add(GoToCurrentMonth()),
              ),
        rightAction: ActionButton(
          onPressed: () =>
              context.read<MonthCalendarBloc>().add(GoToNextMonth()),
          child: const Icon(AbiliaIcons.go_to_next_page),
        ),
      ),
    );
  }
}
