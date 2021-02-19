import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class CalendarPeriodSelector extends StatelessWidget {
  final CalendarPeriod groupValue;
  const CalendarPeriodSelector({
    Key key,
    @required this.groupValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(children: [
        _SelectCalendarButton(
          onPressed: () async {
            await BlocProvider.of<CalendarViewBloc>(context)
                .add(CalendarPeriodChanged(CalendarPeriod.DAY));
          },
          icon: AbiliaIcons.day,
          value: CalendarPeriod.DAY,
          groupValue: groupValue,
          borderRadius: borderRadiusLeft,
        ),
        SizedBox(
          width: 2,
        ),
        _SelectCalendarButton(
          onPressed: () async {
            await BlocProvider.of<CalendarViewBloc>(context)
                .add(CalendarPeriodChanged(CalendarPeriod.WEEK));
          },
          icon: AbiliaIcons.week,
          value: CalendarPeriod.WEEK,
          groupValue: groupValue,
          borderRadius: BorderRadius.zero,
        ),
        SizedBox(
          width: 2,
        ),
        _SelectCalendarButton(
          onPressed: () async {
            await BlocProvider.of<CalendarViewBloc>(context)
                .add(CalendarPeriodChanged(CalendarPeriod.MONTH));
          },
          icon: AbiliaIcons.month,
          value: CalendarPeriod.MONTH,
          groupValue: groupValue,
          borderRadius: borderRadiusRight,
        )
      ]),
    );
  }
}

class _SelectCalendarButton extends StatelessWidget {
  final CalendarPeriod value;
  final CalendarPeriod groupValue;
  final IconData icon;
  final BorderRadius borderRadius;
  final VoidCallback onPressed;
  final Key buttonKey;

  const _SelectCalendarButton({
    this.buttonKey,
    @required this.onPressed,
    @required this.value,
    @required this.groupValue,
    @required this.icon,
    @required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final width = 64.0;
    final height = 48.0;
    final isSelected = value == groupValue;
    return FlatButton(
      key: buttonKey,
      height: height,
      minWidth: width,
      onPressed: onPressed,
      child: Icon(
        icon,
        size: smallIconSize,
        color: isSelected ? AbiliaColors.black : AbiliaColors.white,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: isSelected
            ? BorderSide.none
            : BorderSide(color: AbiliaColors.transparentWhite30),
      ),
      color: isSelected ? AbiliaColors.white : AbiliaColors.transparentWhite20,
    );
  }
}
