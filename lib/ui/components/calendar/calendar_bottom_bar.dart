import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class CalendarBottomBar extends StatelessWidget {
  final DateTime day;
  static final barHeigt = 64.0.s;

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
            padding: EdgeInsets.symmetric(horizontal: 16.0.s),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                AddActivityButton(day: day),
                AbiliaTabBar(
                  collapsedCondition: (i) => false,
                  tabs: <Widget>[
                    Icon(AbiliaIcons.day),
                    Icon(AbiliaIcons.week),
                    Icon(AbiliaIcons.month),
                  ],
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
