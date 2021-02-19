import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class CalendarBottomBar extends StatelessWidget {
  final DateTime day;
  final barHeigt = 64.0;

  const CalendarBottomBar({
    Key key,
    @required this.day,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarViewBloc, CalendarViewState>(
      builder: (context, state) => Theme(
        data: bottomNavigationBarTheme,
        child: BottomAppBar(
          child: Container(
            height: barHeigt,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                AddActivityButton(day: day),
                CalendarPeriodSelector(
                  groupValue: state.currentCalendarPeriod,
                ),
                MenuButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
