import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class AbiliaClock extends StatelessWidget {
  const AbiliaClock({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
        buildWhen: (previous, current) =>
            previous.clockType != current.clockType,
        builder: (context, state) => AbiliaClockType(state.clockType),
      );
}

class AbiliaClockType extends StatelessWidget {
  final ClockType clockType;
  const AbiliaClockType(
    this.clockType, {
    Key key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final analog = clockType == ClockType.analogue ||
        clockType == ClockType.analogueDigital;
    final digital = clockType == ClockType.digital ||
        clockType == ClockType.analogueDigital;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (analog)
          AnalogClock(
            borderWidth: 1.0.s,
            borderColor: AbiliaColors.transparentBlack30,
            height: actionButtonMinSize,
            width: actionButtonMinSize,
            centerPointRadius: 4.0.s,
            hourNumberScale: 1.5.s,
            hourHandLength: 11.s,
            minuteHandLength: 15.s,
            fontSize: 7.s,
          ),
        if (digital) const DigitalClock(),
      ],
    );
  }
}
