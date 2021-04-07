import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class CalendarBottomBar extends StatelessWidget {
  static final barHeigt = 64.0.s;

  const CalendarBottomBar({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DayPickerBloc, DayPickerState>(
      builder: (context, state) => BottomAppBar(
        child: Container(
          height: barHeigt,
          padding: EdgeInsets.symmetric(horizontal: 16.0.s),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              AddActivityButton(day: state.day),
              AbiliaTabBar(
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
    );
  }
}
