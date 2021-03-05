import 'package:seagull/ui/all.dart';

class WeekCalendar extends StatelessWidget {
  const WeekCalendar({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 6.0.s,
          vertical: 8.s,
        ),
        child: Row(
          children: [
            WeekColumn(active: false),
            WeekColumn(active: false),
            WeekColumn(active: false),
            WeekColumn(active: true),
            WeekColumn(active: false),
            WeekColumn(active: false),
            WeekColumn(active: false),
          ],
        ),
      ),
    );
  }
}

class WeekColumn extends StatelessWidget {
  final bool active;
  const WeekColumn({
    Key key,
    @required this.active,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: active ? 107 : 39,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: active ? 6.0 : 1),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.fromBorderSide(
              BorderSide(
                color: AbiliaColors.transparentBlack30,
              ),
            ),
            color: AbiliaColors.transparentBlack20,
          ),
        ),
      ),
    );
  }
}
