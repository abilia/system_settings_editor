import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class MonthAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => CalendarAppBar.size;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DayPickerBloc, DayPickerState>(
      builder: (context, state) => CalendarAppBar(
        day: state.day,
        calendarDayColor: DayColor.noColors,
        rows: AppBarTitleRows.month(
          currentTime: state.day,
          langCode: Localizations.localeOf(context).toLanguageTag(),
        ),
        leftAction: ActionButton(
          onPressed: () {},
          child: const Icon(AbiliaIcons.return_to_previous_page),
        ),
        rightAction: ActionButton(
          onPressed: () {},
          child: const Icon(AbiliaIcons.go_to_next_page),
        ),
      ),
    );
  }
}
